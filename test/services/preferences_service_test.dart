import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordpal/services/preferences_service.dart';
import 'package:wordpal/models/user_profile.dart';

void main() {
  group('PreferencesService - UserProfile', () {
    late PreferencesService service;

    setUp(() {
      service = PreferencesService();
    });

    test('getUserProfile returns default if no data exists', () async {
      SharedPreferences.setMockInitialValues({});
      
      final profile = await service.getUserProfile();
      expect(profile.name, 'Student');
    });

    test('saveUserProfile and getUserProfile work correctly', () async {
      SharedPreferences.setMockInitialValues({});
      
      final profile = UserProfile.defaultProfile().copyWith(
        name: 'Maria',
        weeklyPracticeMinutes: {'M': 30, 'T': 15},
      );
      
      await service.saveUserProfile(profile);
      
      final loaded = await service.getUserProfile();
      expect(loaded.name, 'Maria');
      expect(loaded.weeklyPracticeMinutes, {'M': 30, 'T': 15});
    });

    test('getUserProfile returns default if data is corrupted', () async {
      SharedPreferences.setMockInitialValues({
        'user_profile': 'this is not valid json'
      });
      
      final profile = await service.getUserProfile();
      expect(profile.name, 'Student');
    });
  });
}
