import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // coloca tus datos aquí
  static const String GEMINI_ENDPOINT = 'https://YOUR_GEMINI_ENDPOINT_HERE';
  static const String GEMINI_API_KEY = 'AIzaSyDUe84YZlDVZs-9vAtOLFEks0yZXoFs7ro';

  /// Envía un prompt simple a Gemini para generar title + tags.
  /// Retorna un mapa: { "title": "...", "tags": "tag1,tag2" }
  static Future<Map<String, String>> generateTitleAndTagsFromFilename(String filename) async {
    final prompt = '''
Given the file name "$filename", generate a short title (max 6 words) and 3 tags separated by commas.
Provide output in JSON: {"title":"...","tags":"tag1,tag2,tag3"}
''';

    final body = {
      // Ajusta el formato de request según la API de Gemini a la que tengas acceso
      "prompt": prompt,
      "max_output_tokens": 200
    };

    final response = await http.post(
      Uri.parse(GEMINI_ENDPOINT),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $GEMINI_API_KEY',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Error Gemini: ${response.statusCode} ${response.body}');
    }

    final text = response.body;


    try {
      final parsed = jsonDecode(text);
      if (parsed is Map && parsed.containsKey('title') && parsed.containsKey('tags')) {
        return {
          'title': parsed['title'].toString(),
          'tags': parsed['tags'].toString(),
        };
      }
    } catch (_) {
      final regex = RegExp(r'\{[\s\S]*\}');
      final match = regex.firstMatch(text);
      if (match != null) {
        final jsonPart = match.group(0)!;
        final parsed = jsonDecode(jsonPart);
        return {
          'title': parsed['title'].toString(),
          'tags': parsed['tags'].toString(),
        };
      }
    }

    return {
      'title': filename.split('.').first.replaceAll('_', ' '),
      'tags': 'uncategorized'
    };
  }
}
