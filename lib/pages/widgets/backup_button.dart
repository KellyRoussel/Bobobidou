import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/db_helper.dart'; // Optional: for sharing backup file

class BackupButton extends StatelessWidget {
  const BackupButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _backupDatabase(context),
      icon: Icon(
        Icons.save_as,
        color: Theme.of(context).appBarTheme.foregroundColor,
      ),
      tooltip: "Backup DB",
    );
  }

  Future<void> _backupDatabase(BuildContext context) async {
    // Check if storage permission is granted
    if (!await _checkAndRequestPermission()) {
      Fluttertoast.showToast(
        msg: "Storage permission is required for backup",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    try {
      // Show loading indicator
      _showLoadingDialog(context);

      // Perform the backup
      final DatabaseHelper _dbHelper = DatabaseHelper.instance;
      String backupPath = await _dbHelper.backupDatabase();

      // Hide loading indicator
      Navigator.of(context).pop();

      // Show success message with path
      _showBackupSuccessDialog(context, backupPath);
    } catch (e) {
      // Hide loading indicator if showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error toast
      Fluttertoast.showToast(
        msg: "Backup failed: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<bool> _checkAndRequestPermission() async {

        final status = await Permission.storage.status;
        if (status != PermissionStatus.granted) {
          final result = await Permission.manageExternalStorage.request();
          return result == PermissionStatus.granted;
        }
        return true;


  }


  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Creating backup..."),
            ],
          ),
        );
      },
    );
  }

  void _showBackupSuccessDialog(BuildContext context, String backupPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Backup Successful"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your database has been backed up successfully. If you uninstall the app, you can find the backup at:",
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  backupPath,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please make a note of this path. You can restore from this backup after reinstalling the app.",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Also show a toast with the path
                Fluttertoast.showToast(
                  msg: "Backup saved at: $backupPath",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                );
              },
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () {
                // Share the backup file so user can save it elsewhere
                SharePlus.instance.share(ShareParams(text: backupPath));
              },
              child: const Text("SHARE"),
            ),
          ],
        );
      },
    );
  }
}