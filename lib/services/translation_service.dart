import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TranslationService {
  static const _baseUrl = 'https://api.mymemory.translated.net/get';

  // Returns PT-BR translation of [text], or null on failure.
  Future<String?> translate(String text) async {
    if (text.trim().isEmpty) return null;
    try {
      final uri = Uri.parse(
        '$_baseUrl?q=${Uri.encodeComponent(text)}&langpair=en|pt-BR',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final body = json.decode(response.body) as Map<String, dynamic>;
      final match = body['responseData']?['translatedText'] as String?;
      if (match == null || match.isEmpty) return null;
      // MyMemory sometimes returns the original text when it can't translate.
      if (match.toLowerCase() == text.toLowerCase()) return null;
      return match;
    } on SocketException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
