import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/analysis_provider.dart';

class TimelineGraph extends StatelessWidget {
  final AnalysisProvider analysisProvider;
  late List<Map<String, dynamic>> timelineData;
  late DateTime startDate;
  final int historicalInDays=14;


  // Create data points for the chart
  List<FlSpot> mealSpots = [];
  List<FlSpot> painSpots = [];

  TimelineGraph(this.analysisProvider, {super.key}){
    // Get temporal data
    timelineData = analysisProvider.getTemporalData();

    // Get the date range
    final now = DateTime.now();
    startDate = now.subtract(Duration(days: historicalInDays));



    // Group items by day for clearer visualization
    Map<int, int> mealsByDay = {};
    Map<int, int> painByDay = {};

    // Calculate days since start date for x-axis
    for (var item in timelineData) {
      final days = item['dateTime'].difference(startDate).inDays.toDouble();

      if (item['type'] == 'meal') {
        mealsByDay[days.toInt()] = (mealsByDay[days.toInt()] ?? 0) + 1;
      } else if (item['type'] == 'pain') {
        painByDay[days.toInt()] = (painByDay[days.toInt()] ?? 0) + 1;
      }
    }

    // Convert to spots
    mealsByDay.forEach((day, count) {
      mealSpots.add(FlSpot(day.toDouble(), count.toDouble()));
    });

    painByDay.forEach((day, count) {
      painSpots.add(FlSpot(day.toDouble(), count.toDouble() * 2)); // Multiply to make pain events more visible
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // If no data, return a message
    if (timelineData.isEmpty) {
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
        child: Center(
          child: Text(
            AppLocalizations.of(context).translate("no_temporal_data"),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }
    return  Container(
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
            AppLocalizations.of(context).translate("temporal_patterns"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).translate("temporal_description"),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                      //tooltipBgColor: theme.colorScheme.surface.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final day = startDate.add(Duration(days: spot.x.toInt()));
                          final formattedDate = '${day.day}/${day.month}';

                          String text;
                          if (spot.barIndex == 0) {
                            text = '${spot.y.toInt()} ${AppLocalizations.of(context).translate("meals")} - $formattedDate';
                          } else {
                            text = '${spot.y ~/ 2} ${AppLocalizations.of(context).translate("pain_events")} - $formattedDate';
                          }

                          return LineTooltipItem(
                            text,
                            TextStyle(
                              color: spot.barIndex == 0 ? primaryColor : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      }
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        final day = startDate.add(Duration(days: value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${day.day}/${day.month}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                minX: 0,
                maxX: 14,
                minY: 0,
                maxY: mealSpots.isEmpty && painSpots.isEmpty ? 5 : null,
                lineBarsData: [
                  // Meals line
                  LineChartBarData(
                    spots: mealSpots,
                    isCurved: true,
                    color: primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryColor.withOpacity(0.1),
                    ),
                  ),
                  // Pain events line
                  LineChartBarData(
                    spots: painSpots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.red,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
