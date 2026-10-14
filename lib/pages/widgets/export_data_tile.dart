import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:bobobidou/l10n/app_localizations.dart';
import '../../services/csv_export_service.dart';

/// Exports meals and pain events as a CSV file the user downloads through the
/// system "Save as" dialog (Downloads, Drive...).
/// No storage permission is needed: Google Play rejects apps requesting
/// MANAGE_EXTERNAL_STORAGE for this kind of use.
class ExportDataTile extends StatelessWidget {
  const ExportDataTile({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return ListTile(
      onTap: () => _exportData(context),
      leading: const Icon(Icons.file_download_outlined),
      title: Text(localizations.translate('export_tooltip')),
      subtitle: Text(localizations.translate('export_subtitle')),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    try {
      final saved = await CsvExportService.exportToFile(
        CsvExportLabels(
          date: localizations.translate('export_column_date'),
          time: localizations.translate('export_column_time'),
          type: localizations.translate('export_column_type'),
          ingredients: localizations.translate('export_column_ingredients'),
          meal: localizations.translate('export_type_meal'),
          pain: localizations.translate('export_type_pain'),
        ),
        dialogTitle: localizations.translate('export_dialog_title'),
      );
      if (!saved) return;

      Fluttertoast.showToast(
        msg: localizations.translate('export_success'),
        gravity: ToastGravity.BOTTOM,
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
