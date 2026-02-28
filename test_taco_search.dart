import 'dart:io';
import 'package:nutriz/features/diary/data/datasources/local_food_database.dart';

void main() {
  // Test if TacoDatabase foods are loaded in foods array
  print('Total foods in LocalFoodDatabase: ${LocalFoodDatabase.foods.length}');

  // Try some searches
  final queries = ['arroz', 'carne', 'frango', 'taco', 'maçã', 'maca'];

  for (final q in queries) {
    print('--- Search for "$q" ---');
    final res = LocalFoodDatabase.search(q);
    print('Found ${res.length} items');
    for (var i = 0; i < (res.length > 5 ? 5 : res.length); i++) {
      print('- ${res[i]['name']} (ID: ${res[i]['id']})');
    }
    print('');
  }
}
