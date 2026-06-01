import 'package:isar/isar.dart';

part 'app_settings.g.dart';

enum ThemePreference {
  system,
  light,
  dark,
}

enum SplitTunnelMode {
  disabled,
  onlySelectedApps,
  excludeSelectedApps,
}

enum ConnectionMode {
  proxy,
  tun,
}

@collection
class AppSettings {
  Id id = 1;

  @Enumerated(EnumType.name)
  ThemePreference theme = ThemePreference.system;

  bool themeChosen = false;
  bool autoUpdateSubscription = true;
  int autoUpdateHours = 24;
  bool bypassRussia = true;
  bool killSwitch = true;
  bool tunMode = false;
  bool launchAtStartup = false;
  bool showConnectionMessages = true;
  bool showAnnouncements = true;

  @Enumerated(EnumType.name)
  SplitTunnelMode splitTunnelMode = SplitTunnelMode.disabled;

  List<String> splitTunnelPackages = [];
  DateTime updatedAt = DateTime.now();

  AppSettings copy() {
    return AppSettings()
      ..id = id
      ..theme = theme
      ..themeChosen = themeChosen
      ..autoUpdateSubscription = autoUpdateSubscription
      ..autoUpdateHours = autoUpdateHours
      ..bypassRussia = bypassRussia
      ..killSwitch = killSwitch
      ..tunMode = tunMode
      ..launchAtStartup = launchAtStartup
      ..showConnectionMessages = showConnectionMessages
      ..showAnnouncements = showAnnouncements
      ..splitTunnelMode = splitTunnelMode
      ..splitTunnelPackages = [...splitTunnelPackages]
      ..updatedAt = updatedAt;
  }

  void applyFrom(AppSettings other) {
    theme = other.theme;
    themeChosen = other.themeChosen;
    autoUpdateSubscription = other.autoUpdateSubscription;
    autoUpdateHours = other.autoUpdateHours;
    bypassRussia = other.bypassRussia;
    killSwitch = other.killSwitch;
    tunMode = other.tunMode;
    launchAtStartup = other.launchAtStartup;
    showConnectionMessages = other.showConnectionMessages;
    showAnnouncements = other.showAnnouncements;
    splitTunnelMode = other.splitTunnelMode;
    splitTunnelPackages = [...other.splitTunnelPackages];
  }
}

extension AppSettingsMode on AppSettings {
  ConnectionMode get connectionMode =>
      tunMode ? ConnectionMode.tun : ConnectionMode.proxy;

  set connectionMode(ConnectionMode mode) {
    tunMode = mode == ConnectionMode.tun;
  }
}
