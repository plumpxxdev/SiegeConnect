import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/storage/isar_provider.dart';
import '../domain/log_entry.dart';

final logRepositoryProvider = Provider<LogRepository>((ref) {
  return LogRepository(ref);
});

final recentLogsProvider = StreamProvider<List<AppLog>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.appLogs
      .where()
      .sortByCreatedAtDesc()
      .limit(200)
      .watch(fireImmediately: true);
});

class LogRepository {
  LogRepository(this._ref);

  final Ref _ref;

  Future<void> add({
    required String level,
    required String source,
    required String message,
  }) async {
    final isar = await _ref.read(isarProvider.future);
    final entry = AppLog()
      ..level = level
      ..source = source
      ..message = message
      ..createdAt = DateTime.now();

    await isar.writeTxn(() => isar.appLogs.put(entry));
  }
}
