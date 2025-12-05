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
      await _isar.userProfileEntitys.clear();
      await _isar.userProfileEntitys.put(entity);
    });
  }

  Future<UserProfile?> getProfile() async {
    final entity = await _isar.userProfileEntitys.where().findFirst();
    return entity?.toDomain();
  }
}
