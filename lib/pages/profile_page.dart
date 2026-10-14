import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/models/user.dart';
import 'package:bobobidou/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows the Google account the user is signed in with, and lets them
/// sign in or out. Credits (used / remaining) will be added here later.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          localizations.translate('profile'),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: authProvider.isAuthenticated
                        ? _buildSignedIn(context, authProvider.user)
                        : _buildSignedOut(context),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSignedIn(BuildContext context, User? user) {
    final localizations = AppLocalizations.of(context);
    final picture = user?.picture;

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: picture != null ? NetworkImage(picture) : null,
          child: picture == null ? const Icon(Icons.person, size: 40) : null,
        ),
        const SizedBox(height: 16),
        if (user != null) ...[
          Text(
            user.name,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
        _buildStatus(
          context,
          icon: Icons.check_circle,
          color: Colors.green,
          label: localizations.translate('signed_in_with_google'),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: Text(localizations.translate('logout')),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => _confirmLogout(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSignedOut(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          child: Icon(Icons.person_outline, size: 40),
        ),
        const SizedBox(height: 16),
        _buildStatus(
          context,
          icon: Icons.cancel,
          color: Colors.grey,
          label: localizations.translate('not_signed_in'),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.translate('sign_in_explanation'),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: Text(localizations.translate('continue_with_google')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => _login(context),
          ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Flexible(child: Text(label, style: TextStyle(color: color))),
      ],
    );
  }

  Future<void> _login(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await context.read<AuthProvider>().login(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(localizations
            .translate(success ? 'login_success' : 'login_failed')),
        backgroundColor: success ? Colors.green : Colors.red,
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
}
