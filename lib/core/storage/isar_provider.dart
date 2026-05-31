import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/logs/domain/log_entry.dart';
import '../../features/settings/domain/app_settings.dart';
import '../../features/subscription/domain/subscription_profile.dart';
import '../../features/subscription/domain/vpn_node.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationSupportDirectory();

  return Isar.open(
    [
      AppSettingsSchema,
      AppLogSchema,
      SubscriptionProfileSchema,
      VpnNodeSchema,
    ],
    directory: dir.path,
    name: 'siegeconnect',
  );
});
