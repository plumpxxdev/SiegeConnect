package app.siegeconnect.client

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log

class PxxVpnService : VpnService() {
    private var tunnel: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        try {
            when (intent?.action) {
                ACTION_START -> startTunnel(intent)
                ACTION_STOP -> stopTunnel()
            }
        } catch (error: Exception) {
            Log.e(TAG, "VPN service command failed", error)
            stopTunnel(closeService = true)
        }
        return START_STICKY
    }

    private fun startTunnel(intent: Intent) {
        stopTunnel(closeService = false)

        val packages = arrayListOf<String>()
        val splitMode = "disabled"
        val configPath = intent.getStringExtra("configPath") ?: return
        val tunMode = intent.getBooleanExtra("tunMode", true)

        if (tunMode) {
            val builder = Builder()
                .setSession("SiegeConnect")
                .setMtu(1500)
                .addAddress("10.222.0.2", 30)
                .addDnsServer("1.1.1.1")
                .addDnsServer("8.8.8.8")
                .addRoute("0.0.0.0", 0)

            try {
                builder
                    .addAddress("fdfe:dcba:9876::2", 126)
                    .addRoute("::", 0)
            } catch (error: Exception) {
                Log.w(TAG, "IPv6 VPN route is not available on this device", error)
            }

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
            if (tunnel == null) {
                throw IllegalStateException("Android VPN permission was not granted")
            }
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
        try {
            AndroidMihomoProcess.stop()
        } catch (error: Exception) {
            Log.w(TAG, "Failed to stop Mihomo cleanly", error)
        }
        try {
            tunnel?.close()
        } catch (error: Exception) {
            Log.w(TAG, "Failed to close Android VPN fd", error)
        }
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
