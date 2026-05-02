import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wordpal/models/word_entry.dart';
import 'package:wordpal/providers/app_provider.dart';
import 'package:wordpal/services/database_service.dart';
import 'package:wordpal/services/dictionary_service.dart';
import 'package:wordpal/services/preferences_service.dart';

import 'app_provider_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<DictionaryService>(),
  MockSpec<DatabaseService>(),
  MockSpec<PreferencesService>()
])
void main() {
  late MockDictionaryService mockDictService;
  late MockDatabaseService mockDbService;
  late MockPreferencesService mockPrefsService;
  late AppProvider provider;

  setUp(() {
    mockDictService = MockDictionaryService();
    mockDbService = MockDatabaseService();
    mockPrefsService = MockPreferencesService();

    // Default mock behaviors
    when(mockPrefsService.getHistory()).thenAnswer((_) async => []);
    when(mockPrefsService.getPosFilter()).thenAnswer((_) async => 'all');
    when(mockPrefsService.getExamplesOnlyMode()).thenAnswer((_) async => false);
    when(mockDbService.getAllWords()).thenAnswer((_) async => []);

    provider = AppProvider(
      dictService: mockDictService,
      dbService: mockDbService,
      prefsService: mockPrefsService,
    );
  });

  test('Initial state is correct', () {
    expect(provider.searchState, SearchState.idle);
    expect(provider.currentWord, isNull);
    expect(provider.searchError, isEmpty);
    expect(provider.history, isEmpty);
    expect(provider.savedWords, isEmpty);
    expect(provider.posFilter, 'all');
    expect(provider.examplesOnly, isFalse);
  });

  test('init() loads data from services', () async {
    when(mockPrefsService.getHistory()).thenAnswer((_) async => ['test']);
    when(mockPrefsService.getPosFilter()).thenAnswer((_) async => 'verb');
    when(mockPrefsService.getExamplesOnlyMode()).thenAnswer((_) async => true);

    await provider.init();

    expect(provider.history, ['test']);
    expect(provider.posFilter, 'verb');
    expect(provider.examplesOnly, isTrue);
  });

  test('search() updates state on success', () async {
    final entry = WordEntry(word: 'hello', phonetics: [], meanings: []);
    when(mockDictService.lookup('hello')).thenAnswer((_) async => entry);
    when(mockPrefsService.getHistory()).thenAnswer((_) async => ['hello']);

    await provider.search('hello');

    expect(provider.searchState, SearchState.success);
    expect(provider.currentWord, entry);
    expect(provider.history, ['hello']);
    verify(mockPrefsService.addToHistory('hello')).called(1);
  });

  test('search() updates state on error', () async {
    when(mockDictService.lookup('hello'))
        .thenThrow(DictionaryException('Not found', DictionaryErrorType.notFound));

    await provider.search('hello');

    expect(provider.searchState, SearchState.error);
    expect(provider.searchError, 'Not found');
    expect(provider.currentWord, isNull);
  });
}
