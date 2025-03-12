import 'package:flutter/foundation.dart';

class Meal {
  final int? id;
  final DateTime dateTime;
  final List<String> ingredients;

  Meal({this.id, required this.dateTime, required this.ingredients});

  // Conversion en Map pour le stockage en base de données.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'ingredients': ingredients.join(','),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      ingredients: (map['ingredients'] as String).split(','),
    );
  }
}
