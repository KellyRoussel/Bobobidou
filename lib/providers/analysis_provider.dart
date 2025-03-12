import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/pain_event.dart';
import '../services/db_helper.dart';

class AnalysisProvider with ChangeNotifier {
  Map<String, int> _ingredientInvolvement = {};
  Map<String, int> get ingredientInvolvement => _ingredientInvolvement;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> loadAnalysis() async {
    List<Meal> meals = await _dbHelper.getMeals();
    List<PainEvent> painEvents = await _dbHelper.getPainEvents();

    Map<String, int> involvement = {};

    for (var pain in painEvents) {
      final windowStart = pain.dateTime.subtract(const Duration(hours: 48));
      final relevantMeals = meals.where((meal) =>
      meal.dateTime.isAfter(windowStart) &&
          meal.dateTime.isBefore(pain.dateTime));
      for (var meal in relevantMeals) {
        for (var ingredient in meal.ingredients) {
          final ing = ingredient.trim();
          if (ing.isEmpty) continue;
          involvement[ing] = (involvement[ing] ?? 0) + 1;
        }
      }
    }

    _ingredientInvolvement = involvement;
    notifyListeners();
  }
}
