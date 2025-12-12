import 'package:isar/isar.dart';
import '../../domain/models/user_profile.dart';
import '../models/user_profile_schema.dart';

class ProfileRepository {
  final Isar _isar;

  ProfileRepository(this._isar);

  Future<void> saveProfile(UserProfile profile) async {
    final entity = UserProfileEntity.fromDomain(profile);
    await _isar.writeTxn(() async {
      // Clear existing profile since we only support one user for now
      print('DEBUG: Clearing existing profiles...');
      await _isar.userProfileEntitys.clear();
      print(
        'DEBUG: Putting new profile: ${entity.id}, completed: ${entity.isOnboardingCompleted}',
      );
      await _isar.userProfileEntitys.put(entity);
    });
  }

  Future<UserProfile?> getProfile() async {
    final entity = await _isar.userProfileEntitys.where().findFirst();
    print(
      'DEBUG: Retrieved profile entity: ${entity?.id}, completed: ${entity?.isOnboardingCompleted}',
    );
    return entity?.toDomain();
  }
}
