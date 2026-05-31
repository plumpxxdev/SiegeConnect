import 'package:isar/isar.dart';

part 'subscription_profile.g.dart';

@collection
class SubscriptionProfile {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String subscriptionUrl;

  late String title;
  late String originalYaml;
  late String mergedYamlPath;

  int uploadBytes = 0;
  int downloadBytes = 0;
  int totalBytes = 0;
  int expireAtSeconds = 0;
  int updateIntervalHours = 24;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  DateTime? lastUsedAt;
}
