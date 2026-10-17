import 'package:bobobidou/config/app_config.dart';
import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/models/user.dart';
import 'package:bobobidou/providers/auth_provider.dart';
import 'package:bobobidou/providers/locale_provider.dart';
import 'package:bobobidou/theme/bobo_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/bobo_card.dart';
import 'widgets/export_data_tile.dart';
import 'widgets/section_header.dart';

/// Settings tab: the Google account used for food recognition, the
/// language, the data export and the privacy policy.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: BoboSpace.xxxl),
        children: [
          PageHeader(title: localizations.translate('nav_settings')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BoboSpace.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AccountCard(),
                const SizedBox(height: BoboSpace.xxl),
                SectionHeader(localizations.translate('language')),
                const _LanguagePicker(),
                const SizedBox(height: BoboSpace.xxl),
                SectionHeader(localizations.translate('my_data')),
                const BoboCard(
                  padding: EdgeInsets.symmetric(vertical: BoboSpace.sm),
                  child: Column(
                    children: [
                      ExportDataTile(),
                      Divider(height: 1, indent: BoboSpace.lg, endIndent: BoboSpace.lg),
                      _PrivacyPolicyTile(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return BoboCard(
      padding: const EdgeInsets.all(BoboSpace.xl),
      child: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : authProvider.isAuthenticated
              ? _buildSignedIn(context, authProvider.user)
              : _buildSignedOut(context),
    );
  }

  Widget _buildSignedIn(BuildContext context, User? user) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final picture = user?.picture;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: BoboColors.pecheSplash,
              foregroundColor: BoboColors.cacao,
              backgroundImage: picture != null ? NetworkImage(picture) : null,
              child: picture == null ? const Icon(Icons.person_rounded, size: 28) : null,
            ),
            const SizedBox(width: BoboSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user != null) ...[
                    Text(user.name, style: textTheme.titleLarge),
                    Text(user.email, style: textTheme.bodyMedium),
                  ],
                  const SizedBox(height: BoboSpace.xs),
                  _buildStatus(
                    context,
                    icon: Icons.check_circle_rounded,
                    color: BoboColors.succes,
                    label: localizations.translate('signed_in_with_google'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: BoboSpace.xl),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout_rounded),
          label: Text(localizations.translate('logout')),
          style: OutlinedButton.styleFrom(foregroundColor: BoboColors.erreur),
          onPressed: () => _confirmLogout(context),
        ),
        const SizedBox(height: BoboSpace.sm),
        TextButton.icon(
          icon: const Icon(Icons.delete_forever_rounded),
          label: Text(localizations.translate('delete_account')),
          style: TextButton.styleFrom(foregroundColor: BoboColors.erreur),
          onPressed: () => _confirmDeleteAccount(context),
        ),
      ],
    );
  }

  Widget _buildSignedOut(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: BoboColors.pecheSplash,
              foregroundColor: BoboColors.cacao,
              child: Icon(Icons.person_outline_rounded, size: 28),
            ),
            const SizedBox(width: BoboSpace.lg),
            Expanded(
              child: Text(
                localizations.translate('not_signed_in'),
                style: textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: BoboSpace.md),
        Text(localizations.translate('sign_in_explanation'), style: textTheme.bodyMedium),
        const SizedBox(height: BoboSpace.xl),
        FilledButton.icon(
          icon: const Icon(Icons.login_rounded),
          label: Text(localizations.translate('continue_with_google')),
          onPressed: () => _login(context),
        ),
      ],
    );
  }

  Widget _buildStatus(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: BoboSpace.xs),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Future<void> _login(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await context.read<AuthProvider>().login(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(localizations.translate(success ? 'login_success' : 'login_failed')),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.translate('logout')),
        content: Text(localizations.translate('logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.translate('cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: BoboColors.erreur),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.translate('logout')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.logout();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.translate('delete_account')),
        content: Text(localizations.translate('delete_account_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.translate('cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: BoboColors.erreur),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.translate('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await authProvider.deleteAccount();
    messenger.showSnackBar(
      SnackBar(
        content: Text(localizations.translate(
            success ? 'delete_account_success' : 'delete_account_failed')),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final localizations = AppLocalizations.of(context);

    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: 'fr', label: Text(localizations.translate('french'))),
        ButtonSegment(value: 'en', label: Text(localizations.translate('english'))),
      ],
      selected: {localeProvider.locale.languageCode},
      onSelectionChanged: (selection) =>
          context.read<LocaleProvider>().setLocale(Locale(selection.first, '')),
    );
  }
}

/// Opens the privacy policy in the browser, in the app language.
class _PrivacyPolicyTile extends StatelessWidget {
  const _PrivacyPolicyTile();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return ListTile(
      onTap: () => _open(context),
      leading: const Icon(Icons.privacy_tip_outlined),
      title: Text(localizations.translate('privacy_policy')),
      subtitle: Text(localizations.translate('privacy_policy_subtitle')),
      trailing: const Icon(Icons.open_in_new_rounded),
    );
  }

  Future<void> _open(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final languageCode = context.read<LocaleProvider>().locale.languageCode;
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(AppConfig.privacyPolicyUrl(languageCode)),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Privacy policy launch failed: $e');
    }
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizations.translate('privacy_policy_open_failed'))),
      );
    }
  }
}
