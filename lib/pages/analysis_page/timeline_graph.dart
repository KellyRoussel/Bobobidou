import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../l10n/app_localizations.dart';
import '../../providers/analysis_provider.dart';
import 'full_screen_timeline_chart.dart';

class TimelineGraph extends StatefulWidget {
  final AnalysisProvider analysisProvider;

  const TimelineGraph(this.analysisProvider, {super.key});

  @override
  State<TimelineGraph> createState() => _TimelineGraphState();
}

class _TimelineGraphState extends State<TimelineGraph> {
  late List<Map<String, dynamic>> timelineData;
  late DateTime startDate;
  late DateTime endDate;

  // Controls for the scrollable view
  final ScrollController _scrollController = ScrollController();
  bool _isFullScreen = false;

  // Number of hours to show in the default view
  final int _visibleHours = 72; // 3 days
  // Total hours to load
  final int _totalHoursToLoad = 168; // 7 days

  // Data points for the chart
  List<ChartDataPoint> mealEvents = [];
  List<ChartDataPoint> painEvents = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Make sure to restore orientation and UI mode when widget is disposed
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  void _loadData() {
    // Get temporal data
    timelineData = widget.analysisProvider.getTemporalData();

    // Get the date range
    endDate = DateTime.now();
    startDate = endDate.subtract(Duration(hours: _totalHoursToLoad));

    // Process the data points
    _processDataPoints();
  }

  void _processDataPoints() {
    mealEvents.clear();
    painEvents.clear();

    // Create events from timeline data
    for (var item in timelineData) {
      final hoursSinceStart = item['dateTime'].difference(startDate).inHours.toDouble();

      if (item['type'] == 'meal') {
        // For meals, use intensity or default to 1.0
        double intensity = (item['intensity'] ?? 1.0).toDouble();
        mealEvents.add(ChartDataPoint(
          time: item['dateTime'],
          hoursSinceStart: hoursSinceStart,
          intensity: intensity,
          details: item['details'] ?? '',
        ));
      } else if (item['type'] == 'pain') {
        // For pain, use severity or default to 1.0
        double severity = (item['severity'] ?? 1.0).toDouble();
        painEvents.add(ChartDataPoint(
          time: item['dateTime'],
          hoursSinceStart: hoursSinceStart,
          intensity: severity,
          details: item['details'] ?? '',
        ));
      }
    }
  }

  void _toggleFullScreen() async {
    // Set landscape orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Enter immersive mode
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Navigate to full screen chart page
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenChartPage(
          mealEvents: mealEvents,
          painEvents: painEvents,
          startDate: startDate,
          endDate: endDate,
        ),
      ),
    );

    // Restore after returning
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final width = MediaQuery.of(context).size.width;

    // If no data, return a message
    if (timelineData.isEmpty) {
      return _buildEmptyDataContainer(theme, context);
    }

    // Calculate width for the scrollable chart
    // Each hour takes 20 logical pixels
    final hourWidth = 20.0;
    final chartWidth = _totalHoursToLoad * hourWidth;

    return WillPopScope(
      onWillPop: () async {
        if (_isFullScreen) {
          _toggleFullScreen();
          return false;
        }
        return true;
      },
      child: _isFullScreen
          ? _buildFullScreenContent(theme, context, primaryColor, chartWidth, hourWidth)
          : _buildNormalContent(theme, context, primaryColor, chartWidth, hourWidth, width),
    );
  }

  Widget _buildEmptyDataContainer(ThemeData theme, BuildContext context) {
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

  Widget _buildNormalContent(ThemeData theme, BuildContext context, Color primaryColor,
      double chartWidth, double hourWidth, double containerWidth) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).translate("temporal_patterns"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: _toggleFullScreen,
                tooltip: AppLocalizations.of(context).translate("full_screen"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildScrollableChart(theme, primaryColor, chartWidth, hourWidth, containerWidth),
          ),
          const SizedBox(height: 16),
          _buildLegend(context, primaryColor),
        ],
      ),
    );
  }

  Widget _buildFullScreenContent(ThemeData theme, BuildContext context, Color primaryColor,
      double chartWidth, double hourWidth) {
    final fullscreenWidth = MediaQuery.of(context).size.width;
    final fullscreenHeight = MediaQuery.of(context).size.height;

    // This is the key change - use a Column with specific size constraints
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // to balance the icon
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
                  onPressed: _toggleFullScreen,
                  tooltip: AppLocalizations.of(context).translate("exit_full_screen"),
                ),
              ],
            ),

            // Chart taking the rest of the space
            Expanded(
              child: _buildScrollableChart(
                theme,
                primaryColor,
                chartWidth,
                hourWidth,
                MediaQuery.of(context).size.width,
              ),
            ),

            const SizedBox(height: 8),

            // Legend
            _buildLegend(context, primaryColor),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );


  }

  Widget _buildScrollableChart(ThemeData theme, Color primaryColor,
      double chartWidth, double hourWidth, double visibleWidth) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth,
          height: _isFullScreen ? MediaQuery.of(context).size.height - 100 : 200,
          child: Stack(
            children: [
              // Background grid
              _buildHourlyGrid(theme, chartWidth, hourWidth),

              // Chart content
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
    );
  }

  Widget _buildHourlyGrid(ThemeData theme, double chartWidth, double hourWidth) {
    return CustomPaint(
      size: Size(chartWidth, _isFullScreen ? MediaQuery.of(context).size.height - 100 : 200),
      painter: HourlyGridPainter(
        hourWidth: hourWidth,
        hoursCount: _totalHoursToLoad,
        startDate: startDate,
        gridColor: Colors.grey[300]!,
        textColor: Colors.grey[600]!,
      ),
    );
  }

  Widget _buildLegend(BuildContext context, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Meal indicator
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
        // Pain indicator
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
    );
  }
}

