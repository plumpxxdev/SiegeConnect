# SiegeConnect

SiegeConnect is an MIT-licensed cross-platform VPN client shell for Remnawave subscriptions. The app is designed around Flutter, Riverpod, Isar, Dio and Mihomo (Clash.Meta).

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
6. The generated runtime config includes internal Mihomo DNS, so TUN mode can
   hijack DNS instead of relying on a user's manual Windows DNS settings.

## Deep Links

SiegeConnect registers subscription import links on Android and Windows:

- `siegeconnect://add/{{SUBSCRIPTION_LINK}}`

The subscription URL may be encoded, for example:

```text
siegeconnect://add/https%3A%2F%2Fexample.com%2Fsub%3Ftoken%3Dabc
```

On Windows, a link opened while SiegeConnect is already running is forwarded to
the existing app window or tray instance instead of launching a second VPN
client process.

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

TUN mode on Windows is prepared by the setup installer through an elevated
background task. The portable build can run proxy mode, but setup is recommended
for normal TUN usage.

## License

SiegeConnect source code is released under the MIT License. See [LICENSE](LICENSE).
