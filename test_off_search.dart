import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final query = 'torta de';
  final encodedQuery = Uri.encodeComponent(query);
  final uri = Uri.parse(
    'https://nutriz-food-ai.alexandretmoraes110.workers.dev/proxy-off?q=$encodedQuery',
  );

  print('Requesting: $uri');
  try {
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('Response: ${response.body.substring(0, 100)}...');
    } else {
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
