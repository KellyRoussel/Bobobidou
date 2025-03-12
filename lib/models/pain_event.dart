class PainEvent {
  final int? id;
  final DateTime dateTime;

  PainEvent({this.id, required this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory PainEvent.fromMap(Map<String, dynamic> map) {
    return PainEvent(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}
