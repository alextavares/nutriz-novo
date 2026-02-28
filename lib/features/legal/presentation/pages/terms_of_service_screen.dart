import 'package:flutter/material.dart';
import 'legal_markdown_screen.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalMarkdownScreen(
      title: 'Termos de Uso',
      assetPath: 'assets/legal/terms_of_service.md',
    );
  }
}

