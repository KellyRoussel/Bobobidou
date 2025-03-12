import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../models/pain_event.dart';
import '../providers/meals_provider.dart';
import '../providers/pain_provider.dart';
import 'analysis_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _ingredientsController = TextEditingController();
  DateTime? _selectedMealDateTime;
  DateTime? _selectedPainDateTime;

  Future<DateTime?> _pickDateTime(BuildContext context, {DateTime? initialDate}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    final mealsProvider = Provider.of<MealsProvider>(context);
    final painProvider = Provider.of<PainProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Repas & Douleurs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalysisPage()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enregistrer un repas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: "Ingrédients (séparés par des virgules)",
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(_selectedMealDateTime == null
                      ? "Date/heure non définie"
                      : "Repas: ${_selectedMealDateTime!.toLocal()}"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? dt =
                    await _pickDateTime(context, initialDate: DateTime.now());
                    if (dt != null) {
                      setState(() {
                        _selectedMealDateTime = dt;
                      });
                    }
                  },
                  child: const Text("Choisir"),
                )
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedMealDateTime != null &&
                    _ingredientsController.text.trim().isNotEmpty) {
                  final ingredients = _ingredientsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .toList();
                  Meal meal = Meal(
                      dateTime: _selectedMealDateTime!,
                      ingredients: ingredients);
                  await mealsProvider.addMeal(meal);
                  _ingredientsController.clear();
                  setState(() {
                    _selectedMealDateTime = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Repas enregistré")));
                }
              },
              child: const Text("Enregistrer le repas"),
            ),
            const Divider(height: 32),
            const Text("Enregistrer un épisode de douleur",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: Text(_selectedPainDateTime == null
                      ? "Date/heure non définie"
                      : "Douleur: ${_selectedPainDateTime!.toLocal()}"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? dt =
                    await _pickDateTime(context, initialDate: DateTime.now());
                    if (dt != null) {
                      setState(() {
                        _selectedPainDateTime = dt;
                      });
                    }
                  },
                  child: const Text("Choisir"),
                )
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedPainDateTime != null) {
                  PainEvent pain =
                  PainEvent(dateTime: _selectedPainDateTime!);
                  await painProvider.addPainEvent(pain);
                  setState(() {
                    _selectedPainDateTime = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Douleur enregistrée")));
                }
              },
              child: const Text("Enregistrer la douleur"),
            ),
          ],
        ),
      ),
    );
  }
}
