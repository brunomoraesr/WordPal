class UserProfile {
  final String name;
  final DateTime joinedAt;
  final Map<String, int> weeklyPracticeMinutes;
  final bool dailyReminder;
  final String pronunciationAccent;
  final String translationLanguage;

  UserProfile({
    required this.name,
    required this.joinedAt,
    required this.weeklyPracticeMinutes,
    this.dailyReminder = true,
    this.pronunciationAccent = 'British English',
    this.translationLanguage = 'Português (BR)',
  });

  UserProfile copyWith({
    String? name,
    DateTime? joinedAt,
    Map<String, int>? weeklyPracticeMinutes,
    bool? dailyReminder,
    String? pronunciationAccent,
    String? translationLanguage,
  }) {
    return UserProfile(
      name: name ?? this.name,
      joinedAt: joinedAt ?? this.joinedAt,
      weeklyPracticeMinutes: weeklyPracticeMinutes ?? this.weeklyPracticeMinutes,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      pronunciationAccent: pronunciationAccent ?? this.pronunciationAccent,
      translationLanguage: translationLanguage ?? this.translationLanguage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'joinedAt': joinedAt.toIso8601String(),
      'weeklyPracticeMinutes': weeklyPracticeMinutes,
      'dailyReminder': dailyReminder,
      'pronunciationAccent': pronunciationAccent,
      'translationLanguage': translationLanguage,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? 'Student',
      joinedAt: map['joinedAt'] != null
          ? DateTime.parse(map['joinedAt'] as String)
          : DateTime.now(),
      weeklyPracticeMinutes: map['weeklyPracticeMinutes'] != null
          ? Map<String, int>.from(map['weeklyPracticeMinutes'] as Map)
          : {},
      dailyReminder: map['dailyReminder'] as bool? ?? true,
      pronunciationAccent:
          map['pronunciationAccent'] as String? ?? 'British English',
      translationLanguage:
          map['translationLanguage'] as String? ?? 'Português (BR)',
    );
  }

  factory UserProfile.defaultProfile() {
    return UserProfile(
      name: 'Student',
      joinedAt: DateTime.now(),
      weeklyPracticeMinutes: {
        'M': 0,
        'T': 0,
        'W': 0,
        'Th': 0,
        'F': 0,
        'S': 0,
        'Su': 0,
      },
    );
  }

  int get practiceMinutesToday {
    final days = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];
    final today = DateTime.now().weekday - 1; // 0 = Monday
    return weeklyPracticeMinutes[days[today]] ?? 0;
  }
}
