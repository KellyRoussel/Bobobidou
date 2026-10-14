import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/bobo_tokens.dart';
import '../widgets/bobo_card.dart';
import 'severity.dart';

/// Bar chart of the 5 ingredients most often eaten before a pain episode.
class SuspiciousIngredientsGraph extends StatelessWidget {
  final List<MapEntry<String, int>> topIngredients;

  SuspiciousIngredientsGraph(List<MapEntry<String, int>> sortedEntries, {super.key})
      : topIngredients = sortedEntries.take(5).toList();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final axisStyle = textTheme.bodySmall!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BoboSpace.page, vertical: BoboSpace.sm),
      child: BoboCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.translate("pain_correlation"), style: textTheme.titleLarge),
            const SizedBox(height: BoboSpace.xs),
            Text(localizations.translate("ingredients_appear"), style: textTheme.bodyMedium),
            const SizedBox(height: BoboSpace.xl),
            topIngredients.isEmpty
                ? Text(localizations.translate("no_correlation_yet"), style: textTheme.bodyLarge)
                : SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: topIngredients.first.value.toDouble() * 1.2,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: _interval(),
                              getTitlesWidget: (value, meta) =>
                                  Text(value.toInt().toString(), style: axisStyle),
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                if (value >= topIngredients.length || value < 0) {
                                  return const SizedBox.shrink();
                                }
                                // Truncate long names
                                String name = topIngredients[value.toInt()].key;
                                if (name.length > 10) {
                                  name = '${name.substring(0, 8)}…';
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: BoboSpace.sm),
                                  child: Text(name, style: axisStyle.copyWith(color: BoboColors.cacao)),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          horizontalInterval: _interval(),
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: BoboColors.ligne,
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
                                color: Severity.of(
                                  topIngredients[index].value / topIngredients.first.value,
                                ).fill,
                                width: 24,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(BoboRadius.sm / 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  /// Keeps around 4 grid lines whatever the counts.
  double _interval() {
    final max = topIngredients.isEmpty ? 1 : topIngredients.first.value;
    return (max / 4).ceilToDouble().clamp(1, double.infinity);
  }
}
