import Flutter
import NetworkExtension

final class VpnBridge: NSObject {
    private let vpnChannel = "app.pxxconnect/vpn"
    private let mihomoChannel = "app.pxxconnect/mihomo"

    func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        FlutterMethodChannel(name: vpnChannel, binaryMessenger: messenger)
            .setMethodCallHandler(handleVpnCall)
        FlutterMethodChannel(name: mihomoChannel, binaryMessenger: messenger)
            .setMethodCallHandler(handleMihomoCall)
    }

    private func handleVpnCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            guard
                let args = call.arguments as? [String: Any],
                let configPath = args["configPath"] as? String
            else {
                result(FlutterError(code: "BAD_ARGS", message: "configPath is required", details: nil))
                return
            }
            startPacketTunnel(configPath: configPath, result: result)
        case "stop":
            stopPacketTunnel(result: result)
        case "isAdministrator":
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleMihomoCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "delay":
            result(-1)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startPacketTunnel(configPath: String, result: @escaping FlutterResult) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error {
                result(FlutterError(code: "NE_LOAD", message: error.localizedDescription, details: nil))
                return
            }

            let manager = managers?.first ?? NETunnelProviderManager()
            let protocolConfiguration = NETunnelProviderProtocol()
            protocolConfiguration.providerBundleIdentifier = "app.pxxconnect.client.PacketTunnel"
            protocolConfiguration.serverAddress = "PXXConnect"
            protocolConfiguration.providerConfiguration = ["configPath": configPath]

            manager.protocolConfiguration = protocolConfiguration
            manager.localizedDescription = "PXXConnect"
            manager.isEnabled = true
            manager.saveToPreferences { saveError in
                if let saveError {
                    result(FlutterError(code: "NE_SAVE", message: saveError.localizedDescription, details: nil))
                    return
                }
                do {
                    try manager.connection.startVPNTunnel()
                    result(nil)
                } catch {
                    result(FlutterError(code: "NE_START", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    private func stopPacketTunnel(result: @escaping FlutterResult) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error {
                result(FlutterError(code: "NE_LOAD", message: error.localizedDescription, details: nil))
                return
            }
            managers?.first?.connection.stopVPNTunnel()
            result(nil)
        }
    }
}
