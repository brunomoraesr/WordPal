import 'package:flutter_test/flutter_test.dart';
import 'package:wordpal/models/word_entry.dart';

void main() {
  group('WordEntry', () {
    test('fromJson creates a valid WordEntry', () {
      final json = {
        "word": "hello",
        "phonetic": "həˈləʊ",
        "phonetics": [
          {"text": "həˈləʊ", "audio": "https://example.com/hello.mp3"}
        ],
        "meanings": [
          {
            "partOfSpeech": "noun",
            "definitions": [
              {
                "definition": "\"Hello!\" or an equivalent greeting.",
                "synonyms": ["greeting"],
                "antonyms": ["goodbye"]
              }
            ],
            "synonyms": ["hi"],
            "antonyms": []
          }
        ]
      };

      final entry = WordEntry.fromJson(json);

      expect(entry.word, "hello");
      expect(entry.phonetic, "həˈləʊ");
      expect(entry.phonetics.length, 1);
      expect(entry.phonetics[0].audio, "https://example.com/hello.mp3");
      expect(entry.meanings.length, 1);
      expect(entry.meanings[0].partOfSpeech, "noun");
      expect(entry.meanings[0].definitions[0].definition, "\"Hello!\" or an equivalent greeting.");
    });

    test('getters return correct values', () {
      final json = {
        "word": "test",
        "phonetics": [
          {"text": "/test/", "audio": "audio.mp3"}
        ],
        "meanings": [
          {
            "partOfSpeech": "noun",
            "definitions": [
              {
                "definition": "A procedure.",
                "synonyms": ["trial"],
                "antonyms": []
              }
            ],
            "synonyms": ["exam"],
            "antonyms": []
          }
        ]
      };

      final entry = WordEntry.fromJson(json);

      expect(entry.displayPhonetic, "/test/");
      expect(entry.audioUrl, "audio.mp3");
      expect(entry.allSynonyms, containsAll(["exam", "trial"]));
      expect(entry.partsOfSpeech, ["noun"]);
    });
  });
}
