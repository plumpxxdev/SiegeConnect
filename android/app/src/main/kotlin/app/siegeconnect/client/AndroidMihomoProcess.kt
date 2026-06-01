package app.siegeconnect.client

import android.content.Context
import android.os.Build
import android.system.Os
import android.system.OsConstants
import android.util.Log
import java.io.File
import java.io.FileDescriptor
import java.util.ArrayDeque
import kotlin.concurrent.thread

object AndroidMihomoProcess {
    private const val TAG = "SiegeConnectMihomo"
    private val supportedAbis = setOf("arm64-v8a", "armeabi-v7a", "x86_64")
    private val logLines = ArrayDeque<String>()
    private var process: Process? = null

    @Synchronized
    fun start(
        context: Context,
        configPath: String,
        tunFd: Int = -1,
        tunFileDescriptor: FileDescriptor? = null,
    ) {
        stop()
        val appContext = context.applicationContext
        val binary = ensureBinary(appContext)
        val coreDir = File(appContext.filesDir, "mihomo").apply { mkdirs() }
        val runtimeConfigPath = prepareConfig(
            appContext,
            configPath,
            tunFd,
            tunFileDescriptor,
        )

        val running = ProcessBuilder(
            binary.absolutePath,
            "-d",
            coreDir.absolutePath,
            "-f",
            runtimeConfigPath,
        )
            .directory(coreDir)
            .redirectErrorStream(true)
            .start()

        process = running
        thread(name = "siegeconnect-mihomo-log", isDaemon = true) {
            running.inputStream.bufferedReader().useLines { lines ->
                lines.forEach { line ->
                    appendLog(line)
                    Log.i(TAG, line)
                }
            }
        }

        Thread.sleep(800)
        if (!running.isAlive) {
            val exitCode = try {
                running.exitValue()
            } catch (_: IllegalThreadStateException) {
                -1
            }
            process = null
            throw IllegalStateException(
                "Mihomo exited with code $exitCode. ${recentLogs()}",
            )
        }
    }

    @Synchronized
    fun stop() {
        process?.let { running ->
            running.destroy()
            Thread.sleep(300)
            if (running.isAlive) {
                running.destroyForcibly()
            }
        }
        process = null
    }

    private fun ensureBinary(context: Context): File {
        Build.SUPPORTED_ABIS.firstOrNull(supportedAbis::contains)
            ?: error("Unsupported Android ABI: ${Build.SUPPORTED_ABIS.joinToString()}")
        val target = File(context.applicationInfo.nativeLibraryDir, "libmihomo.so")
        if (!target.exists()) {
            error("Bundled Mihomo binary not found: ${target.absolutePath}")
        }
        target.setExecutable(true, true)
        return target
    }

    private fun prepareConfig(
        context: Context,
        configPath: String,
        tunFd: Int,
        tunFileDescriptor: FileDescriptor?,
    ): String {
        if (tunFd < 0 || tunFileDescriptor == null) {
            return configPath
        }

        try {
            Os.fcntlInt(tunFileDescriptor, OsConstants.F_SETFD, 0)
        } catch (error: Exception) {
            Log.w(TAG, "Failed to clear CLOEXEC on VPN fd", error)
        }

        val source = File(configPath).readText()
        val target = File(context.filesDir, "runtime/selected-android.yaml")
        target.parentFile?.mkdirs()
        target.writeText(injectTunFileDescriptor(source, tunFd))
        return target.absolutePath
    }

    private fun injectTunFileDescriptor(yaml: String, tunFd: Int): String {
        val lines = yaml.replace("\r\n", "\n").split('\n').toMutableList()
        val tunIndex = lines.indexOfFirst { it.trim() == "tun:" }
        if (tunIndex < 0) {
            return yaml
        }

        var endIndex = lines.size
        for (index in tunIndex + 1 until lines.size) {
            val line = lines[index]
            if (line.isNotBlank() && !line.startsWith(" ") && !line.startsWith("-")) {
                endIndex = index
                break
            }
        }

        fun upsert(key: String, value: String) {
            val lineIndex = (tunIndex + 1 until endIndex).firstOrNull { index ->
                lines[index].trimStart().startsWith("$key:")
            }
            if (lineIndex == null) {
                lines.add(tunIndex + 1, "  $key: $value")
                endIndex += 1
            } else {
                lines[lineIndex] = "  $key: $value"
            }
        }

        upsert("file-descriptor", tunFd.toString())
        upsert("stack", "gvisor")
        upsert("inet4-address", "10.222.0.2/30")
        upsert("inet6-address", "fdfe:dcba:9876::2/126")
        upsert("mtu", "1500")
        upsert("auto-route", "false")
        upsert("auto-detect-interface", "false")
        upsert("strict-route", "true")
        return lines.joinToString("\n")
    }

    private fun appendLog(line: String) {
        synchronized(logLines) {
            logLines.addLast(line)
            while (logLines.size > 40) {
                logLines.removeFirst()
            }
        }
    }

    private fun recentLogs(): String {
        return synchronized(logLines) {
            logLines.joinToString("\n").takeLast(1200)
        }
    }
}
