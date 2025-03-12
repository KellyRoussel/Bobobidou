import 'package:bobobidou/pages/widgets/ingredients_chips.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../models/pain_event.dart';
import '../providers/meals_provider.dart';
import '../providers/pain_provider.dart';
import 'analysis_page.dart';
import 'package:intl/intl.dart';

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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6750A4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6750A4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
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
    return DateFormat('dd MMM yyyy - HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final mealsProvider = Provider.of<MealsProvider>(context);
    final painProvider = Provider.of<PainProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6750A4),
        title: const Text(
          "Food & Pain Tracker",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
            tooltip: 'View Analysis',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalysisPage()),
              );
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.restaurant),
              text: "Meals",
            ),
            Tab(
              icon: Icon(Icons.healing),
              text: "Pain Events",
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
                _buildSectionTitle("Log a Meal"),
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
                              const Icon(Icons.calendar_today, color: Color(0xFF6750A4)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedMealDateTime == null
                                      ? "Select Date and Time"
                                      : "Date: ${_formatDateTime(_selectedMealDateTime!)}",
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
                                  content: const Text("Meal logged successfully"),
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
                                  content: const Text("Please fill in all fields"),
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
                            backgroundColor: const Color(0xFF6750A4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "SAVE MEAL",
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
                _buildSectionTitle("Log a Pain Episode"),
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
                              const Icon(Icons.calendar_today, color: Color(0xFF6750A4)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedPainDateTime == null
                                      ? "Select Date and Time"
                                      : "Date: ${_formatDateTime(_selectedPainDateTime!)}",
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
                                  content: const Text("Pain episode logged successfully"),
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
                                  content: const Text("Please select date and time"),
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
                            backgroundColor: const Color(0xFF6750A4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "LOG PAIN EPISODE",
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
        backgroundColor: const Color(0xFF6750A4),
        elevation: 2,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalysisPage()),
          );
        },
        child: const Icon(Icons.insights, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6750A4),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Recent Meals"),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
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
              ? const Center(
            child: Text(
              "No meals logged yet",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: mealsProvider.meals.length > 5 ? 5 : mealsProvider.meals.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final reversedIndex = mealsProvider.meals.length - 1 - index;
              if (reversedIndex < 0) return const SizedBox.shrink();

              final meal = mealsProvider.meals[reversedIndex];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEDE7F6),
                  child: Icon(Icons.restaurant, color: Color(0xFF6750A4)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Recent Pain Episodes"),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
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
              ? const Center(
            child: Text(
              "No pain episodes logged yet",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: painProvider.painEvents.length > 5 ? 5 : painProvider.painEvents.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final reversedIndex = painProvider.painEvents.length - 1 - index;
              if (reversedIndex < 0) return const SizedBox.shrink();

              final pain = painProvider.painEvents[reversedIndex];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFCE4EC),
                  child: Icon(Icons.healing, color: Colors.redAccent),
                ),
                title: const Text(
                  "Pain Episode",
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