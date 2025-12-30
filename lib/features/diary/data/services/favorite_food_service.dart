import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/entities/food_item.dart';
import '../../../profile/data/repositories/profile_repository.dart';

class FavoriteFoodService {
  static const _fileName = 'favorite_foods.json';
  final ProfileRepository? _profileRepository;

  FavoriteFoodService({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository;

  String buildKey(FoodItem item) {
    final id = item.id.trim();
    if (id.isNotEmpty) return id;
    final name = item.name.trim().toLowerCase();
    final brand = (item.brand ?? '').trim().toLowerCase();
    return '$name::$brand';
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<FoodItem>> getFavorites({int limit = 30}) async {
    final entries = await _readEntries();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _syncProfile(entries);
    return entries.take(limit).map((entry) => entry.food).toList();
  }

  Future<Set<String>> getFavoriteIds() async {
    final entries = await _readEntries();
    await _syncProfile(entries);
    return entries.map((entry) => entry.key).toSet();
  }

  Future<void> toggleFavorite(FoodItem item) async {
    final key = buildKey(item);
    final entries = await _readEntries();
    final index = entries.indexWhere((entry) => entry.key == key);
    if (index >= 0) {
      entries.removeAt(index);
    } else {
      final stored = item.id.trim().isEmpty ? item.copyWith(id: key) : item;
      entries.add(_FavoriteEntry(
        key: key,
        food: stored,
        createdAt: DateTime.now(),
      ));
    }
    await _writeEntries(entries);
    await _syncProfile(entries);
  }

  Future<List<_FavoriteEntry>> _readEntries() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      final data = jsonDecode(raw);
      if (data is! List) return [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(_FavoriteEntry.fromJson)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _writeEntries(List<_FavoriteEntry> entries) async {
    final file = await _getFile();
    final payload = entries.map((entry) => entry.toJson()).toList();
    await file.writeAsString(jsonEncode(payload));
  }

  Future<void> _syncProfile(List<_FavoriteEntry> entries) async {
    if (_profileRepository == null) return;
    final profile = await _profileRepository!.getProfile();
    if (profile == null) return;
    final keys = entries.map((entry) => entry.key).toList(growable: false);
    await _profileRepository!.saveProfile(
      profile.copyWith(favoriteFoodKeys: keys),
    );
  }
}

class _FavoriteEntry {
  final String key;
  final FoodItem food;
  final DateTime createdAt;

  _FavoriteEntry({
    required this.key,
    required this.food,
    required this.createdAt,
  });

  factory _FavoriteEntry.fromJson(Map<String, dynamic> json) {
    final foodJson = json['food'] as Map<String, dynamic>? ?? {};
    return _FavoriteEntry(
      key: json['key'] as String? ?? '',
      food: FoodItem.fromJson(foodJson),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'food': food.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
