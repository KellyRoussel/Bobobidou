import 'package:bobobidou/config/app_config.dart';
import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/providers/locale_provider.dart';
import 'package:bobobidou/providers/subscription_provider.dart';
import 'package:bobobidou/theme/bobo_tokens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/bobo_card.dart';

/// Bobobidou Premium: what it gives, its price, the purchase and the restore.
class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  /// Opens the page; returns true if the user is a subscriber afterwards.
  static Future<bool> open(BuildContext context) async {
    final subscription = context.read<SubscriptionProvider>();
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PremiumPage()),
    );
    return subscription.isPremium;
  }

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Fresh state and store price
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SubscriptionProvider>().load());
  }

  Future<void> _subscribe() async {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final outcome = await context.read<SubscriptionProvider>().purchase();
    if (!mounted) return;
    setState(() => _busy = false);
    switch (outcome) {
      case PurchaseOutcome.success:
        messenger.showSnackBar(SnackBar(content: Text(localizations.translate('premium_welcome'))));
        navigator.pop(true);
      case PurchaseOutcome.cancelled:
        break;
      case PurchaseOutcome.pending:
        messenger.showSnackBar(SnackBar(content: Text(localizations.translate('premium_pending'))));
      case PurchaseOutcome.failed:
        messenger.showSnackBar(SnackBar(content: Text(localizations.translate('premium_purchase_failed'))));
    }
  }

  Future<void> _restore() async {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final premium = await context.read<SubscriptionProvider>().restore();
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(
      content: Text(localizations.translate(premium ? 'premium_restored' : 'premium_nothing_to_restore')),
    ));
    if (premium) navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final subscription = context.watch<SubscriptionProvider>();
    final status = subscription.status;

    return PopScope(
      // Not in the middle of a purchase
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: localizations.translate('close'),
            onPressed: _busy ? null : () => Navigator.of(context).pop(subscription.isPremium),
          ),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(BoboSpace.page, 0, BoboSpace.page, BoboSpace.xxl),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: BoboColors.repasTendre,
                  foregroundColor: BoboColors.repas,
                  child: Icon(Icons.photo_camera_rounded, size: 36),
                ),
              ),
              const SizedBox(height: BoboSpace.lg),
              Text(
                localizations.translate('premium_title'),
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: BoboSpace.sm),
              Text(
                localizations.translate(status != null && status.freePhotosLeft <= 0 && !status.premium
                    ? 'premium_subtitle_trial_over'
                    : 'premium_subtitle'),
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: BoboSpace.xl),
              BoboCard(
                padding: const EdgeInsets.all(BoboSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Benefit(
                      icon: Icons.auto_awesome_rounded,
                      text: localizations.translate('premium_benefit_recognition'),
                    ),
                    _Benefit(
                      icon: Icons.photo_library_rounded,
                      text: localizations
                          .translate('premium_benefit_daily')
                          .replaceAll('{count}', '${status?.dailyPhotoLimit ?? 5}'),
                    ),
                    _Benefit(
                      icon: Icons.favorite_rounded,
                      text: localizations.translate('premium_benefit_free'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BoboSpace.xl),
              if (subscription.isPremium)
                _ActiveSubscription(status!.expiresAt, status.willRenew)
              else ...[
                Text(
                  subscription.price == null
                      ? localizations.translate('premium_price_default')
                      : localizations.translate('premium_price').replaceAll('{price}', subscription.price!),
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: BoboSpace.md),
                FilledButton(
                  onPressed: _busy || subscription.isLoading ? null : _subscribe,
                  child: _busy
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(localizations.translate('premium_subscribe')),
                ),
                const SizedBox(height: BoboSpace.sm),
                TextButton(
                  onPressed: _busy ? null : _restore,
                  child: Text(localizations.translate('premium_restore')),
                ),
              ],
              const SizedBox(height: BoboSpace.lg),
              Text(
                localizations.translate('premium_terms'),
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: BoboSpace.sm),
              Center(
                child: TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse(AppConfig.privacyPolicyUrl(context.read<LocaleProvider>().locale.languageCode)),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(localizations.translate('privacy_policy')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Benefit({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BoboSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BoboColors.repas),
          const SizedBox(width: BoboSpace.md),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

/// Already a subscriber: until when, and the link to manage it in Google Play.
class _ActiveSubscription extends StatelessWidget {
  final DateTime? expiresAt;
  final bool willRenew;

  const _ActiveSubscription(this.expiresAt, this.willRenew);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          subscriptionStateText(localizations, expiresAt, willRenew),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BoboSpace.md),
        const ManageSubscriptionButton(),
      ],
    );
  }
}

/// "Premium · renews on 3 Dec" or "Premium · ends on 3 Dec" (cancelled).
String subscriptionStateText(AppLocalizations localizations, DateTime? expiresAt, bool willRenew) {
  if (expiresAt == null) return localizations.translate('premium_active');
  final date = DateFormat.yMMMMd(localizations.locale.languageCode).format(expiresAt);
  return localizations
      .translate(willRenew ? 'premium_renews_on' : 'premium_ends_on')
      .replaceAll('{date}', date);
}

/// Opens the Google Play subscriptions page, where the user cancels.
class ManageSubscriptionButton extends StatelessWidget {
  const ManageSubscriptionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return OutlinedButton.icon(
      icon: const Icon(Icons.open_in_new_rounded),
      label: Text(localizations.translate('premium_manage')),
      onPressed: () => openPlaySubscriptions(context),
    );
  }
}

Future<void> openPlaySubscriptions(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final failedText = AppLocalizations.of(context).translate('premium_manage_failed');
  var opened = false;
  try {
    opened = await launchUrl(AppConfig.playSubscriptionsUrl, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Google Play subscriptions launch failed: $e');
  }
  if (!opened) messenger.showSnackBar(SnackBar(content: Text(failedText)));
}
