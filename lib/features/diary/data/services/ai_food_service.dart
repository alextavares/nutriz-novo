import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/food.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../core/value_objects/macro_nutrients.dart';
import '../../../../core/network/worker_endpoints.dart';

class AiFoodService {
  static const _analyzePath = '/analyze-food';
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 45),
    ),
  );

  Future<Food> analyzeFoodImage(XFile imageFile) async {
    try {
      // Use XFile.readAsBytes() to support content:// URIs (common on Android
      // gallery/photo picker). Using dart:io File(path) can fail on device.
      final bytes = await imageFile.readAsBytes();
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : 'image.jpg',
        ),
      });

      final response = await _dio.post(
        '${resolveWorkerBaseUrl()}$_analyzePath',
        data: formData,
        options: Options(
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Não foi possível analisar a imagem (${response.statusMessage}).',
        );
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
        name: json['name'] ?? 'Alimento desconhecido',
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
        final status = e.response?.statusCode;
        final raw = e.response?.data;
        final body = raw == null
            ? null
            : (() {
                final s = raw.toString();
                if (s.length <= 300) return s;
                return '${s.substring(0, 300)}…';
              })();
        if (status == 413) {
          throw Exception(
            'A foto ficou grande demais para enviar. Tente aproximar, usar a galeria ou reduzir a resolução.',
          );
        }
        if (status == 404) {
          throw Exception(
            'Serviço de IA não encontrado (404). Verifique o Worker em ${resolveWorkerBaseUrl()}$_analyzePath',
          );
        }
        final suffix = body == null ? '' : '\n$body';
        throw Exception(
          'Erro ao analisar a foto (${status ?? 'sem status'}): ${e.message ?? e.toString()}$suffix',
        );
        // print('DioError Type: ${e.type}');
        // print('DioError Message: ${e.message}');
        // print('DioError Error: ${e.error}');
        // print('Worker Error Status: ${e.response?.statusCode}');
        // print('Worker Error Data: ${e.response?.data}');
      }
      // print('Full Exception: $e');
      throw Exception('Não foi possível analisar o alimento: $e');
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
