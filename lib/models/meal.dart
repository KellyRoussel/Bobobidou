import 'package:flutter/foundation.dart';

class OldMeal {
  final int? id;
  final DateTime dateTime;
  final List<String> ingredients;

  OldMeal({this.id, required this.dateTime, required this.ingredients});

  // Conversion en Map pour le stockage en base de données.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'ingredients': ingredients.join(','),
    };
  }

  factory OldMeal.fromMap(Map<String, dynamic> map) {
    return OldMeal(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      ingredients: (map['ingredients'] as String).split(','),
    );
  }
}

// Helper class for migration
class Meal {
  final int? id;
  final DateTime dateTime;
  final List<String> ingredients;

  Meal({
    this.id,
    required this.dateTime,
    required this.ingredients,
  });
}