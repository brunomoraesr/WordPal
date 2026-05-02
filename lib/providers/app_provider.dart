import 'package:flutter/foundation.dart';
import '../models/saved_word.dart';
import '../models/word_entry.dart';
import '../services/database_service.dart';
import '../services/dictionary_service.dart';
import '../services/preferences_service.dart';

enum SearchState { idle, loading, success, error }

class AppProvider extends ChangeNotifier {
  final DictionaryService _dictService;
  final DatabaseService _dbService;
  final PreferencesService _prefsService;

  AppProvider({
    DictionaryService? dictService,
    DatabaseService? dbService,
    PreferencesService? prefsService,
  })  : _dictService = dictService ?? DictionaryService(),
        _dbService = dbService ?? DatabaseService(),
        _prefsService = prefsService ?? PreferencesService();

  // Search state
  SearchState _searchState = SearchState.idle;
  WordEntry? _currentWord;
  String _searchError = '';
  List<String> _history = [];

  // Notebook state
  List<SavedWord> _savedWords = [];

  // Filter / UI preferences
  String _posFilter = 'all';
  bool _examplesOnly = false;

  SearchState get searchState => _searchState;
  WordEntry? get currentWord => _currentWord;
  String get searchError => _searchError;
  List<String> get history => List.unmodifiable(_history);
  List<SavedWord> get savedWords => List.unmodifiable(_savedWords);
  String get posFilter => _posFilter;
  bool get examplesOnly => _examplesOnly;

  bool get isCurrentWordSaved {
    if (_currentWord == null) return false;
    return _savedWords.any((w) => w.word == _currentWord!.word.toLowerCase());
  }

  Future<void> init() async {
    _history = await _prefsService.getHistory();
    _posFilter = await _prefsService.getPosFilter();
    _examplesOnly = await _prefsService.getExamplesOnlyMode();
    _savedWords = await _dbService.getAllWords();
    notifyListeners();
  }

  Future<void> search(String word) async {
    if (word.trim().isEmpty) return;
    _searchState = SearchState.loading;
    _searchError = '';
    notifyListeners();

    try {
      _currentWord = await _dictService.lookup(word.trim());
      _searchState = SearchState.success;
      await _prefsService.addToHistory(word.trim().toLowerCase());
      _history = await _prefsService.getHistory();
    } on DictionaryException catch (e) {
      _searchState = SearchState.error;
      _searchError = e.message;
    } catch (e) {
      _searchState = SearchState.error;
      _searchError = 'Unexpected error. Please try again.';
    }
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _prefsService.clearHistory();
    _history = [];
    notifyListeners();
  }

  void setPosFilter(String filter) {
    _posFilter = filter;
    _prefsService.setPosFilter(filter);
    notifyListeners();
  }

  void setExamplesOnly(bool value) {
    _examplesOnly = value;
    _prefsService.setExamplesOnlyMode(value);
    notifyListeners();
  }

  Future<void> toggleSaveCurrentWord() async {
    if (_currentWord == null) return;
    final word = _currentWord!.word.toLowerCase();
    final existing = _savedWords.firstWhere(
      (w) => w.word == word,
      orElse: () => SavedWord(
          word: '', phonetic: '', partOfSpeech: '', definition: '', addedAt: DateTime.now()),
    );

    if (existing.word.isNotEmpty) {
      await _dbService.deleteWord(existing.id!);
      _savedWords = await _dbService.getAllWords();
    } else {
      final firstMeaning = _currentWord!.meanings.isNotEmpty
          ? _currentWord!.meanings.first
          : null;
      final firstDef = firstMeaning != null && firstMeaning.definitions.isNotEmpty
          ? firstMeaning.definitions.first.definition
          : '';

      final saved = SavedWord(
        word: word,
        phonetic: _currentWord!.displayPhonetic,
        partOfSpeech: firstMeaning?.partOfSpeech ?? '',
        definition: firstDef,
        audioUrl: _currentWord!.audioUrl,
        mastered: false,
        addedAt: DateTime.now(),
      );
      await _dbService.insertWord(saved);
      _savedWords = await _dbService.getAllWords();
    }
    notifyListeners();
  }

  Future<void> toggleMastery(SavedWord word) async {
    if (word.id == null) return;
    await _dbService.updateMastery(word.id!, !word.mastered);
    _savedWords = await _dbService.getAllWords();
    notifyListeners();
  }

  Future<void> deleteWord(SavedWord word) async {
    if (word.id == null) return;
    await _dbService.deleteWord(word.id!);
    _savedWords = await _dbService.getAllWords();
    notifyListeners();
  }

  void resetSearch() {
    _searchState = SearchState.idle;
    _currentWord = null;
    _searchError = '';
    notifyListeners();
  }
}
