import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

/// Human-friendly dates: "Today", "Yesterday", then "Monday 12 October".
class DateLabels {
  DateLabels._();

  static DateTime dayOf(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  static String day(BuildContext context, DateTime dateTime) {
    final localizations = AppLocalizations.of(context);
    final today = dayOf(DateTime.now());
    final difference = today.difference(dayOf(dateTime)).inDays;
    if (difference == 0) return localizations.translate('today');
    if (difference == 1) return localizations.translate('yesterday');
    final locale = localizations.locale.languageCode;
    final sameYear = dateTime.year == today.year;
    final label = DateFormat(sameYear ? 'EEEE d MMMM' : 'EEEE d MMMM yyyy', locale)
        .format(dateTime);
    return label[0].toUpperCase() + label.substring(1);
  }

  static String time(BuildContext context, DateTime dateTime) {
    final locale = AppLocalizations.of(context).locale.languageCode;
    return DateFormat.Hm(locale).format(dateTime);
  }

  /// "Today · 12:30"
  static String dayAndTime(BuildContext context, DateTime dateTime) =>
      '${day(context, dateTime)} · ${time(context, dateTime)}';
}
