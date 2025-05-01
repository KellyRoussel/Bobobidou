import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/pain_event.dart';
import '../services/db_helper.dart';

class AnalysisProvider with ChangeNotifier {
  Map<String, int> _ingredientInvolvement = {};
  Map<String, int> get ingredientInvolvement => _ingredientInvolvement;

  // Add these properties for the temporal graph
  List<Meal> _meals = [];
  List<PainEvent> _painEvents = [];

  List<Meal> get meals => _meals;
  List<PainEvent> get painEvents => _painEvents;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> loadAnalysis() async {
    _meals = await _dbHelper.getMeals();
    _painEvents = await _dbHelper.getPainEvents();

    Map<String, int> involvement = {};

    for (var pain in _painEvents) {
      final windowStart = pain.dateTime.subtract(const Duration(hours: 48));
      final relevantMeals = _meals.where((meal) =>
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

  // Helper method to get data for the time pattern analysis
  List<Map<String, dynamic>> getTemporalData({int daysToShow = 14}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysToShow));

    List<Map<String, dynamic>> timelineData = [];

    // Add meals to timeline
    for (var meal in _meals) {
      if (meal.dateTime.isAfter(startDate)) {
        timelineData.add({
          'dateTime': meal.dateTime,
          'type': 'meal',
          'data': meal,
        });
      }
    }

    // Add pain events to timeline
    for (var pain in _painEvents) {
      if (pain.dateTime.isAfter(startDate)) {
        timelineData.add({
          'dateTime': pain.dateTime,
          'type': 'pain',
          'data': pain,
        });
      }
    }

    // Sort by date
    timelineData.sort((a, b) => a['dateTime'].compareTo(b['dateTime']));

    return timelineData;
  }
}