package app.pxxconnect.client

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor

class PxxVpnService : VpnService() {
    private var tunnel: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startTunnel(intent)
            ACTION_STOP -> stopTunnel()
        }
        return START_STICKY
    }

    private fun startTunnel(intent: Intent) {
        val packages = intent.getStringArrayListExtra("splitTunnelPackages") ?: arrayListOf()
        val splitMode = intent.getStringExtra("splitTunnelMode") ?: "disabled"
        val configPath = intent.getStringExtra("configPath") ?: return

        val builder = Builder()
            .setSession("PXXConnect")
            .addAddress("10.222.0.2", 30)
            .addDnsServer("1.1.1.1")
            .addRoute("0.0.0.0", 0)

        packages.forEach { packageName ->
            when (splitMode) {
                "onlySelectedApps" -> builder.addAllowedApplication(packageName)
                "excludeSelectedApps" -> builder.addDisallowedApplication(packageName)
            }
        }

        tunnel = builder.establish()

        // The production build should call the gomobile-bound Mihomo library here:
        // Pxxcore.start(configPath, tunnel!!.fd)
        // The FD must be duplicated or owned according to the final Go bridge contract.
        MihomoNative.start(configPath, tunnel?.fd ?: -1)
    }

    private fun stopTunnel() {
        MihomoNative.stop()
        tunnel?.close()
        tunnel = null
        stopSelf()
    }

    override fun onDestroy() {
        stopTunnel()
        super.onDestroy()
    }

    companion object {
        const val ACTION_START = "app.pxxconnect.START"
        const val ACTION_STOP = "app.pxxconnect.STOP"
    }
}

object MihomoNative {
    fun start(configPath: String, tunFd: Int) {
        // Replace with gomobile generated binding, for example:
        // Pxxcore.start(configPath, tunFd)
    }

    fun stop() {
        // Pxxcore.stop()
    }
}
