import 'package:bobobidou/pages/analysis_page/timeline_graph.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class FullScreenChartPage extends StatelessWidget {
  final List<ChartDataPoint> mealEvents;
  final List<ChartDataPoint> painEvents;
  final DateTime startDate;
  final DateTime endDate;

  const FullScreenChartPage({
    super.key,
    required this.mealEvents,
    required this.painEvents,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final hourWidth = 20.0;
    final totalHours = 168;
    final chartWidth = totalHours * hourWidth;

    final ScrollController _scrollController = ScrollController();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Text(
                  AppLocalizations.of(context).translate("temporal_patterns"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppLocalizations.of(context).translate("exit_full_screen"),
                ),
              ],
            ),

            // Chart
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    height: MediaQuery.of(context).size.height - 100,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(chartWidth, MediaQuery.of(context).size.height - 100),
                          painter: HourlyGridPainter(
                            hourWidth: hourWidth,
                            hoursCount: totalHours,
                            startDate: startDate,
                            gridColor: Colors.grey[300]!,
                            textColor: Colors.grey[600]!,
                          ),
                        ),
                        TimelineEventChart(
                          chartWidth: chartWidth,
                          hourWidth: hourWidth,
                          mealEvents: mealEvents,
                          painEvents: painEvents,
                          mealColor: primaryColor,
                          painColor: Colors.red,
                          startDate: startDate,
                          endDate: endDate,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Legend
            const SizedBox(height: 8),
            _buildLegend(context, primaryColor),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).translate("meals"),
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).translate("pain_events"),
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    );
  }
}
