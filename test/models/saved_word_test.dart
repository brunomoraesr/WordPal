import 'package:flutter_test/flutter_test.dart';
import 'package:wordpal/models/saved_word.dart';

void main() {
  group('SavedWord', () {
    final now = DateTime.now();

    test('toMap converts SavedWord to Map', () {
      final word = SavedWord(
        id: 1,
        word: 'hello',
        phonetic: 'həˈləʊ',
        partOfSpeech: 'noun',
        definition: 'A greeting',
        audioUrl: 'hello.mp3',
        mastered: true,
        addedAt: now,
      );

      final map = word.toMap();

      expect(map['id'], 1);
      expect(map['word'], 'hello');
      expect(map['phonetic'], 'həˈləʊ');
      expect(map['part_of_speech'], 'noun');
      expect(map['definition'], 'A greeting');
      expect(map['audio_url'], 'hello.mp3');
      expect(map['mastered'], 1);
      expect(map['added_at'], now.toIso8601String());
    });

    test('fromMap creates SavedWord from Map', () {
      final map = {
        'id': 2,
        'word': 'test',
        'phonetic': '/test/',
        'part_of_speech': 'verb',
        'definition': 'To try',
        'audio_url': 'test.mp3',
        'mastered': 0,
        'added_at': now.toIso8601String(),
      };

      final word = SavedWord.fromMap(map);

      expect(word.id, 2);
      expect(word.word, 'test');
      expect(word.phonetic, '/test/');
      expect(word.partOfSpeech, 'verb');
      expect(word.definition, 'To try');
      expect(word.audioUrl, 'test.mp3');
      expect(word.mastered, false);
      expect(word.addedAt.toIso8601String(), now.toIso8601String());
    });
  });
}
