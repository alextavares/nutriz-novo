import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/entities/food_item.dart';
import '../datasources/local_food_database.dart';

abstract class FoodService {
  Future<List<FoodItem>> searchFood(String query);
  Future<FoodItem?> analyzeImage(File image);
  Future<FoodItem?> scanBarcode(String barcode);
}

class FoodServiceImpl implements FoodService {
  final String workerUrl =
      'https://nutriz-food-ai.alexandretmoraes110.workers.dev';
  
  // OpenFoodFacts API (gratuita, sem key)
  final String openFoodFactsUrl = 'https://world.openfoodfacts.org';

  @override
  Future<List<FoodItem>> searchFood(String query) async {
    if (query.isEmpty) return [];

    // 1. Primeiro busca no banco local (rápido, offline)
    final localResults = _searchLocalDatabase(query);
    
    // 2. Se encontrou resultados locais suficientes, retorna
    if (localResults.length >= 5) {
      return localResults;
    }

    // 3. Tenta buscar na API do Worker (se configurada)
    try {
      final apiResults = await _searchWorkerApi(query);
      if (apiResults.isNotEmpty) {
        // Combina resultados (local primeiro, depois API)
        return [...localResults, ...apiResults]
            .take(20)
            .toList();
      }
    } catch (e) {
      print('Worker API error: $e');
    }

    // 4. Fallback: OpenFoodFacts
    try {
      final offResults = await _searchOpenFoodFacts(query);
      return [...localResults, ...offResults]
          .take(20)
          .toList();
    } catch (e) {
      print('OpenFoodFacts error: $e');
    }

    // Retorna pelo menos os resultados locais
    return localResults;
  }

  /// Search local database
  List<FoodItem> _searchLocalDatabase(String query) {
    final results = LocalFoodDatabase.search(query);
    return results.map((food) => FoodItem(
      id: food['id'] as String,
      name: food['name'] as String,
      brand: food['brand'] as String?,
      calories: (food['calories'] as num).toDouble(),
      protein: (food['protein'] as num).toDouble(),
      carbs: (food['carbs'] as num).toDouble(),
      fat: (food['fat'] as num).toDouble(),
      servingSize: food['servingSize'] as String,
    )).toList();
  }

  /// Search Worker API
  Future<List<FoodItem>> _searchWorkerApi(String query) async {
    final response = await http.get(
      Uri.parse('$workerUrl/search-food?q=$query'),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => FoodItem.fromJson(json)).toList();
    }
    return [];
  }

  /// Search OpenFoodFacts API
  Future<List<FoodItem>> _searchOpenFoodFacts(String query) async {
    final response = await http.get(
      Uri.parse('$openFoodFactsUrl/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=10'),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final products = data['products'] as List<dynamic>? ?? [];
      
      return products
          .where((p) => p['product_name'] != null)
          .map((p) {
            final nutrients = p['nutriments'] ?? {};
            return FoodItem(
              id: 'off_${p['code'] ?? DateTime.now().millisecondsSinceEpoch}',
              name: p['product_name'] ?? 'Unknown',
              brand: p['brands'],
              calories: _parseNutrient(nutrients['energy-kcal_100g']),
              protein: _parseNutrient(nutrients['proteins_100g']),
              carbs: _parseNutrient(nutrients['carbohydrates_100g']),
              fat: _parseNutrient(nutrients['fat_100g']),
              servingSize: '100g',
              imageUrl: p['image_small_url'],
            );
          })
          .where((f) => f.calories > 0) // Filtra itens sem dados nutricionais
          .toList();
    }
    return [];
  }

  double _parseNutrient(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Future<FoodItem?> analyzeImage(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$workerUrl/analyze-food'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return FoodItem.fromJson(data);
      } else {
        throw Exception('Failed to analyze image: ${response.body}');
      }
    } catch (e) {
      print('Error analyzing image: $e');
      return null;
    }
  }

  @override
  Future<FoodItem?> scanBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$openFoodFactsUrl/api/v0/product/$barcode.json'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1) {
          final p = data['product'];
          final nutrients = p['nutriments'] ?? {};
          
          return FoodItem(
            id: 'off_$barcode',
            name: p['product_name'] ?? 'Unknown Product',
            brand: p['brands'],
            calories: _parseNutrient(nutrients['energy-kcal_100g']),
            protein: _parseNutrient(nutrients['proteins_100g']),
            carbs: _parseNutrient(nutrients['carbohydrates_100g']),
            fat: _parseNutrient(nutrients['fat_100g']),
            servingSize: p['serving_size'] ?? '100g',
            imageUrl: p['image_small_url'],
          );
        }
      }
      return null;
    } catch (e) {
      print('Error scanning barcode: $e');
      return null;
    }
  }
}
