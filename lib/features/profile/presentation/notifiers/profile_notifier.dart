import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nutriz/features/profile/domain/models/user_profile.dart';
import 'package:nutriz/features/gamification/presentation/providers/gamification_providers.dart'; // For isarProvider
import '../../data/repositories/profile_repository.dart';

part 'profile_notifier.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  UserProfile build() {
    _loadProfile();
    // Return default/loading state initially
    return UserProfile(
      id: 'loading',
      gender: Gender.male,
      birthDate: DateTime(1990, 1, 1),
      height: 170,
      currentWeight: 70,
      targetWeight: 70,
      weeklyGoal: 0,
      activityLevel: ActivityLevel.sedentary,
      mainGoal: MainGoal.maintain,
      dietaryPreference: DietaryPreference.classic,
      calculatedCalories: 2000,
      proteinGrams: 150,
      carbsGrams: 200,
      fatGrams: 65,
      isOnboardingCompleted: false,
    );
  }

  Future<void> _loadProfile() async {
    try {
      final isar = ref.read(isarProvider);
      final repository = ProfileRepository(isar);
      final profile = await repository.getProfile();
      if (profile != null) {
        state = profile;
      }
    } catch (e) {
      // Handle error or keep default
      print('Error loading profile: $e');
    }
  }

  void updateProfile(UserProfile newProfile) {
    state = newProfile;
  }

  void updateWeight(double newWeight) {
    state = state.copyWith(currentWeight: newWeight);
    // Recalculate progress or other metrics if needed
  }
}
