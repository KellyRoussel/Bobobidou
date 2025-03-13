import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          appLocalizations.translate('language'),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              child: Column(
                children: [
                  _buildLanguageOption(
                    context,
                    title: appLocalizations.translate('english'),
                    locale: const Locale('en', ''),
                    currentLocale: localeProvider.locale,
                    onSelect: () => localeProvider.setLocale(const Locale('en', '')),
                  ),
                  const Divider(),
                  _buildLanguageOption(
                    context,
                    title: appLocalizations.translate('french'),
                    locale: const Locale('fr', ''),
                    currentLocale: localeProvider.locale,
                    onSelect: () => localeProvider.setLocale(const Locale('fr', '')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, {
        required String title,
        required Locale locale,
        required Locale currentLocale,
        required VoidCallback onSelect,
      }) {
    final isSelected = locale.languageCode == currentLocale.languageCode;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
        Icons.check_circle,
        color: Theme.of(context).primaryColor,
      )
          : null,
      onTap: onSelect,
    );
  }
}