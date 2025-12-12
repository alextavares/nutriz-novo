import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/food.dart';
import '../../data/services/ai_food_service.dart';

class AiFoodState {
  final bool isLoading;
  final String? error;
  final Food? analyzedFood;

  AiFoodState({this.isLoading = false, this.error, this.analyzedFood});

  AiFoodState copyWith({bool? isLoading, String? error, Food? analyzedFood}) {
    return AiFoodState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullable update logic simplified for this case
      analyzedFood: analyzedFood ?? this.analyzedFood,
    );
  }
}

class AiFoodNotifier extends StateNotifier<AiFoodState> {
  final AiFoodService _service;
  final ImagePicker _picker = ImagePicker();

  AiFoodNotifier(this._service) : super(AiFoodState());

  Future<void> pickAndAnalyzeImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source);
      if (image == null) return;

      state = state.copyWith(isLoading: true, error: null);

      final food = await _service.analyzeFoodImage(image);

      state = state.copyWith(isLoading: false, analyzedFood: food);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearResult() {
    state = AiFoodState();
  }
}
