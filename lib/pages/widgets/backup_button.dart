import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bobobidou/l10n/app_localizations.dart';
import '../../services/db_helper.dart';

/// Exports the database and opens the share sheet so the user can save the
/// backup outside of the app (Drive, Files, e-mail...).
/// No storage permission is needed: Google Play rejects apps requesting
/// MANAGE_EXTERNAL_STORAGE for this kind of use.
class BackupButton extends StatelessWidget {
  const BackupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return IconButton(
      onPressed: () => _backupDatabase(context),
      icon: Icon(
        Icons.save_as,
        color: Theme.of(context).appBarTheme.foregroundColor,
      ),
      tooltip: localizations.translate('backup_tooltip'),
    );
  }

  Future<void> _backupDatabase(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    try {
      final backupPath = await DatabaseHelper.instance.backupDatabase();

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(backupPath)],
          subject: localizations.translate('backup_share_subject'),
        ),
      );
    } catch (e) {
      debugPrint('Backup failed: $e');
      Fluttertoast.showToast(
        msg: localizations.translate('backup_failed'),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
