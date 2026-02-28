import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import '../../domain/entities/food_item.dart';
import '../models/diary_schemas.dart';
import '../datasources/local_food_database.dart';
import '../../../../core/network/worker_endpoints.dart';
import 'custom_food_service.dart';

abstract class FoodService {
  Future<List<FoodItem>> searchFood(String query);
  Future<List<FoodItem>> getFrequentFoods({int limit = 12, int days = 30});
  Future<List<FoodItem>> getRecentFoods({int limit = 12, int days = 30});
  Future<FoodItem?> analyzeImage(File image);
  Future<FoodItem?> scanBarcode(String barcode);
}

class FoodServiceImpl implements FoodService {
  final Isar? _isar;
  final CustomFoodService? _customFoodService;
  final String workerUrl = resolveWorkerBaseUrl();

  // OpenFoodFacts API (gratuita, sem key)
  final String openFoodFactsUrl = 'https://world.openfoodfacts.org';

  FoodServiceImpl({Isar? isar, CustomFoodService? customFoodService})
    : _isar = isar,
      _customFoodService = customFoodService;

  @override
  Future<List<FoodItem>> searchFood(String query) async {
    if (query.isEmpty) return _popularLocalDatabase();

    // 1. Primeiro busca no banco local (rápido, offline) e alimentos costumizados
    final localResults = _searchLocalDatabase(query);

    List<FoodItem> customResults = [];
    if (_customFoodService != null) {
      customResults = await _customFoodService!.searchCustomFoods(query);
    }

    final combinedLocalResults = [...customResults, ...localResults];

    // Mantém busca local para queries muito curtas
    if (query.length < 3) {
      return combinedLocalResults;
    }

    // Inicia a lista de resultados com os itens locais reunidos (banco offline + banco do usuário)
    List<FoodItem> finalResults = List.from(combinedLocalResults);

    // 3. Busca primária remota (Cloudflare D1 + IA):
    // O Worker agora consulta o banco TACO (rápido!) e só usa IA se não achar nada.
    try {
      final cloudResults = await _searchWorkerApi(query);
      if (cloudResults.isNotEmpty) {
        finalResults.addAll(cloudResults);
      }
    } catch (e) {
      // Ignora erro do worker
    }

    // 4. Fallback Secundário: OpenFoodFacts (Ampla base, mas pode ser lenta)
    // Acionamos apenas se tivermos poucos resultados brasileiros confiáveis
    if (finalResults.length < 5) {
      try {
        final offResults = await _searchOpenFoodFacts(query);
        if (offResults.isNotEmpty) {
          finalResults.addAll(offResults);
        }
      } catch (e) {
        // Ignora
      }
    }

    // Remove eventuais duplicatas por ID antes da ordenação final
    final seenIds = <String>{};
    final uniqueResults = <FoodItem>[];

    for (final item in finalResults) {
      if (!seenIds.contains(item.id)) {
        seenIds.add(item.id);
        uniqueResults.add(item);
      }
    }

    // Retorna ordenado por similaridade de nome, com um limite top 30
    return _sortByQuery(uniqueResults, query).take(30).toList();
  }

