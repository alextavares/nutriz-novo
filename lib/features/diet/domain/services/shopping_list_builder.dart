class ShoppingListItem {
  final String key;
  final String displayName;
  final int count;
  final List<String> examples;

  const ShoppingListItem({
    required this.key,
    required this.displayName,
    required this.count,
    required this.examples,
  });
}

class ShoppingListBuilder {
  final List<String> ingredients;

  const ShoppingListBuilder(this.ingredients);

  List<ShoppingListItem> build() {
    final map = <String, _Bucket>{};
    for (final raw in ingredients) {
      final normalized = normalizeIngredientKey(raw);
      if (normalized.isEmpty) continue;
      map.putIfAbsent(normalized, () => _Bucket()).add(raw);
    }

    final items = map.entries
        .map((e) {
          final display = _pretty(e.key);
          return ShoppingListItem(
            key: e.key,
            displayName: display,
            count: e.value.count,
            examples: e.value.examples,
          );
        })
        .toList(growable: false);

    items.sort((a, b) => b.count.compareTo(a.count));
    return items;
  }

  static String normalizeIngredientKey(String raw) {
    var s = raw.trim().toLowerCase();
    if (s.isEmpty) return '';
    s = s.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
    s = s.replaceAll(RegExp(r'\s+'), ' ');

    // Remove leading quantities like "170g de", "2 colheres (sopa) de", "1 porção de"
    s = s.replaceFirst(
      RegExp(r'^\d+([,.]\d+)?\s*(g|kg|ml|l)\s+de\s+'),
      '',
    );
    s = s.replaceFirst(RegExp(r'^\d+([,.]\d+)?\s*(g|kg|ml|l)\s+'), '');

    final unitMatch = RegExp(
      r'^\d+([,.]\d+)?\s*(colher(?:es)?|xícara(?:s)?|xicara(?:s)?|copo(?:s)?|fatia(?:s)?|porção|porcao|unidade(?:s)?|dente(?:s)?|punhado|pitada)\b',
    ).firstMatch(s);
    if (unitMatch != null) {
      s = s.substring(unitMatch.end).trim();
      s = s.replaceFirst(RegExp(r'^de\s+'), '');
    }

    // Remove a plain leading number.
    s = s.replaceFirst(RegExp(r'^\d+\s+'), '');
    s = s.replaceFirst(RegExp(r'^de\s+'), '');

    // Light cleanup
    s = s.replaceAll(RegExp(r'[•\-–—]+'), '').trim();
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  static String _pretty(String key) {
    if (key.isEmpty) return key;
    final first = key.substring(0, 1).toUpperCase();
    return '$first${key.substring(1)}';
  }
}

class _Bucket {
  int count = 0;
  final List<String> examples = <String>[];

  void add(String raw) {
    count += 1;
    if (examples.length < 3 && !examples.contains(raw)) {
      examples.add(raw);
    }
  }
}

