package app.siegeconnect.client

import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.system.Os
import android.system.OsConstants
import android.util.Log
import java.io.File
import java.io.FileDescriptor
import kotlin.concurrent.thread

class PxxVpnService : VpnService() {
    private var tunnel: ParcelFileDescriptor? = null
    private val mihomo = MihomoProcess(this)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startTunnel(intent)
            ACTION_STOP -> stopTunnel()
        }
        return START_STICKY
    }

    private fun startTunnel(intent: Intent) {
        stopTunnel(closeService = false)

        val packages = intent.getStringArrayListExtra("splitTunnelPackages") ?: arrayListOf()
        val splitMode = intent.getStringExtra("splitTunnelMode") ?: "disabled"
        val configPath = intent.getStringExtra("configPath") ?: return
        val tunMode = intent.getBooleanExtra("tunMode", true)

        if (tunMode) {
            val builder = Builder()
                .setSession("SiegeConnect")
                .addAddress("10.222.0.2", 30)
                .addDnsServer("1.1.1.1")
                .addRoute("0.0.0.0", 0)

            if (splitMode == "onlySelectedApps") {
                packages.forEach { packageName ->
                    builder.addAllowedApplication(packageName)
                }
            } else {
                val disallowedPackages =
                    if (splitMode == "excludeSelectedApps") packages else emptyList()
                (disallowedPackages + packageName).distinct().forEach { packageName ->
                    builder.addDisallowedApplication(packageName)
                }
            }

            tunnel = builder.establish()
        }

        mihomo.start(configPath, tunnel?.fd ?: -1, tunnel?.fileDescriptor)
    }

    private fun stopTunnel(closeService: Boolean = true) {
        mihomo.stop()
        tunnel?.close()
        tunnel = null
        if (closeService) {
            stopSelf()
        }
    }

    override fun onDestroy() {
        stopTunnel(closeService = false)
        super.onDestroy()
    }

    private class MihomoProcess(private val service: PxxVpnService) {
        private var process: Process? = null

        fun start(configPath: String, tunFd: Int, tunFileDescriptor: FileDescriptor?) {
            stop()
            val binary = ensureBinary()
            val runtimeConfigPath = prepareConfig(configPath, tunFd, tunFileDescriptor)
            process = ProcessBuilder(binary.absolutePath, "-f", runtimeConfigPath)
                .directory(service.filesDir)
                .redirectErrorStream(true)
                .start()
                .also { running ->
                    thread(name = "siegeconnect-mihomo-log", isDaemon = true) {
                        running.inputStream.bufferedReader().useLines { lines ->
                            lines.forEach { Log.i(TAG, it) }
                        }
                    }
                }
        }

        fun stop() {
            process?.let { running ->
                running.destroy()
                try {
                    running.waitFor()
                } catch (_: InterruptedException) {
                    Thread.currentThread().interrupt()
                }
                if (running.isAlive) {
                    running.destroyForcibly()
                }
            }
            process = null
        }

        private fun ensureBinary(): File {
            Build.SUPPORTED_ABIS.firstOrNull(SUPPORTED_ABIS::contains)
                ?: error("Unsupported Android ABI: ${Build.SUPPORTED_ABIS.joinToString()}")
            val target = File(service.applicationInfo.nativeLibraryDir, "libmihomo.so")
            target.setExecutable(true, true)
            return target
        }

        private fun prepareConfig(
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
            val target = File(service.filesDir, "runtime/selected-android.yaml")
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
            upsert("auto-route", "false")
            upsert("auto-detect-interface", "false")
            return lines.joinToString("\n")
        }

        companion object {
            private const val TAG = "SiegeConnectMihomo"
            private val SUPPORTED_ABIS = setOf(
                "arm64-v8a",
                "armeabi-v7a",
                "x86_64",
            )
        }
    }

    companion object {
        const val ACTION_START = "app.siegeconnect.START"
        const val ACTION_STOP = "app.siegeconnect.STOP"
    }
}
