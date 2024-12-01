import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'your_database.db');

    // Delete the existing database
    await deleteDatabase(path);

    // Create a new database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT,
        password TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT,
        description TEXT,
        dueDateTime TEXT,
        category TEXT,
        done INTEGER DEFAULT 0,
        type TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    Database db = await database;
    return await db.query('users');
  }

  Future<int> insertItem(Map<String, dynamic> item) async {
    Database db = await database;
    return await db.insert('items', item);
  }

  Future<List<Map<String, dynamic>>> getItems(int userId) async {
    Database db = await database;
    return await db.query('items', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<int> updateItem(Map<String, dynamic> item) async {
    Database db = await database;
    int id = item['id'];
    return await db.update('items', item, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteItem(int id) async {
    Database db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}
