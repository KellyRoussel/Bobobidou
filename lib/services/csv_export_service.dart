import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
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

    final buffer = StringBuffer()
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

  /// Opens the system "Save as" dialog so the user downloads the CSV where
  /// they want (Downloads, Drive...). No storage permission is needed: the
  /// system file picker grants access to the chosen location only.
  /// Returns false if the user cancelled the dialog.
  static Future<bool> exportToFile(
    CsvExportLabels labels, {
    required String dialogTitle,
  }) async {
    final meals = await DatabaseHelper.instance.getMeals();
    final painEvents = await DatabaseHelper.instance.getPainEvents();
    final csv = buildCsv(meals, painEvents, labels);

    final timestamp = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
    final savedUri = await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: 'bobobidou_export_$timestamp.csv',
      mimeType: 'text/csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: encodeWindows1252(csv),
    );
    return savedUri != null;
  }

  /// Encodes [text] in Windows-1252 rather than UTF-8: Google Sheets on
  /// Android ignores the UTF-8 BOM and reads CSV files as Windows-1252, which
  /// is also Excel's default for French locales. It covers every French
  /// character (é, è, à, ç, œ...); characters outside of it become '?'.
  static Uint8List encodeWindows1252(String text) {
    final bytes = <int>[];
    for (final rune in text.runes) {
      if (rune < 0x80 || (rune >= 0xA0 && rune <= 0xFF)) {
        bytes.add(rune);
      } else {
        bytes.add(_windows1252Extras[rune] ?? 0x3F);
      }
    }
    return Uint8List.fromList(bytes);
  }

  // Characters Windows-1252 places in the 0x80-0x9F range (unused by Latin-1).
  static const Map<int, int> _windows1252Extras = {
    0x20AC: 0x80, // €
    0x201A: 0x82, // ‚
    0x0192: 0x83, // ƒ
    0x201E: 0x84, // „
    0x2026: 0x85, // …
    0x2020: 0x86, // †
    0x2021: 0x87, // ‡
    0x02C6: 0x88, // ˆ
    0x2030: 0x89, // ‰
    0x0160: 0x8A, // Š
    0x2039: 0x8B, // ‹
    0x0152: 0x8C, // Œ
    0x017D: 0x8E, // Ž
    0x2018: 0x91, // ‘
    0x2019: 0x92, // ’
    0x201C: 0x93, // “
    0x201D: 0x94, // ”
    0x2022: 0x95, // •
    0x2013: 0x96, // –
    0x2014: 0x97, // —
    0x02DC: 0x98, // ˜
    0x2122: 0x99, // ™
    0x0161: 0x9A, // š
    0x203A: 0x9B, // ›
    0x0153: 0x9C, // œ
    0x017E: 0x9E, // ž
    0x0178: 0x9F, // Ÿ
  };

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
