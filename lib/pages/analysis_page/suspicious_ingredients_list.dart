import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/analysis_provider.dart';

class SuspiciousIngredientsList extends StatelessWidget {
  final List<MapEntry<String, int>> sortedEntries;

  const SuspiciousIngredientsList(this.sortedEntries, {super.key});

  @override
  Widget build(BuildContext context) {
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
                  AppLocalizations.of(context).translate("may_trigger"),
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
                    "${entry.value} ${AppLocalizations.of(context).translate("occurrences")}",
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
                              "${AppLocalizations.of(context).translate("associated_with")} ${entry.value} ${AppLocalizations.of(context).translate("pain_episodes")}.",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "${AppLocalizations.of(context).translate("correlation_score")} ${(ratio * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 16,
                                color: severityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              ratio > 0.5
                                  ? AppLocalizations.of(context).translate("highly_recommended")
                                  : ratio > 0.25
                                  ? AppLocalizations.of(context).translate("consider_reducing")
                                  : AppLocalizations.of(context).translate("low_correlation"),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context).translate("close")),
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
