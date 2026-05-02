class SavedWord {
  final int? id;
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String definition;
  final String? audioUrl;
  final bool mastered;
  final DateTime addedAt;

  SavedWord({
    this.id,
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definition,
    this.audioUrl,
    this.mastered = false,
    required this.addedAt,
  });

  SavedWord copyWith({
    int? id,
    String? word,
    String? phonetic,
    String? partOfSpeech,
    String? definition,
    String? audioUrl,
    bool? mastered,
    DateTime? addedAt,
  }) {
    return SavedWord(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      audioUrl: audioUrl ?? this.audioUrl,
      mastered: mastered ?? this.mastered,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'word': word,
        'phonetic': phonetic,
        'part_of_speech': partOfSpeech,
        'definition': definition,
        'audio_url': audioUrl,
        'mastered': mastered ? 1 : 0,
        'added_at': addedAt.toIso8601String(),
      };

  factory SavedWord.fromMap(Map<String, dynamic> map) => SavedWord(
        id: map['id'] as int?,
        word: map['word'] as String,
        phonetic: map['phonetic'] as String? ?? '',
        partOfSpeech: map['part_of_speech'] as String? ?? '',
        definition: map['definition'] as String? ?? '',
        audioUrl: map['audio_url'] as String?,
        mastered: (map['mastered'] as int? ?? 0) == 1,
        addedAt: DateTime.parse(map['added_at'] as String),
      );
}
