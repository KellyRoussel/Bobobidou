/// A meal and the names of its ingredients (stored in the
/// `meal_ingredients` junction table).
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