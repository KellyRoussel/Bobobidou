import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/pages/analysis_page/suspicious_ingredients_graph.dart';
import 'package:bobobidou/pages/analysis_page/suspicious_ingredients_list.dart';
import 'package:bobobidou/pages/analysis_page/timeline_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analysis_provider.dart';

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
            AppLocalizations.of(context).translate("analysis_title"),
          style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            tooltip:  AppLocalizations.of(context).translate("refresh_data"),
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
      // Add resizeToAvoidBottomInset to prevent the keyboard from causing overflow
      resizeToAvoidBottomInset: true,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : Consumer<AnalysisProvider>(
        builder: (context, analysisProvider, child) {
          final involvement = analysisProvider.ingredientInvolvement;

          if (analysisProvider.meals.isEmpty && analysisProvider.painEvents.isEmpty) {
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

          // Wrap everything in a SingleChildScrollView
          return SingleChildScrollView(
            // Set physics to allow scrolling when keyboard appears
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                SuspiciousIngredientsGraph(sortedEntries),
                TimelineGraph(analysisProvider),
                if (analysisProvider.ingredientInvolvement.isNotEmpty) _buildSearchBar(context),
                // Use a fixed height container for the list to prevent infinite height issues
                if (analysisProvider.ingredientInvolvement.isNotEmpty) Container(
                  height: MediaQuery.of(context).size.height - 300, // Adjust this value as needed
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: sortedEntries.isEmpty && _filterQuery.isNotEmpty
                      ? Center(
                    child: Text(
                      '${AppLocalizations.of(context).translate("no_ingredients_match")} "$_filterQuery"',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : SuspiciousIngredientsList(sortedEntries),
                ),
              ],
            ),
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
              AppLocalizations.of(context).translate("no_data"),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).translate("start_logging"),
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
              label: Text( AppLocalizations.of(context).translate("log_data")),
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
          hintText: AppLocalizations.of(context).translate("search_ingredients"),
          hintStyle: TextStyle(color: Colors.grey[600]),
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



}