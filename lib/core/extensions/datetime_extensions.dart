extension DateTimeExtensions on DateTime {
  // Adicionar extensões de DateTime aqui
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
