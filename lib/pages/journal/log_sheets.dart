import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/meal.dart';
import '../../models/pain_event.dart';
import '../../providers/meals_provider.dart';
import '../../providers/pain_provider.dart';
import '../../theme/bobo_tokens.dart';
import '../widgets/date_time_field.dart';
import '../widgets/entry_icon.dart';
import '../widgets/ingredients_input.dart';

/// Opens the "log a meal" sheet above the current page.
Future<void> showLogMealSheet(BuildContext context) =>
    _showLogSheet(context, const _LogMealSheet());

/// Opens the "log a pain episode" sheet above the current page.
Future<void> showLogPainSheet(BuildContext context) =>
    _showLogSheet(context, const _LogPainSheet());

Future<void> _showLogSheet(BuildContext context, Widget sheet) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Padding(
      // Keep the save button above the keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          BoboSpace.page,
          0,
          BoboSpace.page,
          BoboSpace.xl,
        ),
        child: sheet,
      ),
    ),
  );
}

void _confirm(ScaffoldMessengerState messenger, String message) {
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: BoboColors.peche),
          const SizedBox(width: BoboSpace.md),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

class _SheetTitle extends StatelessWidget {
  final EntryKind kind;
  final String title;
  final String subtitle;

  const _SheetTitle({required this.kind, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        EntryIcon(kind, size: 48, filled: true),
        const SizedBox(width: BoboSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.headlineSmall),
              Text(subtitle, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogMealSheet extends StatefulWidget {
  const _LogMealSheet();

  @override
  State<_LogMealSheet> createState() => _LogMealSheetState();
}

class _LogMealSheetState extends State<_LogMealSheet> {
  DateTime _dateTime = DateTime.now();
  List<String> _ingredients = [];

  Future<void> _save() async {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (_ingredients.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizations.translate('fill_all_fields'))),
      );
      return;
    }

    await context.read<MealsProvider>().addMeal(
          Meal(dateTime: _dateTime, ingredients: List.of(_ingredients)),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    _confirm(messenger, localizations.translate('meal_logged'));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetTitle(
          kind: EntryKind.meal,
          title: localizations.translate('log_meal'),
          subtitle: localizations.translate('log_meal_hint'),
        ),
        const SizedBox(height: BoboSpace.xl),
        IngredientInputWidget(
          onIngredientsChanged: (ingredients) {
            setState(() => _ingredients = List.of(ingredients));
          },
        ),
        const SizedBox(height: BoboSpace.xl),
        DateTimeField(
          value: _dateTime,
          onChanged: (value) => setState(() => _dateTime = value),
        ),
        const SizedBox(height: BoboSpace.xl),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check_rounded),
          label: Text(localizations.translate('save_meal')),
        ),
      ],
    );
  }
}

class _LogPainSheet extends StatefulWidget {
  const _LogPainSheet();

  @override
  State<_LogPainSheet> createState() => _LogPainSheetState();
}

class _LogPainSheetState extends State<_LogPainSheet> {
  DateTime _dateTime = DateTime.now();

  Future<void> _save() async {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await context.read<PainProvider>().addPainEvent(PainEvent(dateTime: _dateTime));
    if (!mounted) return;
    Navigator.of(context).pop();
    _confirm(messenger, localizations.translate('pain_logged'));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetTitle(
          kind: EntryKind.pain,
          title: localizations.translate('log_pain'),
          subtitle: localizations.translate('log_pain_hint'),
        ),
        const SizedBox(height: BoboSpace.xl),
        DateTimeField(
          value: _dateTime,
          onChanged: (value) => setState(() => _dateTime = value),
        ),
        const SizedBox(height: BoboSpace.xl),
        FilledButton.icon(
          onPressed: _save,
          style: FilledButton.styleFrom(backgroundColor: BoboColors.douleur),
          icon: const Icon(Icons.check_rounded),
          label: Text(localizations.translate('log_pain_episode')),
        ),
      ],
    );
  }
}
