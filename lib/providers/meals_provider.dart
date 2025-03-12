import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/db_helper.dart';

class MealsProvider with ChangeNotifier {
  List<Meal> _meals = [];
  List<Meal> get meals => _meals;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  MealsProvider() {
    loadMeals();
  }

  Future<void> loadMeals() async {
    _meals = await _dbHelper.getMeals();
    notifyListeners();
  }

  Future<void> addMeal(Meal meal) async {
    await _dbHelper.insertMeal(meal);
    await loadMeals();
  }
}