// Custom chart data point
class ChartDataPoint {
  final DateTime time;
  final double hoursSinceStart;
  final double intensity;
  final String details;

  ChartDataPoint({
    required this.time,
    required this.hoursSinceStart,
    required this.intensity,
    required this.details,
  });
}

// Custom painter for grid lines and time labels
class HourlyGridPainter extends CustomPainter {
  final double hourWidth;
  final int hoursCount;
  final DateTime startDate;
  final Color gridColor;
  final Color textColor;

  HourlyGridPainter({
    required this.hourWidth,
    required this.hoursCount,
    required this.startDate,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = i * (size.height / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines and time labels
    for (int hour = 0; hour <= hoursCount; hour += 6) {  // Draw every 6 hours
      final x = hour * hourWidth;

      // Draw vertical line
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

      // Draw time label
      DateTime timeAtX = startDate.add(Duration(hours: hour));
      String timeText = '${timeAtX.day}/${timeAtX.month}\n${timeAtX.hour}:00';

      textPainter.text = TextSpan(
        text: timeText,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
        ),
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - textPainter.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Custom chart for timeline events
class TimelineEventChart extends StatelessWidget {
  final double chartWidth;
  final double hourWidth;
  final List<ChartDataPoint> mealEvents;
  final List<ChartDataPoint> painEvents;
  final Color mealColor;
  final Color painColor;
  final DateTime startDate;
  final DateTime endDate;

  const TimelineEventChart({
    super.key,
    required this.chartWidth,
    required this.hourWidth,
    required this.mealEvents,
    required this.painEvents,
    required this.mealColor,
    required this.painColor,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: chartWidth,
      height: double.infinity,
      child: CustomPaint(
        painter: TimelineEventPainter(
          mealEvents: mealEvents,
          painEvents: painEvents,
          mealColor: mealColor,
          painColor: painColor,
          hourWidth: hourWidth,
        ),
        foregroundPainter: TimelineEventInteractionPainter(
          mealEvents: mealEvents,
          painEvents: painEvents,
          mealColor: mealColor,
          painColor: painColor,
          hourWidth: hourWidth,
        ),
        child: GestureDetector(
          onTapDown: (TapDownDetails details) {
            _handleTap(context, details);
          },
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, TapDownDetails details) {
    final tapPosition = details.localPosition;
    final hourAtTap = tapPosition.dx / hourWidth;
    final tappedTime = startDate.add(Duration(hours: hourAtTap.floor()));

    // Check if tap is on a meal or pain event
    ChartDataPoint? tappedEvent = _findEventAtPosition(tapPosition);

    if (tappedEvent != null) {
      _showEventDetails(context, tappedEvent);
    }
  }

  ChartDataPoint? _findEventAtPosition(Offset position) {
    final hourAtPosition = position.dx / hourWidth;
    final tapRadius = 15.0; // Tap detection radius in pixels
    final hourRadius = tapRadius / hourWidth;

    // Check meals
    for (var event in mealEvents) {
      if ((event.hoursSinceStart - hourAtPosition).abs() < hourRadius) {
        return event;
      }
    }

    // Check pain events
    for (var event in painEvents) {
      if ((event.hoursSinceStart - hourAtPosition).abs() < hourRadius) {
        return event;
      }
    }

    return null;
  }

  void _showEventDetails(BuildContext context, ChartDataPoint event) {
    final bool isMeal = mealEvents.contains(event);
    final eventType = isMeal
        ? AppLocalizations.of(context).translate("meal")
        : AppLocalizations.of(context).translate("pain_event");

    final time = '${event.time.day}/${event.time.month} ${event.time.hour}:${event.time.minute.toString().padLeft(2, '0')}';
    final intensity = event.intensity.toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(eventType),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${AppLocalizations.of(context).translate("time")}: $time'),
              Text('${AppLocalizations.of(context).translate("intensity")}: $intensity'),
              if (event.details.isNotEmpty)
                Text('${AppLocalizations.of(context).translate("details")}: ${event.details}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).translate("close")),
            ),
          ],
        );
      },
    );
  }
}

// Painter for drawing the actual events
class TimelineEventPainter extends CustomPainter {
  final List<ChartDataPoint> mealEvents;
  final List<ChartDataPoint> painEvents;
  final Color mealColor;
  final Color painColor;
  final double hourWidth;

  TimelineEventPainter({
    required this.mealEvents,
    required this.painEvents,
    required this.mealColor,
    required this.painColor,
    required this.hourWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw meal events at the bottom half
    final mealPaint = Paint()
      ..color = mealColor
      ..style = PaintingStyle.fill;

    // Draw pain events at the top half
    final painPaint = Paint()
      ..color = painColor
      ..style = PaintingStyle.fill;

    // Horizontal dividing line
    final dividerPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      dividerPaint,
    );

    // Draw meal events (bottom half)
    _drawEvents(
      canvas,
      size,
      mealEvents,
      mealPaint,
      size.height / 2,  // Start from middle
      size.height,      // End at bottom
    );

    // Draw pain events (top half)
    _drawEvents(
      canvas,
      size,
      painEvents,
      painPaint,
      0,               // Start from top
      size.height / 2, // End at middle
    );
  }

  void _drawEvents(
      Canvas canvas,
      Size size,
      List<ChartDataPoint> events,
      Paint paint,
      double startY,
      double endY,
      ) {
    final verticalRange = (endY - startY);
    final maxHeight = verticalRange * 0.8; // Maximum bar height

    // Find max intensity for scaling
    double maxIntensity = 0;
    for (var event in events) {
      if (event.intensity > maxIntensity) {
        maxIntensity = event.intensity;
      }
    }
    if (maxIntensity == 0) maxIntensity = 1.0; // Prevent division by zero

    // Draw events as bars
    for (var event in events) {
      final x = event.hoursSinceStart * hourWidth;
      final barHeight = (event.intensity / maxIntensity) * maxHeight;

      // For meals, bars go up from bottom
      // For pain, bars go down from top
      final y = (startY == 0)
          ? endY - barHeight  // Pain (top half)
          : endY - barHeight; // Meal (bottom half)

      // Draw bar
      final barWidth = hourWidth * 0.8;
      final rect = Rect.fromLTWH(
        x - barWidth / 2,
        y,
        barWidth,
        barHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3.0)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Painter for interaction effects (hover, selection)
class TimelineEventInteractionPainter extends CustomPainter {
  final List<ChartDataPoint> mealEvents;
  final List<ChartDataPoint> painEvents;
  final Color mealColor;
  final Color painColor;
  final double hourWidth;

  TimelineEventInteractionPainter({
    required this.mealEvents,
    required this.painEvents,
    required this.mealColor,
    required this.painColor,
    required this.hourWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Highlight the meal-pain connections
    if (mealEvents.isNotEmpty && painEvents.isNotEmpty) {
      _drawPainMealCorrelations(canvas, size);
    }
  }

  void _drawPainMealCorrelations(Canvas canvas, Size size) {
    // For each pain event, find the closest meal before it
    for (var painEvent in painEvents) {
      ChartDataPoint? closestMeal;
      double smallestTimeGap = double.infinity;

      for (var meal in mealEvents) {
        // Only consider meals that happened before the pain
        if (meal.time.isBefore(painEvent.time)) {
          final timeGap = painEvent.time.difference(meal.time).inMinutes / 60.0;
          if (timeGap < smallestTimeGap) {
            smallestTimeGap = timeGap;
            closestMeal = meal;
          }
        }
      }

      // If we found a meal that happened before the pain (within 6 hours), draw the connection
      if (closestMeal != null && smallestTimeGap <= 6.0) {
        final paint = Paint()
          ..color = Colors.orange.withOpacity(0.3)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

        final mealX = closestMeal.hoursSinceStart * hourWidth;
        final painX = painEvent.hoursSinceStart * hourWidth;

        // Draw connecting line
        final path = Path();
        path.moveTo(mealX, size.height * 0.75); // From meal (bottom half)

        // Control points for curve
        final controlX1 = mealX + (painX - mealX) * 0.2;
        final controlY1 = size.height * 0.6;
        final controlX2 = mealX + (painX - mealX) * 0.8;
        final controlY2 = size.height * 0.4;

        path.cubicTo(
          controlX1, controlY1,
          controlX2, controlY2,
          painX, size.height * 0.25, // To pain (top half)
        );

        canvas.drawPath(path, paint);

        // Draw time difference
        final hours = (smallestTimeGap).floor();
        final minutes = ((smallestTimeGap - hours) * 60).round();
        final timeText = '${hours}h ${minutes}m';

        final textPainter = TextPainter(
          text: TextSpan(
            text: timeText,
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            mealX + (painX - mealX) / 2 - textPainter.width / 2,
            size.height * 0.5 - textPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}