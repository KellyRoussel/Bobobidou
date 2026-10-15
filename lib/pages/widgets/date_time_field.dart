import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/date_labels.dart';
import '../../theme/bobo_tokens.dart';

/// Tappable field showing when something happened ("Today · 12:30").
/// Opens the date then the time picker.
class DateTimeField extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const DateTimeField({required this.value, required this.onChanged, super.key});

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2020),
      // Entries are about the past: no logging in the future.
      lastDate: DateTime.now(),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (time == null) return;

    onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: BoboSpace.xs, bottom: BoboSpace.sm),
          child: Text(
            AppLocalizations.of(context).translate('when'),
            style: theme.textTheme.titleSmall,
          ),
        ),
        Material(
          color: BoboColors.creme,
          shape: const RoundedRectangleBorder(
            borderRadius: BoboRadius.mdAll,
            side: BorderSide(color: BoboColors.ligne, width: 1.5),
          ),
          child: InkWell(
            borderRadius: BoboRadius.mdAll,
            onTap: () => _pick(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BoboSpace.lg,
                vertical: BoboSpace.md + 2,
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: BoboSpace.md),
                  Expanded(
                    child: Text(
                      DateLabels.dayAndTime(context, value),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const Icon(Icons.expand_more_rounded, color: BoboColors.cacaoDoux),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
