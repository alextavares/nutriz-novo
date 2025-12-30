import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';
import 'package:nutriz/core/debug/debug_flags.dart';
import '../../domain/models/user_profile.dart';
import '../models/user_profile_schema.dart';

class ProfileRepository {
  static const String singleProfileId = 'default';
  static const bool _log = false;

  final Isar _isar;

  ProfileRepository(this._isar);

  Stream<void> watchProfileChanges({bool fireImmediately = false}) {
    return _isar.userProfileEntitys.watchLazy(fireImmediately: fireImmediately);
  }

  Future<void> saveProfile(UserProfile profile) async {
    if (DebugFlags.canLog && _log) {
      debugPrint(
        'DEBUG: ProfileRepository.saveProfile profileId=${profile.id} '
        'isOnboardingCompleted=${profile.isOnboardingCompleted}',
      );
    }
    final entity = UserProfileEntity.fromDomain(profile);
    entity.profileId = singleProfileId;
    await _isar.writeTxn(() async {
      final existing = await _isar.userProfileEntitys.getByProfileId(
        singleProfileId,
      );
      if (existing != null) {
        if (DebugFlags.canLog && _log) {
          debugPrint(
            'DEBUG: ProfileRepository.saveProfile updating existing entityId=${existing.id}',
          );
        }
        entity.id = existing.id;
      } else {
        if (DebugFlags.canLog && _log) {
          debugPrint(
            'DEBUG: ProfileRepository.saveProfile creating new profile',
          );
        }
      }
      await _isar.userProfileEntitys.put(entity);
    });
  }

  Future<UserProfile?> getProfile() async {
    final entity = await _isar.userProfileEntitys.getByProfileId(
      singleProfileId,
    );
    if (DebugFlags.canLog && _log) {
      debugPrint(
        'DEBUG: ProfileRepository.getProfile found=${entity != null} '
        'isOnboardingCompleted=${entity?.isOnboardingCompleted}',
      );
    }
    return entity?.toDomain();
  }
}
