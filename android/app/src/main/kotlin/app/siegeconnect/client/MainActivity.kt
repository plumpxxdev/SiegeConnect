package app.siegeconnect.client

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val vpnChannel = "app.siegeconnect/vpn"
    private val mihomoChannel = "app.siegeconnect/mihomo"
    private var pendingVpnStartIntent: Intent? = null
    private var pendingVpnResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, vpnChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> startVpn(call, result)
                    "stop" -> {
                        AndroidMihomoProcess.stop()
                        startService(Intent(this, PxxVpnService::class.java).apply {
                            action = PxxVpnService.ACTION_STOP
                        })
                        result.success(null)
                    }
                    "isAdministrator" -> result.success(true)
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mihomoChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "delay" -> result.success(-1)
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_VPN_PERMISSION) {
            val result = pendingVpnResult
            val intent = pendingVpnStartIntent
            pendingVpnResult = null
            pendingVpnStartIntent = null

            if (result == null || intent == null) {
                super.onActivityResult(requestCode, resultCode, data)
                return
            }

            if (resultCode == Activity.RESULT_OK) {
                startService(intent)
                result.success(null)
            } else {
                result.error(
                    "VPN_PERMISSION_DENIED",
                    "Разрешение Android VPN не выдано",
                    null,
                )
            }
            return
        }

        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun startVpn(call: MethodCall, result: MethodChannel.Result) {
        val tunMode = true
        val configPath = call.argument<String>("configPath")
        if (configPath.isNullOrBlank()) {
            result.error("CONFIG_PATH", "Config path is empty", null)
            return
        }

        val intent = buildVpnServiceIntent(call, configPath, tunMode)
        val prepareIntent = VpnService.prepare(this)
        if (prepareIntent != null) {
            if (pendingVpnResult != null) {
                result.error("VPN_PERMISSION_PENDING", "VPN permission request is already open", null)
                return
            }
            pendingVpnStartIntent = intent
            pendingVpnResult = result
            startActivityForResult(prepareIntent, REQUEST_VPN_PERMISSION)
            return
        }

        startService(intent)
        result.success(null)
    }

    private fun buildVpnServiceIntent(
        call: MethodCall,
        configPath: String,
        tunMode: Boolean,
    ): Intent {
        return Intent(this, PxxVpnService::class.java).apply {
            action = PxxVpnService.ACTION_START
            putExtra("configPath", configPath)
            putExtra("killSwitch", call.argument<Boolean>("killSwitch") ?: true)
            putExtra("tunMode", tunMode)
            putExtra("splitTunnelMode", call.argument<String>("splitTunnelMode") ?: "disabled")
            putStringArrayListExtra(
                "splitTunnelPackages",
                ArrayList(call.argument<List<String>>("splitTunnelPackages") ?: emptyList()),
            )
        }
    }

    companion object {
        private const val REQUEST_VPN_PERMISSION = 7301
    }
}
