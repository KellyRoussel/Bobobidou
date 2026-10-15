import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/ingredient.dart';
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
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }

  // Initial database creation
  Future _createDB(Database db, int version) async {
    // Create meals table (now without ingredients field)
    await db.execute('''
      CREATE TABLE meals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime TEXT
      )
    ''');

    // Create pain events table
    await db.execute('''
      CREATE TABLE painEvents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime TEXT
      )
    ''');

    // Create ingredients table
    await db.execute('''
      CREATE TABLE ingredients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE
      )
    ''');

    // Create junction table for many-to-many relationship
    await db.execute('''
      CREATE TABLE meal_ingredients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_id INTEGER,
        ingredient_id INTEGER,
        FOREIGN KEY (meal_id) REFERENCES meals (id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
      )
    ''');
  }

  // Insert a meal with its ingredients
  Future<int> insertMeal(Meal meal) async {
    final db = await instance.database;

    // Start a transaction
    return await db.transaction((txn) async {
      // 1. Insert the meal
      final mealId = await txn.insert('meals', {
        'dateTime': meal.dateTime.toIso8601String(),
      });

      // 2. Insert or get IDs for each ingredient
      for (var ingredientName in meal.ingredients) {
        String trimmedName = ingredientName.trim();
        if (trimmedName.isEmpty) continue;

        // Try to insert the ingredient (will be ignored if it already exists)
        await txn.execute(
            'INSERT OR IGNORE INTO ingredients (name) VALUES (?)',
            [trimmedName]
        );

        // Get the ingredient ID
        final List<Map<String, dynamic>> ingredientMaps = await txn.query(
            'ingredients',
            where: 'name = ?',
            whereArgs: [trimmedName],
            limit: 1
        );

        if (ingredientMaps.isNotEmpty) {
          int ingredientId = ingredientMaps.first['id'] as int;

          // 3. Create relationship in junction table
          await txn.insert('meal_ingredients', {
            'meal_id': mealId,
            'ingredient_id': ingredientId
          });
        }
      }

      return mealId;
    });
  }

  Future<int> insertPainEvent(PainEvent painEvent) async {
    final db = await instance.database;
    return await db.insert('painEvents', painEvent.toMap());
  }

  Future<List<Meal>> getMeals() async {
    final db = await instance.database;

    // Get all meals
    final List<Map<String, dynamic>> mealMaps = await db.query('meals');

    // Convert each meal map to a Meal object with its ingredients
    List<Meal> meals = [];

    for (var mealMap in mealMaps) {
      int mealId = mealMap['id'] as int;

      // Get ingredients for this meal using the junction table
      final List<Map<String, dynamic>> ingredientMaps = await db.rawQuery('''
        SELECT i.name 
        FROM ingredients i
        JOIN meal_ingredients mi ON i.id = mi.ingredient_id
        WHERE mi.meal_id = ?
      ''', [mealId]);

      List<String> ingredients = ingredientMaps.map((map) => map['name'] as String).toList();

      meals.add(Meal(
        id: mealId,
        dateTime: DateTime.parse(mealMap['dateTime']),
        ingredients: ingredients,
      ));
    }

    return meals;
  }

  Future<List<PainEvent>> getPainEvents() async {
    final db = await instance.database;
    final result = await db.query('painEvents');
    return result.map((map) => PainEvent.fromMap(map)).toList();
  }

  Future<List<String>> getAllIngredients() async {
    final db = await instance.database;

    // Get all ingredients directly from the ingredients table
    final List<Map<String, dynamic>> ingredientMaps = await db.query('ingredients');

    // Convert maps to string list and sort
    List<String> allIngredients = ingredientMaps
        .map((map) => map['name'] as String)
        .toList()
      ..sort();

    return allIngredients;
  }

  Future<List<Ingredient>> getAllIngredientsWithIds() async {
    final db = await instance.database;

    // Get all ingredients with their IDs
    final List<Map<String, dynamic>> ingredientMaps = await db.query('ingredients');

    // Convert maps to Ingredient objects
    return ingredientMaps.map((map) => Ingredient(
      id: map['id'] as int,
      name: map['name'] as String,
    )).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

