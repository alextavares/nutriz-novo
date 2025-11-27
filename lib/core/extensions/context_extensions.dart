import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Adicionar extensões de Context aqui
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}
