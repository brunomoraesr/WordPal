class UserProfile {
  final String name;
  final DateTime joinedAt;
  final Map<String, int> weeklyPracticeMinutes;
  final bool dailyReminder;
  final String reminderTime; // "HH:mm" 24h format
  final String nativeLanguage;
  final String learningGoal;
  final String englishLevel;
  final double fontSize; // text scale factor: 0.85, 1.0, 1.15, 1.3

  UserProfile({
    required this.name,
    required this.joinedAt,
    required this.weeklyPracticeMinutes,
    this.dailyReminder = true,
    this.reminderTime = '08:00',
    this.nativeLanguage = 'Português (BR)',
    this.learningGoal = 'Vocabulário geral',
    this.englishLevel = 'Não definido',
    this.fontSize = 1.0,
  });

  UserProfile copyWith({
    String? name,
    DateTime? joinedAt,
    Map<String, int>? weeklyPracticeMinutes,
    bool? dailyReminder,
    String? reminderTime,
    String? nativeLanguage,
    String? learningGoal,
    String? englishLevel,
    double? fontSize,
  }) {
    return UserProfile(
      name: name ?? this.name,
      joinedAt: joinedAt ?? this.joinedAt,
      weeklyPracticeMinutes: weeklyPracticeMinutes ?? this.weeklyPracticeMinutes,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      learningGoal: learningGoal ?? this.learningGoal,
      englishLevel: englishLevel ?? this.englishLevel,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'joinedAt': joinedAt.toIso8601String(),
      'weeklyPracticeMinutes': weeklyPracticeMinutes,
      'dailyReminder': dailyReminder,
      'reminderTime': reminderTime,
      'nativeLanguage': nativeLanguage,
      'learningGoal': learningGoal,
      'englishLevel': englishLevel,
      'fontSize': fontSize,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? 'Estudante',
      joinedAt: map['joinedAt'] != null
          ? DateTime.parse(map['joinedAt'] as String)
          : DateTime.now(),
      weeklyPracticeMinutes: map['weeklyPracticeMinutes'] != null
          ? Map<String, int>.from(map['weeklyPracticeMinutes'] as Map)
          : {},
      dailyReminder: map['dailyReminder'] as bool? ?? true,
      reminderTime: map['reminderTime'] as String? ?? '08:00',
      nativeLanguage:
          map['nativeLanguage'] as String? ?? 'Português (BR)',
      learningGoal:
          map['learningGoal'] as String? ?? 'Vocabulário geral',
      englishLevel:
          map['englishLevel'] as String? ?? 'Não definido',
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 1.0,
    );
  }

  factory UserProfile.defaultProfile() {
    return UserProfile(
      name: 'Estudante',
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
