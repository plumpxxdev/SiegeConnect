package app.siegeconnect.client

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log

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

        try {
            AndroidMihomoProcess.start(
                applicationContext,
                configPath,
                tunnel?.fd ?: -1,
                tunnel?.fileDescriptor,
            )
        } catch (error: Exception) {
            Log.e(TAG, "Failed to start Mihomo", error)
            stopTunnel(closeService = true)
        }
    }

    private fun stopTunnel(closeService: Boolean = true) {
        AndroidMihomoProcess.stop()
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

    companion object {
        private const val TAG = "SiegeConnectVpnService"
        const val ACTION_START = "app.siegeconnect.START"
        const val ACTION_STOP = "app.siegeconnect.STOP"
    }
}
