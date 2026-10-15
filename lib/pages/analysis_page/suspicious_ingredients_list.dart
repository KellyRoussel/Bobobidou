import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/bobo_tokens.dart';
import '../widgets/bobo_card.dart';
import 'severity.dart';

/// Every ingredient eaten in the 48 hours before a pain episode, most
/// frequent first.
class SuspiciousIngredientsList extends StatelessWidget {
  final List<MapEntry<String, int>> sortedEntries;
  /// Highest count among all ingredients, to rank them even when filtered.
  final int maxValue;

  const SuspiciousIngredientsList(this.sortedEntries, {required this.maxValue, super.key});

  @override
  Widget build(BuildContext context) {
    return BoboCard(
      padding: const EdgeInsets.symmetric(vertical: BoboSpace.sm),
      child: Column(
        children: [
          for (var i = 0; i < sortedEntries.length; i++) ...[
            if (i > 0) const Divider(indent: 72),
            _IngredientTile(sortedEntries[i], ratio: sortedEntries[i].value / maxValue),
          ],
        ],
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final MapEntry<String, int> entry;
  final double ratio;

  const _IngredientTile(this.entry, {required this.ratio});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final severity = Severity.of(ratio);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: BoboSpace.lg),
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: severity.tint, shape: BoxShape.circle),
        child: Text(
          '${entry.value}',
          style: textTheme.titleMedium!.copyWith(
            fontFamily: BoboFonts.display,
            color: severity.text,
          ),
        ),
      ),
      title: Text(entry.key),
      subtitle: Text(
        '${localizations.translate("before")} ${entry.value} ${localizations.translate(entry.value == 1 ? "one_pain_episode" : "pain_episodes")}',
      ),
      trailing: _SeverityBadge(severity),
      onTap: () => _showDetails(context, severity),
    );
  }

  void _showDetails(BuildContext context, Severity severity) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.key),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${localizations.translate("associated_with")} ${entry.value} ${localizations.translate(entry.value == 1 ? "one_pain_episode" : "pain_episodes")}.",
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: BoboSpace.lg),
            // Wrap so the badge drops to the next line instead of
            // overflowing the dialog on narrow screens.
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: BoboSpace.sm,
              runSpacing: BoboSpace.sm,
              children: [
                Text.rich(
                  TextSpan(
                    text: localizations.translate("correlation_score"),
                    style: textTheme.titleSmall,
                    children: [
                      TextSpan(
                        text: '${(ratio * 100).toStringAsFixed(0)} %',
                        style: textTheme.titleSmall!.copyWith(color: severity.text),
                      ),
                    ],
                  ),
                ),
                _SeverityBadge(severity),
              ],
            ),
            const SizedBox(height: BoboSpace.lg),
            Text(
              ratio > 0.5
                  ? localizations.translate("highly_recommended")
                  : ratio > 0.25
                      ? localizations.translate("consider_reducing")
                      : localizations.translate("low_correlation"),
              style: textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate("close")),
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final Severity severity;

  const _SeverityBadge(this.severity);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BoboSpace.md, vertical: BoboSpace.xs),
      decoration: BoxDecoration(
        color: severity.tint,
        borderRadius: BorderRadius.circular(BoboRadius.pill),
      ),
      child: Text(
        AppLocalizations.of(context).translate(severity.labelKey),
        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: severity.text),
      ),
    );
  }
}
