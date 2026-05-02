import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/word_entry.dart';

class DictionaryException implements Exception {
  final String message;
  final DictionaryErrorType type;

  DictionaryException(this.message, this.type);
}

enum DictionaryErrorType { notFound, noConnection, serverError }

class DictionaryService {
  static const _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  Future<WordEntry> lookup(String word) async {
    final trimmed = word.trim().toLowerCase();
    if (trimmed.isEmpty) {
      throw DictionaryException('Empty word', DictionaryErrorType.notFound);
    }

    try {
      final uri = Uri.parse('$_baseUrl/$trimmed');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        if (data.isEmpty) {
          throw DictionaryException(
              'Word not found', DictionaryErrorType.notFound);
        }
        return WordEntry.fromJson(data.first as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw DictionaryException(
            'Word "$word" not found in dictionary.',
            DictionaryErrorType.notFound);
      } else {
        throw DictionaryException(
            'Server error (${response.statusCode})',
            DictionaryErrorType.serverError);
      }
    } on SocketException {
      throw DictionaryException(
          'No internet connection. Check your network and try again.',
          DictionaryErrorType.noConnection);
    } on DictionaryException {
      rethrow;
    } catch (e) {
      throw DictionaryException(
          'Unexpected error: $e', DictionaryErrorType.serverError);
    }
  }
}
