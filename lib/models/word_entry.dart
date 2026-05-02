class Phonetic {
  final String text;
  final String? audio;

  Phonetic({required this.text, this.audio});

  factory Phonetic.fromJson(Map<String, dynamic> json) => Phonetic(
        text: json['text'] as String? ?? '',
        audio: json['audio'] as String?,
      );
}

class Definition {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  Definition({
    required this.definition,
    this.example,
    required this.synonyms,
    required this.antonyms,
  });

  factory Definition.fromJson(Map<String, dynamic> json) => Definition(
        definition: json['definition'] as String? ?? '',
        example: json['example'] as String?,
        synonyms: List<String>.from(json['synonyms'] ?? []),
        antonyms: List<String>.from(json['antonyms'] ?? []),
      );
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;
  final List<String> synonyms;
  final List<String> antonyms;

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
    required this.synonyms,
    required this.antonyms,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) => Meaning(
        partOfSpeech: json['partOfSpeech'] as String? ?? '',
        definitions: (json['definitions'] as List<dynamic>? ?? [])
            .map((d) => Definition.fromJson(d as Map<String, dynamic>))
            .toList(),
        synonyms: List<String>.from(json['synonyms'] ?? []),
        antonyms: List<String>.from(json['antonyms'] ?? []),
      );
}

class WordEntry {
  final String word;
  final String? phonetic;
  final List<Phonetic> phonetics;
  final List<Meaning> meanings;

  WordEntry({
    required this.word,
    this.phonetic,
    required this.phonetics,
    required this.meanings,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) => WordEntry(
        word: json['word'] as String? ?? '',
        phonetic: json['phonetic'] as String?,
        phonetics: (json['phonetics'] as List<dynamic>? ?? [])
            .map((p) => Phonetic.fromJson(p as Map<String, dynamic>))
            .toList(),
        meanings: (json['meanings'] as List<dynamic>? ?? [])
            .map((m) => Meaning.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  String get displayPhonetic {
    if (phonetic != null && phonetic!.isNotEmpty) return phonetic!;
    for (final p in phonetics) {
      if (p.text.isNotEmpty) return p.text;
    }
    return '';
  }

  String? get audioUrl {
    for (final p in phonetics) {
      if (p.audio != null && p.audio!.isNotEmpty) return p.audio;
    }
    return null;
  }

  List<String> get allSynonyms {
    final result = <String>{};
    for (final m in meanings) {
      result.addAll(m.synonyms);
      for (final d in m.definitions) {
        result.addAll(d.synonyms);
      }
    }
    return result.take(8).toList();
  }

  List<String> get allAntonyms {
    final result = <String>{};
    for (final m in meanings) {
      result.addAll(m.antonyms);
      for (final d in m.definitions) {
        result.addAll(d.antonyms);
      }
    }
    return result.take(6).toList();
  }

  List<String> get partsOfSpeech =>
      meanings.map((m) => m.partOfSpeech).toSet().toList();
}
