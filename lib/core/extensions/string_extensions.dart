extension StringExtensions on String {
  // Adicionar extensões de String aqui
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
