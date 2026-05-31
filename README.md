# SiegeConnect

SiegeConnect is a proprietary cross-platform VPN client shell for Remnawave subscriptions. The app is designed around Flutter, Riverpod, Isar, Dio and Mihomo (Clash.Meta).

## Stack

- Flutter UI with Material 3 and Cupertino-friendly layout.
- Riverpod state management.
- Isar local cache for subscription profiles, nodes, settings and logs.
- Dio HTTP client with `User-Agent: Clash.Meta`.
- Mihomo core for AmneziaWG, Hysteria 2, VLESS, VMESS and Trojan.
- MethodChannels for native VPN APIs: Android `VpnService`, iOS `NetworkExtension`, and desktop core control.

## Core Flow

1. User imports a Remnawave subscription link.
2. The app downloads YAML using `User-Agent: Clash.Meta`.
3. The original YAML is cached locally.
4. SiegeConnect injects custom Clash rules:
   - `GEOSITE,ru,DIRECT`
   - `GEOIP,ru,DIRECT`
   - `DOMAIN-SUFFIX,ru,DIRECT`
   - `MATCH,PROXY`
5. The merged YAML is written to the app support directory and passed to Mihomo.

## Bootstrap

This machine currently needs Flutter/Dart installed before the app can be built.

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\bootstrap-flutter.ps1
```

After Flutter is installed:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
```

Install Mihomo for local Windows testing:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\install-mihomo.ps1
```

TUN mode on Windows must be started with administrator rights.
