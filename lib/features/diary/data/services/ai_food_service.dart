import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/food.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../core/value_objects/macro_nutrients.dart';

class AiFoodService {
  // TODO: Update this URL after deploying your worker
  static const _workerUrl =
      'https://nutriz-food-ai.alexandretmoraes110.workers.dev';
  final Dio _dio = Dio();

  Future<Food> analyzeFoodImage(XFile imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post(
        _workerUrl,
        data: formData,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to analyze image: ${response.statusMessage}');
      }

      var responseBody = response.data.toString();
      // Clean markdown code blocks if present
      responseBody = responseBody
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final json = jsonDecode(responseBody);

      return Food(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: json['name'] ?? 'Unknown',
        calories: Calories(_parseValue(json['calories'])),
        macros: MacroNutrients(
          protein: _parseValue(json['protein']),
          carbs: _parseValue(json['carbs']),
          fat: _parseValue(json['fat']),
        ),
        servingSize: _parseValue(json['servingSize']) == 0.0
            ? 100.0
            : _parseValue(json['servingSize']),
        servingUnit: json['servingUnit'] ?? 'g',
      );
    } catch (e) {
      if (e is DioException) {
// print('DioError Type: ${e.type}');
// print('DioError Message: ${e.message}');
// print('DioError Error: ${e.error}');
// print('Worker Error Status: ${e.response?.statusCode}');
// print('Worker Error Data: ${e.response?.data}');
      }
// print('Full Exception: $e');
      throw Exception('Failed to analyze food: $e');
    }
  }

  double _parseValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove non-numeric characters except dot
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }
    return 0.0;
  }
}
