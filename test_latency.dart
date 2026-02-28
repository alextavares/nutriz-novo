import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final query = 'torta de frango';
  final encodedQuery = Uri.encodeComponent(query);
  final uri = Uri.parse(
    'https://nutriz-food-ai.alexandretmoraes110.workers.dev/proxy-off?q=$encodedQuery',
  );

  print('Requesting: $uri');
  final stopwatch = Stopwatch()..start();
  try {
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    stopwatch.stop();
    print('Status Code: ${response.statusCode}');
    print('Time elapsed: ${stopwatch.elapsedMilliseconds} ms');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final products = data['products'] as List<dynamic>? ?? [];
      print('Total products returned: ${products.length}');
    } else {
      print('Response: ${response.body}');
    }
  } catch (e) {
    stopwatch.stop();
    print('Error: $e');
    print('Time elapsed before error: ${stopwatch.elapsedMilliseconds} ms');
  }
}
