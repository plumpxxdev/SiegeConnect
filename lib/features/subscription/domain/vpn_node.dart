import 'package:isar/isar.dart';

part 'vpn_node.g.dart';

@collection
class VpnNode {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  @Index(caseSensitive: false)
  late String name;

  late String type;
  late String server;
  int port = 0;

  String countryCode = '';
  String network = '';
  String security = '';
  String rawYaml = '';

  int delayMs = -1;
  bool isSelected = false;
  DateTime updatedAt = DateTime.now();
}
