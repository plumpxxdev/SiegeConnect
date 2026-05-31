import 'package:isar/isar.dart';

part 'log_entry.g.dart';

@collection
class AppLog {
  Id id = Isar.autoIncrement;

  @Index()
  DateTime createdAt = DateTime.now();

  late String level;
  late String source;
  late String message;
}
