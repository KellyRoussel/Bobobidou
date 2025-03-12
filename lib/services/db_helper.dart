import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/meal.dart';
import '../models/pain_event.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime TEXT,
        ingredients TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE painEvents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime TEXT
      )
    ''');
  }

  Future<int> insertMeal(Meal meal) async {
    final db = await instance.database;
    return await db.insert('meals', meal.toMap());
  }

  Future<int> insertPainEvent(PainEvent painEvent) async {
    final db = await instance.database;
    return await db.insert('painEvents', painEvent.toMap());
  }

  Future<List<Meal>> getMeals() async {
    final db = await instance.database;
    final result = await db.query('meals');
    return result.map((map) => Meal.fromMap(map)).toList();
  }

  Future<List<PainEvent>> getPainEvents() async {
    final db = await instance.database;
    final result = await db.query('painEvents');
    return result.map((map) => PainEvent.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
