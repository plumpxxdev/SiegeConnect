package app.siegeconnect.client

import android.content.Intent
import android.net.VpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val vpnChannel = "app.siegeconnect/vpn"
    private val mihomoChannel = "app.siegeconnect/mihomo"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, vpnChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val prepareIntent = VpnService.prepare(this)
                        if (prepareIntent != null) {
                            result.error("VPN_PERMISSION", "VPN permission is required", null)
                            startActivity(prepareIntent)
                            return@setMethodCallHandler
                        }

                        val intent = Intent(this, PxxVpnService::class.java).apply {
                            action = PxxVpnService.ACTION_START
                            putExtra("configPath", call.argument<String>("configPath"))
                            putExtra("killSwitch", call.argument<Boolean>("killSwitch") ?: true)
                            putExtra("tunMode", call.argument<Boolean>("tunMode") ?: true)
                            putExtra("splitTunnelMode", call.argument<String>("splitTunnelMode") ?: "disabled")
                            putStringArrayListExtra(
                                "splitTunnelPackages",
                                ArrayList(call.argument<List<String>>("splitTunnelPackages") ?: emptyList())
                            )
                        }
                        startService(intent)
                        result.success(null)
                    }
                    "stop" -> {
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
}
