import 'package:bobobidou/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<AppTheme>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose App Theme',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Purple Theme
            _buildThemeOption(
              context: context,
              title: 'Purple Theme',
              color: const Color(0xFF6750A4),
              onTap: () {
                appTheme.setTheme(AppTheme.lightPurpleTheme);
              },
              isSelected: appTheme.currentTheme.primaryColor == const Color(0xFF6750A4),
            ),

            const SizedBox(height: 12),

            // Green Theme
            _buildThemeOption(
              context: context,
              title: 'Green Theme',
              color: Colors.green[700]!,
              onTap: () {
                appTheme.setTheme(AppTheme.lightGreenTheme);
              },
              isSelected: appTheme.currentTheme.primaryColor == Colors.green[700],
            ),

            const SizedBox(height: 12),

            // Blue Theme
            _buildThemeOption(
              context: context,
              title: 'Blue Theme',
              color: Colors.blue[700]!,
              onTap: () {
                appTheme.setTheme(AppTheme.lightBlueTheme);
              },
              isSelected: appTheme.currentTheme.primaryColor == Colors.blue[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}