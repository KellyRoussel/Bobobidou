import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/meal.dart';
import '../models/pain_event.dart';
import 'db_helper.dart';

/// Localized texts used in the exported CSV.
class CsvExportLabels {
  final String date;
  final String time;
  final String type;
  final String ingredients;
  final String meal;
  final String pain;

  const CsvExportLabels({
    required this.date,
    required this.time,
    required this.type,
    required this.ingredients,
    required this.meal,
    required this.pain,
  });
}

/// Exports meals and pain events as a single chronological CSV timeline,
/// readable in Excel, Google Sheets or Numbers.
class CsvExportService {
  // ';' instead of ',' so that Excel with a French locale splits the columns.
  static const String separator = ';';
  // UTF-8 BOM so that Excel displays accents correctly.
  static const String _bom = '﻿';

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// Builds the CSV content, sorted chronologically (oldest first).
  static String buildCsv(
    List<Meal> meals,
    List<PainEvent> painEvents,
    CsvExportLabels labels,
  ) {
    final rows = <_Row>[
      for (final meal in meals)
        _Row(meal.dateTime, labels.meal, meal.ingredients.join(', ')),
      for (final pain in painEvents) _Row(pain.dateTime, labels.pain, ''),
    ]..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final buffer = StringBuffer(_bom)
      ..write(_line([labels.date, labels.time, labels.type, labels.ingredients]));
    for (final row in rows) {
      buffer.write(_line([
        _dateFormat.format(row.dateTime),
        _timeFormat.format(row.dateTime),
        row.type,
        row.ingredients,
      ]));
    }
    return buffer.toString();
  }

  /// Writes the CSV to the app's temporary folder (no storage permission
  /// needed) and returns its path, ready to be handed to the share sheet.
  static Future<String> exportToFile(CsvExportLabels labels) async {
    final meals = await DatabaseHelper.instance.getMeals();
    final painEvents = await DatabaseHelper.instance.getPainEvents();
    final csv = buildCsv(meals, painEvents, labels);

    final directory = await getTemporaryDirectory();
    final exportDir = Directory('${directory.path}/bobobidou_exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
    final file = File('${exportDir.path}/bobobidou_export_$timestamp.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  static String _line(List<String> fields) =>
      '${fields.map(_escape).join(separator)}\r\n';

  // RFC 4180: quote fields containing the separator, quotes or line breaks.
  static String _escape(String field) {
    if (field.contains(separator) ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}

class _Row {
  final DateTime dateTime;
  final String type;
  final String ingredients;

  _Row(this.dateTime, this.type, this.ingredients);
}
