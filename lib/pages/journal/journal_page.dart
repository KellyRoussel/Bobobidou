import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/date_labels.dart';
import '../../providers/meals_provider.dart';
import '../../providers/pain_provider.dart';
import '../../theme/bobo_tokens.dart';
import '../widgets/bobo_card.dart';
import '../widgets/bobo_logo.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_icon.dart';
import '../widgets/section_header.dart';
import 'log_sheets.dart';

/// Home tab: quick actions to log a meal or a pain episode, a summary of
/// the last 7 days and the journal of recent entries, grouped by day.
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  /// How many entries the journal shows.
  static const int maxEntries = 40;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final meals = context.watch<MealsProvider>().meals;
    final painEvents = context.watch<PainProvider>().painEvents;

    final entries = [
      for (final meal in meals)
        _Entry(EntryKind.meal, meal.dateTime, meal.ingredients.join(' · ')),
      for (final pain in painEvents)
        _Entry(EntryKind.pain, pain.dateTime, localizations.translate('pain_episode')),
    ]..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final weekStart = DateTime.now().subtract(const Duration(days: 7));
    final weekMeals = meals.where((m) => m.dateTime.isAfter(weekStart)).length;
    final weekPain = painEvents.where((p) => p.dateTime.isAfter(weekStart)).length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: BoboSpace.xxxl),
        children: [
          PageHeader(
            leading: const BoboLogo(size: 52),
            title: localizations.translate(_greetingKey()),
            subtitle: localizations.translate('journal_subtitle'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BoboSpace.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _QuickAction(
                          kind: EntryKind.meal,
                          title: localizations.translate('quick_meal'),
                          subtitle: localizations.translate('quick_meal_hint'),
                          onTap: () => showLogMealSheet(context),
                        ),
                      ),
                      const SizedBox(width: BoboSpace.md),
                      Expanded(
                        child: _QuickAction(
                          kind: EntryKind.pain,
                          title: localizations.translate('quick_pain'),
                          subtitle: localizations.translate('quick_pain_hint'),
                          onTap: () => showLogPainSheet(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: BoboSpace.xl),
                _WeekSummary(meals: weekMeals, painEvents: weekPain),
                const SizedBox(height: BoboSpace.xxl),
                SectionHeader(localizations.translate('journal')),
                if (entries.isEmpty)
                  EmptyState(
                    title: localizations.translate('journal_empty_title'),
                    message: localizations.translate('journal_empty_message'),
                  )
                else
                  ..._buildDays(context, entries.take(maxEntries).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greetingKey() {
    final hour = DateTime.now().hour;
    if (hour >= 18 || hour < 4) return 'greeting_evening';
    return 'greeting_day';
  }

  List<Widget> _buildDays(BuildContext context, List<_Entry> entries) {
    final days = <DateTime, List<_Entry>>{};
    for (final entry in entries) {
      days.putIfAbsent(DateLabels.dayOf(entry.dateTime), () => []).add(entry);
    }

    final textTheme = Theme.of(context).textTheme;
    return [
      for (final day in days.entries) ...[
        Padding(
          padding: const EdgeInsets.only(left: BoboSpace.xs, bottom: BoboSpace.sm),
          child: Text(
            DateLabels.day(context, day.key).toUpperCase(),
            style: textTheme.labelSmall,
          ),
        ),
        BoboCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < day.value.length; i++) ...[
                if (i > 0) const Divider(indent: 72),
                _EntryTile(day.value[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: BoboSpace.xl),
      ],
    ];
  }
}

class _Entry {
  final EntryKind kind;
  final DateTime dateTime;
  final String label;

  const _Entry(this.kind, this.dateTime, this.label);
}

class _EntryTile extends StatelessWidget {
  final _Entry entry;

  const _EntryTile(this.entry);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: BoboSpace.lg,
        vertical: BoboSpace.xs,
      ),
      leading: EntryIcon(entry.kind),
      title: Text(entry.label, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(
        DateLabels.time(context, entry.dateTime),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final EntryKind kind;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BoboCard(
      color: EntryIcon.tintOf(kind),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EntryIcon(kind, size: 44, filled: true),
              const Spacer(),
              const Icon(Icons.add_rounded, color: BoboColors.cacao),
            ],
          ),
          const SizedBox(height: BoboSpace.lg),
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: BoboSpace.xs),
          Text(subtitle, style: textTheme.bodyMedium!.copyWith(color: BoboColors.cacao)),
        ],
      ),
    );
  }
}

class _WeekSummary extends StatelessWidget {
  final int meals;
  final int painEvents;

  const _WeekSummary({required this.meals, required this.painEvents});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    Widget stat(EntryKind kind, int value, String label) => Expanded(
          child: Row(
            children: [
              EntryIcon(kind, size: 36),
              const SizedBox(width: BoboSpace.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$value', style: textTheme.headlineSmall),
                  Text(label, style: textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        );

    return BoboCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.translate('last_7_days').toUpperCase(), style: textTheme.labelSmall),
          const SizedBox(height: BoboSpace.md),
          Row(
            children: [
              stat(EntryKind.meal, meals, localizations.translate('meals_count_label')),
              stat(EntryKind.pain, painEvents, localizations.translate('pain_count_label')),
            ],
          ),
        ],
      ),
    );
  }
}
