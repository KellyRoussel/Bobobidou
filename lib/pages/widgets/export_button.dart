import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bobobidou/l10n/app_localizations.dart';
import '../../services/csv_export_service.dart';

/// Exports meals and pain events as a CSV file and opens the share sheet so
/// the user can save or send it (Drive, Files, e-mail...).
/// No storage permission is needed: Google Play rejects apps requesting
/// MANAGE_EXTERNAL_STORAGE for this kind of use.
class ExportButton extends StatelessWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return IconButton(
      onPressed: () => _exportData(context),
      icon: Icon(
        Icons.file_download,
        color: Theme.of(context).appBarTheme.foregroundColor,
      ),
      tooltip: localizations.translate('export_tooltip'),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    try {
      final exportPath = await CsvExportService.exportToFile(
        CsvExportLabels(
          date: localizations.translate('export_column_date'),
          time: localizations.translate('export_column_time'),
          type: localizations.translate('export_column_type'),
          ingredients: localizations.translate('export_column_ingredients'),
          meal: localizations.translate('export_type_meal'),
          pain: localizations.translate('export_type_pain'),
        ),
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(exportPath, mimeType: 'text/csv')],
          subject: localizations.translate('export_share_subject'),
        ),
      );
    } catch (e) {
      debugPrint('Export failed: $e');
      Fluttertoast.showToast(
        msg: localizations.translate('export_failed'),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
