import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/pages/language_settings_page.dart';
import 'package:bobobidou/pages/widgets/backup_button.dart';
import 'package:bobobidou/pages/widgets/ingredients_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../models/pain_event.dart';
import '../providers/meals_provider.dart';
import '../providers/pain_provider.dart';
import 'analysis_page/analysis_page.dart';
import 'package:intl/intl.dart';
import 'theme_settings_page.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _ingredientsController = TextEditingController();
  DateTime? _selectedMealDateTime;
  DateTime? _selectedPainDateTime;
  late TabController _tabController;
  List<String> _selectedIngredients = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(BuildContext context, {DateTime? initialDate}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
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
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
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
  Widget build(BuildContext context) {
    final mealsProvider = Provider.of<MealsProvider>(context);
    final painProvider = Provider.of<PainProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
            AppLocalizations.of(context).translate("app_title"),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),

        ),

        actions: [
          BackupButton(),
          IconButton(
            icon: Icon(
              Icons.color_lens,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: AppLocalizations.of(context).translate('theme_settings'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.language,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: AppLocalizations.of(context).translate('language'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageSettingsPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          indicatorWeight: 3,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          tabs: [
            Tab(
              icon: const Icon(Icons.restaurant),
              text: AppLocalizations.of(context).translate("meals_tab"),
            ),
            Tab(
              icon: const Icon(Icons.healing),
              text: AppLocalizations.of(context).translate("pain_tab"),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Meals Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle( AppLocalizations.of(context).translate("log_meal"),),
                const SizedBox(height: 16),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IngredientInputWidget(
                        onIngredientsChanged: (ingredients) {
                          setState(() {
                            _selectedIngredients = ingredients;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          DateTime? dt = await _pickDateTime(context, initialDate: _selectedMealDateTime ?? DateTime.now());
                          if (dt != null) {
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
                                  _selectedMealDateTime == null
                                      ?  AppLocalizations.of(context).translate("select_date")
                                      : "${ AppLocalizations.of(context).translate("date_format")}${_formatDateTime(_selectedMealDateTime!)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedMealDateTime == null ? Colors.grey[600] : Colors.black87,
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
                            if (_selectedMealDateTime != null && _selectedIngredients.isNotEmpty) {
                              Meal meal = Meal(
                                dateTime: _selectedMealDateTime!,
                                ingredients: _selectedIngredients,
                              );

                              await mealsProvider.addMeal(meal);

                              setState(() {
                                _selectedMealDateTime = null;
                                _selectedIngredients = [];
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
                _buildRecentItems(mealsProvider),
              ],
            ),
          ),

          // Pain Events Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(AppLocalizations.of(context).translate("log_pain")),
                const SizedBox(height: 16),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          DateTime? dt = await _pickDateTime(context, initialDate: _selectedPainDateTime ?? DateTime.now());
                          if (dt != null) {
                            setState(() {
                              _selectedPainDateTime = dt;
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
                                  _selectedPainDateTime == null
                                      ? AppLocalizations.of(context).translate("select_date")
                                      : "${AppLocalizations.of(context).translate("date_format")}${_formatDateTime(_selectedPainDateTime!)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedPainDateTime == null ? Colors.grey[600] : Colors.black87,
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
                            if (_selectedPainDateTime != null) {
                              PainEvent pain = PainEvent(dateTime: _selectedPainDateTime!);
                              await painProvider.addPainEvent(pain);

                              setState(() {
                                _selectedPainDateTime = null;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).translate("pain_logged")),
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
                                  content: Text(AppLocalizations.of(context).translate("select_date_time")),
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
                            AppLocalizations.of(context).translate("log_pain_episode"),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildRecentPainEvents(painProvider),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalysisPage()),
          );
        },
        child: const Icon(Icons.insights),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildRecentItems(MealsProvider mealsProvider) {
    int maxItems = 30;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppLocalizations.of(context).translate("recent_meals"),),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: mealsProvider.meals.isEmpty
              ? Center(
            child: Text(
    AppLocalizations.of(context).translate("no_meals"),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: mealsProvider.meals.length > maxItems ? maxItems : mealsProvider.meals.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final reversedIndex = mealsProvider.meals.length - 1 - index;
              if (reversedIndex < 0) return const SizedBox.shrink();

              final meal = mealsProvider.meals[reversedIndex];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Icon(Icons.restaurant, color: Theme.of(context).primaryColor),
                ),
                title: Text(
                  meal.ingredients.join(", "),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(_formatDateTime(meal.dateTime)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPainEvents(PainProvider painProvider) {
    int maxItems = 30;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppLocalizations.of(context).translate("recent_pain"),),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: painProvider.painEvents.isEmpty
              ? Center(
            child: Text(
    AppLocalizations.of(context).translate("no_pain"),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: painProvider.painEvents.length > maxItems ? maxItems : painProvider.painEvents.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final reversedIndex = painProvider.painEvents.length - 1 - index;
              if (reversedIndex < 0) return const SizedBox.shrink();

              final pain = painProvider.painEvents[reversedIndex];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent.withOpacity(0.2),
                  child: const Icon(Icons.healing, color: Colors.redAccent),
                ),
                title: Text(
                    AppLocalizations.of(context).translate("pain_episode"),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(_formatDateTime(pain.dateTime)),
              );
            },
          ),
        ),
      ],
    );
  }
}