import 'package:flutter/material.dart';
import '../models/pain_event.dart';
import '../services/db_helper.dart';

class PainProvider with ChangeNotifier {
  List<PainEvent> _painEvents = [];
  List<PainEvent> get painEvents => _painEvents;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  PainProvider() {
    loadPainEvents();
  }

  Future<void> loadPainEvents() async {
    _painEvents = await _dbHelper.getPainEvents();
    notifyListeners();
  }

  Future<void> addPainEvent(PainEvent event) async {
    await _dbHelper.insertPainEvent(event);
    await loadPainEvents();
  }
}