  @override
  Future<List<FoodItem>> getFrequentFoods({
    int limit = 12,
    int days = 30,
  }) async {
    final isar = _isar;
    if (isar == null) {
      return _popularLocalDatabase(limit);
    }

    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final safeDays = days <= 1 ? 0 : days - 1;
    final start = end.subtract(Duration(days: safeDays));

    final entries = await isar.diaryDaySchemas
        .filter()
        .dateBetween(start, end)
        .findAll();

    if (entries.isEmpty) {
      return _popularLocalDatabase(limit);
    }

    final counters = <String, _FrequentFood>{};

    for (final day in entries) {
      for (final meal in day.meals) {
        for (final foodItem in meal.foods) {
          final food = foodItem.food;
          final id = food.id.isNotEmpty
              ? food.id
              : food.name.toLowerCase().trim();
          final existing = counters[id];
          if (existing == null) {
            counters[id] = _FrequentFood(
              id: id,
              name: food.name,
              brand: food.brand,
              calories: food.calories,
              protein: food.protein,
              carbs: food.carbs,
              fat: food.fat,
              servingSize:
                  '${food.servingSize.toStringAsFixed(0)}${food.servingUnit}',
            );
          } else {
            existing.count++;
          }
        }
      }
    }

    final sorted = counters.values.toList()
      ..sort((a, b) {
        if (a.count != b.count) return b.count.compareTo(a.count);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return sorted
        .take(limit)
        .map(
          (item) => FoodItem(
            id: item.id,
            name: item.name,
            brand: item.brand,
            calories: item.calories,
            protein: item.protein,
            carbs: item.carbs,
            fat: item.fat,
            servingSize: item.servingSize,
          ),
        )
        .toList();
  }

  @override
  Future<List<FoodItem>> getRecentFoods({int limit = 12, int days = 30}) async {
    final isar = _isar;
    if (isar == null) {
      return [];
    }

    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final safeDays = days <= 1 ? 0 : days - 1;
    final start = end.subtract(Duration(days: safeDays));

    final entries = await isar.diaryDaySchemas
        .filter()
        .dateBetween(start, end)
        .findAll();

    if (entries.isEmpty) {
      return [];
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    final seen = <String>{};
    final results = <FoodItem>[];

    for (final day in entries) {
      final meals = List<MealEmbedded>.from(day.meals)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      for (final meal in meals) {
        for (final foodItem in meal.foods) {
          final food = foodItem.food;
          final key = food.id.isNotEmpty
              ? food.id
              : food.name.toLowerCase().trim();
          if (seen.contains(key)) continue;
          seen.add(key);
          results.add(
            FoodItem(
              id: food.id,
              name: food.name,
              brand: food.brand,
              calories: food.calories,
              protein: food.protein,
              carbs: food.carbs,
              fat: food.fat,
              servingSize:
                  '${food.servingSize.toStringAsFixed(0)}${food.servingUnit}',
            ),
          );
          if (results.length >= limit) {
            return results;
          }
        }
      }
    }

    return results;
  }

  /// Search local database
  List<FoodItem> _searchLocalDatabase(String query) {
    final results = LocalFoodDatabase.search(query);
    return results
        .map(
          (food) => FoodItem(
            id: food['id'] as String,
            name: food['name'] as String,
            brand: food['brand'] as String?,
            calories: (food['calories'] as num).toDouble(),
            protein: (food['protein'] as num).toDouble(),
            carbs: (food['carbs'] as num).toDouble(),
            fat: (food['fat'] as num).toDouble(),
            servingSize: food['servingSize'] as String,
          ),
        )
        .toList();
  }

  Future<List<FoodItem>> _popularLocalDatabase([int limit = 12]) async {
    final results = LocalFoodDatabase.popular(limit);
    final mappedLocal = results
        .map(
          (food) => FoodItem(
            id: food['id'] as String,
            name: food['name'] as String,
            brand: food['brand'] as String?,
            calories: (food['calories'] as num).toDouble(),
            protein: (food['protein'] as num).toDouble(),
            carbs: (food['carbs'] as num).toDouble(),
            fat: (food['fat'] as num).toDouble(),
            servingSize: food['servingSize'] as String,
          ),
        )
        .toList();

    if (_customFoodService == null) return mappedLocal;

    final customFoods = await _customFoodService!.searchCustomFoods('');

    // Mostramos os alimentos customizados recentes primeiro
    final combined = [...customFoods.reversed, ...mappedLocal];
    return combined.take(limit).toList();
  }

  /// Search Worker API
  Future<List<FoodItem>> _searchWorkerApi(String query) async {
    final response = await http
        .get(Uri.parse('$workerUrl/search-food?q=$query'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => FoodItem.fromJson(json)).toList();
    }
    return [];
  }

  /// Search OpenFoodFacts API via Cloudflare Proxy
  Future<List<FoodItem>> _searchOpenFoodFacts(String query) async {
    final response = await http
        .get(Uri.parse('$workerUrl/proxy-off?q=$query'))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final products = data['products'] as List<dynamic>? ?? [];

      return products
          .where((p) => p['product_name'] != null)
          .map((p) {
            final nutrients = p['nutriments'] ?? {};
            return FoodItem(
              id: 'off_${p['code'] ?? DateTime.now().millisecondsSinceEpoch}',
              name: p['product_name'] ?? 'Produto desconhecido',
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

  String _removeDiacritics(String str) {
    var withDia = 'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ';
    var withoutDia = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  List<FoodItem> _sortByQuery(List<FoodItem> items, String query) {
    final lowerQuery = _removeDiacritics(query.toLowerCase());
    final sorted = [...items];
    sorted.sort((a, b) {
      final scoreA = _matchScore(a, lowerQuery);
      final scoreB = _matchScore(b, lowerQuery);
      if (scoreA != scoreB) return scoreA.compareTo(scoreB);
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }

  int _matchScore(FoodItem item, String normalizedQuery) {
    final name = _removeDiacritics(item.name.toLowerCase());
    final brand = _removeDiacritics((item.brand ?? '').toLowerCase());

    if (name.startsWith(normalizedQuery) || brand.startsWith(normalizedQuery)) {
      return 0;
    }
    if (name.contains(' $normalizedQuery') ||
        brand.contains(' $normalizedQuery')) {
      return 1;
    }
    if (name.contains(normalizedQuery) || brand.contains(normalizedQuery)) {
      return 2;
    }
    return 3;
  }

  @override
  Future<FoodItem?> analyzeImage(File image) async {
    try {
      final bytes = await image.readAsBytes();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$workerUrl/analyze-food'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: 'image.jpg'),
      );

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        var body = response.body;
        body = body.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> data = jsonDecode(body);
        return FoodItem.fromJson(data);
      } else {
        throw Exception('Failed to analyze image: ${response.body}');
      }
    } catch (e) {
      // print('Error analyzing image: $e');
      return null;
    }
  }

  @override
  Future<FoodItem?> scanBarcode(String barcode) async {
    try {
      final response = await http
          .get(Uri.parse('$openFoodFactsUrl/api/v0/product/$barcode.json'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1) {
          final p = data['product'];
          final nutrients = p['nutriments'] ?? {};

          return FoodItem(
            id: 'off_$barcode',
            name: p['product_name'] ?? 'Produto desconhecido',
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
      // print('Error scanning barcode: $e');
      return null;
    }
  }
}

class _FrequentFood {
  final String id;
  final String name;
  final String? brand;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;
  int count;

  _FrequentFood({
    required this.id,
    required this.name,
    required this.brand,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
  }) : count = 1;
}
