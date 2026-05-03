import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class PreferencesService {
  static const _keyHistory = 'search_history';
  static const _keyPosFilter = 'pos_filter';
  static const _keyExamplesOnly = 'examples_only_mode';
  static const _keyUserProfile = 'user_profile';

  static const int maxHistory = 20;

  Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUserProfile);
    if (raw == null) return UserProfile.defaultProfile();
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return UserProfile.fromMap(map);
    } catch (e) {
      return UserProfile.defaultProfile();
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, json.encode(profile.toMap()));
  }

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyHistory);
    if (raw == null) return [];
    return List<String>.from(json.decode(raw) as List<dynamic>);
  }

  Future<void> addToHistory(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.remove(word);
    history.insert(0, word);
    if (history.length > maxHistory) history.removeLast();
    await prefs.setString(_keyHistory, json.encode(history));
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }

  Future<String> getPosFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPosFilter) ?? 'all';
  }

  Future<void> setPosFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPosFilter, filter);
  }

  Future<bool> getExamplesOnlyMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyExamplesOnly) ?? false;
  }

  Future<void> setExamplesOnlyMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyExamplesOnly, value);
  }
}
