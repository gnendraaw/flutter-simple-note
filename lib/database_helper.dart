import 'package:local_db/note.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:local_db/common/encrypt.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static late Database _database;

  DatabaseHelper._internal() {
    _databaseHelper = this;
  }

  factory DatabaseHelper() => _databaseHelper ?? DatabaseHelper._internal();

  Future<Database> get database async {
    _database = await _initializeDb();
    return _database;
  }

  static const String _tableName = 'notes';

  Future<Database> _initializeDb() async {
    var path = await getDatabasesPath();
    var db = openDatabase(
      join(path, 'note_db.db'),
      onCreate: _onCreate,
      version: 1,
      password: encrypt('secure password'),
    );
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            title TEXT, description TEXT
          )''',
    );
  }

  Future<void> insertNote(Note note) async {
    final Database db = await database;
    db.insert(_tableName, note.toMap());
    print('Data saved');
  }

  Future<List<Note>> getNotes() async {
    final Database db = await database;
    List<Map<String, dynamic>> results = await db.query(_tableName);

    return results.map((res) => Note.fromMap(res)).toList();
  }

  Future<Note> getNoteById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    return results.map((res) => Note.fromMap(res)).first;
  }

  Future<void> updateNote(Note note) async {
    final Database db = await database;
    db.update(
      _tableName,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(int id) async {
    final Database db = await database;
    db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
