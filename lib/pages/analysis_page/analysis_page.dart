import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/pages/analysis_page/suspicious_ingredients_graph.dart';
import 'package:bobobidou/pages/analysis_page/suspicious_ingredients_list.dart';
import 'package:bobobidou/pages/analysis_page/timeline_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analysis_provider.dart';
import '../../theme/bobo_tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';

class AnalysisPage extends StatefulWidget {
  /// Called by the empty state's button, to go back to the journal.
  final VoidCallback? onStartLogging;

  const AnalysisPage({this.onStartLogging, super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await context.read<AnalysisProvider>().loadAnalysis();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final header = PageHeader(
      title: localizations.translate("analysis_title"),
      subtitle: localizations.translate("analysis_subtitle"),
      trailing: IconButton(
        icon: const Icon(Icons.refresh_rounded),
        tooltip: localizations.translate("refresh_data"),
        onPressed: () {
          setState(() => _isLoading = true);
          _reload();
        },
      ),
    );

    return SafeArea(
      bottom: false,
      child: _isLoading
          ? Column(
              children: [
                header,
                const Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            )
          : Consumer<AnalysisProvider>(
              builder: (context, analysisProvider, child) {
                if (analysisProvider.meals.isEmpty && analysisProvider.painEvents.isEmpty) {
                  return ListView(
                    children: [header, _buildEmptyState(context)],
                  );
                }

                final allEntries = analysisProvider.ingredientInvolvement.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final filteredEntries = _filterQuery.isEmpty
                    ? allEntries
                    : allEntries
                        .where((entry) =>
                            entry.key.toLowerCase().contains(_filterQuery.toLowerCase()))
                        .toList();

                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(bottom: BoboSpace.xxxl),
                    children: [
                      header,
                      SuspiciousIngredientsGraph(allEntries),
                      TimelineGraph(analysisProvider),
                      if (allEntries.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            BoboSpace.page,
                            BoboSpace.xl,
                            BoboSpace.page,
                            0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SectionHeader(localizations.translate("all_ingredients")),
                              _buildSearchBar(context),
                              const SizedBox(height: BoboSpace.md),
                              filteredEntries.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(BoboSpace.xl),
                                      child: Text(
                                        '${localizations.translate("no_ingredients_match")} "$_filterQuery"',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    )
                                  : SuspiciousIngredientsList(
                                      filteredEntries,
                                      maxValue: allEntries.first.value,
                                    ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          BoboSpace.page + BoboSpace.xs,
                          BoboSpace.xl,
                          BoboSpace.page,
                          0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 18, color: BoboColors.cacaoDoux),
                            const SizedBox(width: BoboSpace.sm),
                            Expanded(
                              child: Text(
                                localizations.translate("analysis_disclaimer"),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return EmptyState(
      title: localizations.translate("no_data"),
      message: localizations.translate("start_logging"),
      action: widget.onStartLogging == null
          ? null
          : FilledButton.icon(
              onPressed: widget.onStartLogging,
              icon: const Icon(Icons.add_rounded),
              label: Text(localizations.translate("log_data")),
            ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _filterQuery = value),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate("search_ingredients"),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _filterQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _filterQuery = '');
                },
              )
            : null,
      ),
    );
  }
}
