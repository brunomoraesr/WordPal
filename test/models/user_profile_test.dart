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
        reminderTime: '08:00',
        nativeLanguage: 'Português (BR)',
        learningGoal: 'Vocabulário geral',
        englishLevel: 'Não definido',
        fontSize: 1.0,
      );

      final map = profile.toMap();

      expect(map['name'], 'Maria');
      expect(map['joinedAt'], now.toIso8601String());
      expect(map['weeklyPracticeMinutes'], {'M': 23});
      expect(map['dailyReminder'], true);
      expect(map['reminderTime'], '08:00');
      expect(map['nativeLanguage'], 'Português (BR)');
      expect(map['learningGoal'], 'Vocabulário geral');
      expect(map['englishLevel'], 'Não definido');
      expect(map['fontSize'], 1.0);
    });

    test('fromMap creates UserProfile from Map', () {
      final now = DateTime(2026, 3, 10).toIso8601String();
      final map = {
        'name': 'João',
        'joinedAt': now,
        'weeklyPracticeMinutes': {'T': 10},
        'dailyReminder': false,
        'reminderTime': '10:00',
        'nativeLanguage': 'Español',
        'learningGoal': 'Inglês para negócios',
        'englishLevel': 'B2',
        'fontSize': 1.15,
      };

      final profile = UserProfile.fromMap(map);

      expect(profile.name, 'João');
      expect(profile.joinedAt.toIso8601String(), now);
      expect(profile.weeklyPracticeMinutes, {'T': 10});
      expect(profile.dailyReminder, false);
      expect(profile.reminderTime, '10:00');
      expect(profile.nativeLanguage, 'Español');
      expect(profile.learningGoal, 'Inglês para negócios');
      expect(profile.englishLevel, 'B2');
      expect(profile.fontSize, 1.15);
    });

    test('defaultProfile creates a default UserProfile', () {
      final profile = UserProfile.defaultProfile();

      expect(profile.name, 'Estudante');
      expect(profile.dailyReminder, true);
      expect(profile.nativeLanguage, 'Português (BR)');
      expect(profile.weeklyPracticeMinutes, {
        'M': 0, 'T': 0, 'W': 0, 'Th': 0, 'F': 0, 'S': 0, 'Su': 0
      });
    });

    test('copyWith updates fields correctly', () {
      final profile = UserProfile.defaultProfile();
      final updated = profile.copyWith(name: 'Alice', dailyReminder: false);

      expect(updated.name, 'Alice');
      expect(updated.dailyReminder, false);
      expect(updated.nativeLanguage, profile.nativeLanguage);
    });
  });
}
