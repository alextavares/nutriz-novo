import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nutriz/features/profile/domain/models/user_profile.dart';
import 'package:nutriz/features/gamification/presentation/providers/gamification_providers.dart'; // For isarProvider
import '../../data/repositories/profile_repository.dart';

part 'profile_notifier.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  ProfileRepository get _repository =>
      ProfileRepository(ref.read(isarProvider));

  @override
  UserProfile build() {
    _loadProfile();
    // Return default/loading state initially
    return UserProfile(
      id: ProfileRepository.singleProfileId,
      gender: Gender.male,
      birthDate: DateTime(1990, 1, 1),
      height: 170,
      currentWeight: 70,
      startWeight: 70,
      targetWeight: 70,
      weeklyGoal: 0,
      activityLevel: ActivityLevel.sedentary,
      mainGoal: MainGoal.maintain,
      dietaryPreference: DietaryPreference.balanced,
      calculatedCalories: 2000,
      proteinGrams: 150,
      carbsGrams: 200,
      fatGrams: 65,
      favoriteFoodKeys: const [],
      isOnboardingCompleted: false,
    );
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getProfile();
      if (profile != null) {
        state = profile;
      }
    } catch (e) {
      // Handle error or keep default
      // print('Error loading profile: $e');
    }
  }

  void updateProfile(UserProfile newProfile) {
    state = newProfile;
  }

  void updateWeight(double newWeight) {
    final updatedProfile = state.copyWith(currentWeight: newWeight);
    state = updatedProfile;
    unawaited(_repository.saveProfile(updatedProfile));
  }
}
