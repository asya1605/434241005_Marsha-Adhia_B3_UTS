import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tickets.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> resetDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'tickets.db');

  await deleteDatabase(path);
  }

  Future _createDB(Database db, int version) async {

    // USERS
    await db.execute('''
CREATE TABLE users(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  email TEXT UNIQUE,
  password TEXT,
  role TEXT DEFAULT 'user',
  created_at TEXT
)
''');

    // TICKETS
    await db.execute('''
CREATE TABLE tickets(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  description TEXT,
  status TEXT,
  user_id INTEGER,
  assigned_to INTEGER,
  image TEXT,
  created_at TEXT
)
''');

    // COMMENTS
    await db.execute('''
CREATE TABLE comments(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ticket_id INTEGER,
  user_id INTEGER,
  message TEXT,
  created_at TEXT
)
''');

    // NOTIFICATIONS
    await db.execute('''
CREATE TABLE notifications(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  title TEXT,
  message TEXT,
  is_read INTEGER,
  created_at TEXT
)
''');
  }

}