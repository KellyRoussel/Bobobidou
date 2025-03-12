import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  bool _isLoading = true;
  String _filterQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analysisProvider =
      Provider.of<AnalysisProvider>(context, listen: false);
      analysisProvider.loadAnalysis().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          "Ingredient Analysis",
          style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            tooltip: 'Refresh Data',
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              final analysisProvider =
              Provider.of<AnalysisProvider>(context, listen: false);
              await analysisProvider.loadAnalysis();
              setState(() {
                _isLoading = false;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : Consumer<AnalysisProvider>(
        builder: (context, analysisProvider, child) {
          final involvement = analysisProvider.ingredientInvolvement;

          if (involvement.isEmpty) {
            return _buildEmptyState(context);
          }

          List<MapEntry<String, int>> sortedEntries = involvement.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          if (_filterQuery.isNotEmpty) {
            sortedEntries = sortedEntries
                .where((entry) => entry.key
                .toLowerCase()
                .contains(_filterQuery.toLowerCase()))
                .toList();
          }

          return Column(
            children: [
              _buildHeaderStats(context, sortedEntries),
              _buildSearchBar(context),
              Expanded(
                child: sortedEntries.isEmpty && _filterQuery.isNotEmpty
                    ? Center(
                  child: Text(
                    'No ingredients match "$_filterQuery"',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : _buildIngredientsList(context, sortedEntries),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No Data Available",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Start logging your meals and pain episodes to see analysis results here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add),
              label: const Text("LOG DATA"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStats(BuildContext context, List<MapEntry<String, int>> sortedEntries) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Get top 5 ingredients for chart
    final topIngredients = sortedEntries.take(5).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pain Correlation Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          topIngredients.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: topIngredients.first.value.toDouble() * 1.2,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= topIngredients.length || value < 0) {
                          return const SizedBox.shrink();
                        }
                        // Truncate long names
                        String name = topIngredients[value.toInt()].key;
                        if (name.length > 10) {
                          name = '${name.substring(0, 8)}...';
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[200],
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                barGroups: List.generate(
                  topIngredients.length,
                      (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: topIngredients[index].value.toDouble(),
                        color: primaryColor.withOpacity(0.7 - (index * 0.1)),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "These ingredients appear most frequently before pain episodes.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _filterQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Search ingredients...",
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: _filterQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _filterQuery = '';
              });
            },
          )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsList(BuildContext context, List<MapEntry<String, int>> sortedEntries) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            final analysisProvider =
            Provider.of<AnalysisProvider>(context, listen: false);
            await analysisProvider.loadAnalysis();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(0),
            itemCount: sortedEntries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];

              // Calculate severity level
              final maxValue = sortedEntries.first.value.toDouble();
              final ratio = entry.value / maxValue;

              Color severityColor;
              if (ratio > 0.75) {
                severityColor = Colors.red[400]!;
              } else if (ratio > 0.5) {
                severityColor = Colors.orange[400]!;
              } else if (ratio > 0.25) {
                severityColor = Colors.amber[400]!;
              } else {
                severityColor = Colors.green[400]!;
              }

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: severityColor.withOpacity(0.2),
                  child: Icon(
                    Icons.food_bank,
                    color: severityColor,
                  ),
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "May trigger pain episodes",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: severityColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    "${entry.value} occurrences",
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  // Could show a detailed view of this ingredient's data
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(entry.key),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "This ingredient has been associated with ${entry.value} pain episodes.",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Correlation score: ${(ratio * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 16,
                                color: severityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              ratio > 0.5
                                  ? "It's highly recommended to avoid this ingredient to reduce pain episodes."
                                  : ratio > 0.25
                                  ? "Consider reducing consumption of this ingredient."
                                  : "This ingredient has a low correlation with pain episodes.",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("CLOSE"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}