import 'package:isar/isar.dart';
import '../../domain/models/fasting_stage.dart';

part 'fasting_repository.g.dart';

@collection
class FastingStateEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String singletonKey = 'default';

  bool isFasting = false;
  DateTime? startTime;
  int elapsedMilliseconds = 0;
  int goalMilliseconds = 0;
}

class FastingRepository {
  final Isar _isar;

  FastingRepository(this._isar);

  Future<void> saveState({
    required bool isFasting,
    required DateTime? startTime,
    required Duration elapsed,
    required Duration goal,
  }) async {
    final entity = FastingStateEntity()
      ..singletonKey = 'default'
      ..isFasting = isFasting
      ..startTime = startTime
      ..elapsedMilliseconds = elapsed.inMilliseconds
      ..goalMilliseconds = goal.inMilliseconds;

    await _isar.writeTxn(() async {
      final existing = await _isar.fastingStateEntitys.getBySingletonKey(
        'default',
      );
      if (existing != null) {
        entity.id = existing.id;
      }
      await _isar.fastingStateEntitys.put(entity);
    });
  }

  Future<FastingStateEntity?> getState() async {
    return await _isar.fastingStateEntitys.getBySingletonKey('default');
  }

  Future<void> clearState() async {
    await _isar.writeTxn(() async {
      final existing = await _isar.fastingStateEntitys.getBySingletonKey(
        'default',
      );
      if (existing != null) {
        await _isar.fastingStateEntitys.delete(existing.id);
      }
    });
  }
}
