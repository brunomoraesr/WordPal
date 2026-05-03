import 'package:flutter_test/flutter_test.dart';
import 'package:wordpal/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('toMap converts UserProfile to Map', () {
      final now = DateTime(2026, 3, 10);
      final profile = UserProfile(
        name: 'Maria',
        joinedAt: now,
        weeklyPracticeMinutes: {'M': 23},
        dailyReminder: true,
        pronunciationAccent: 'American English',
        translationLanguage: 'Español',
      );

      final map = profile.toMap();

      expect(map['name'], 'Maria');
      expect(map['joinedAt'], now.toIso8601String());
      expect(map['weeklyPracticeMinutes'], {'M': 23});
      expect(map['dailyReminder'], true);
      expect(map['pronunciationAccent'], 'American English');
      expect(map['translationLanguage'], 'Español');
    });

    test('fromMap creates UserProfile from Map', () {
      final now = DateTime(2026, 3, 10).toIso8601String();
      final map = {
        'name': 'João',
        'joinedAt': now,
        'weeklyPracticeMinutes': {'T': 10},
        'dailyReminder': false,
        'pronunciationAccent': 'British English',
        'translationLanguage': 'Português (BR)',
      };

      final profile = UserProfile.fromMap(map);

      expect(profile.name, 'João');
      expect(profile.joinedAt.toIso8601String(), now);
      expect(profile.weeklyPracticeMinutes, {'T': 10});
      expect(profile.dailyReminder, false);
      expect(profile.pronunciationAccent, 'British English');
      expect(profile.translationLanguage, 'Português (BR)');
    });

    test('defaultProfile creates a default UserProfile', () {
      final profile = UserProfile.defaultProfile();

      expect(profile.name, 'Student');
      expect(profile.dailyReminder, true);
      expect(profile.pronunciationAccent, 'British English');
      expect(profile.translationLanguage, 'Português (BR)');
      expect(profile.weeklyPracticeMinutes, {
        'M': 0, 'T': 0, 'W': 0, 'Th': 0, 'F': 0, 'S': 0, 'Su': 0
      });
    });

    test('copyWith updates fields correctly', () {
      final profile = UserProfile.defaultProfile();
      final updated = profile.copyWith(name: 'Alice', dailyReminder: false);

      expect(updated.name, 'Alice');
      expect(updated.dailyReminder, false);
      expect(updated.translationLanguage, profile.translationLanguage);
    });
  });
}
