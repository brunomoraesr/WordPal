import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/saved_word.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wordpal.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE saved_words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL UNIQUE,
            phonetic TEXT,
            part_of_speech TEXT,
            definition TEXT,
            audio_url TEXT,
            mastered INTEGER NOT NULL DEFAULT 0,
            added_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> insertWord(SavedWord word) async {
    final db = await database;
    return db.insert(
      'saved_words',
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL
  Future<List<SavedWord>> getAllWords() async {
    final db = await database;
    final maps = await db.query('saved_words', orderBy: 'added_at DESC');
    return maps.map(SavedWord.fromMap).toList();
  }

  // READ ONE
  Future<SavedWord?> getWord(String word) async {
    final db = await database;
    final maps = await db.query(
      'saved_words',
      where: 'word = ?',
      whereArgs: [word.toLowerCase()],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return SavedWord.fromMap(maps.first);
  }

  // UPDATE mastery status
  Future<int> updateMastery(int id, bool mastered) async {
    final db = await database;
    return db.update(
      'saved_words',
      {'mastered': mastered ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<int> deleteWord(int id) async {
    final db = await database;
    return db.delete('saved_words', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isSaved(String word) async {
    final result = await getWord(word);
    return result != null;
  }
}
