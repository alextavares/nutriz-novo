import 'package:flutter/material.dart';
import 'legal_markdown_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalMarkdownScreen(
      title: 'Política de Privacidade',
      assetPath: 'assets/legal/privacy_policy.md',
    );
  }
}

