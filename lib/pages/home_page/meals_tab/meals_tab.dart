import 'package:bobobidou/pages/home_page/meals_tab/recent_meals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/meal.dart';
import '../../../providers/meals_provider.dart';
import '../../widgets/ingredients_input.dart';
import '../section_card.dart';
import '../section_title.dart';

class MealsTab extends StatefulWidget {
  const MealsTab({super.key});

  @override
  State<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends State<MealsTab> {

  late DateTime _selectedMealDateTime;
  List<String> _selectedIngredients = [];
  // Incremented after a meal is saved to rebuild the ingredient input empty
  int _ingredientInputVersion = 0;

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedMealDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
  String _formatDateTime(DateTime dateTime) {
    final locale = AppLocalizations.of(context).locale.languageCode;
    return DateFormat('dd MMM yyyy - HH:mm', locale).format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _selectedMealDateTime = DateTime.now();
  }


  @override
  Widget build(BuildContext context) {
    final mealsProvider = Provider.of<MealsProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle( AppLocalizations.of(context).translate("log_meal"),),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IngredientInputWidget(
                  key: ValueKey(_ingredientInputVersion),
                  onIngredientsChanged: (ingredients) {
                    setState(() {
                      _selectedIngredients = ingredients;
                    });
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    DateTime? dt = await _pickDateTime(context);
                     if(dt != null) {
                       setState(() {
                         _selectedMealDateTime = dt;
                       });
                     }

                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "${ AppLocalizations.of(context).translate("date_format")}${_formatDateTime(_selectedMealDateTime!)}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_selectedIngredients.isNotEmpty) {
                        Meal meal = Meal(
                          dateTime: _selectedMealDateTime,
                          ingredients: List.of(_selectedIngredients),
                        );

                        await mealsProvider.addMeal(meal);

                        setState(() {
                          _selectedMealDateTime = DateTime.now();
                          _selectedIngredients = [];
                          _ingredientInputVersion++;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).translate("meal_logged")),
                            backgroundColor: Colors.green[700],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).translate("fill_all_fields")),
                            backgroundColor: Colors.red[700],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context).translate("save_meal"),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RecentMealsList(mealsProvider),
        ],
      ),
    );
  }
}
