import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LegalMarkdownScreen extends StatelessWidget {
  final String title;
  final String assetPath;

  const LegalMarkdownScreen({super.key, required this.title, required this.assetPath});

  Future<String> _loadText() async {
    return rootBundle.loadString(assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: _loadText(),
        builder: (context, snapshot) {
          final text = snapshot.data;
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || text == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Não foi possível carregar este documento.'),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}

