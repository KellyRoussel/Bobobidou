class Ingredient {
  final int? id;
  final String name;

  Ingredient({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  static Ingredient fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      name: map['name'],
    );
  }

  @override
  String toString() {
    return 'Ingredient{id: $id, name: $name}';
  }
}