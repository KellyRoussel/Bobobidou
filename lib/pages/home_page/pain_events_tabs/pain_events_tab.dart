import 'package:bobobidou/pages/home_page/pain_events_tabs/recent_pain_events.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/pain_event.dart';
import '../../../providers/pain_provider.dart';
import '../section_card.dart';
import '../section_title.dart';

class PainEventsTab extends StatefulWidget {
  const PainEventsTab({super.key});


  @override
  State<PainEventsTab> createState() => _PainEventsTabState();
}

class _PainEventsTabState extends State<PainEventsTab> {
  late DateTime _selectedPainDateTime;

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedPainDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  void initState() {
    super.initState();
    _selectedPainDateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {


    final painProvider = Provider.of<PainProvider>(context);

    String _formatDateTime(DateTime dateTime) {
      final locale = AppLocalizations.of(context).locale.languageCode;
      return DateFormat('dd MMM yyyy - HH:mm', locale).format(dateTime);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(AppLocalizations.of(context).translate("log_pain")),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    DateTime? dt = await _pickDateTime(context);
                    if (dt != null) {
                      setState(() {
                        _selectedPainDateTime = dt;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedPainDateTime == null
                                ? AppLocalizations.of(context).translate("select_date")
                                : "${AppLocalizations.of(context).translate("date_format")}${_formatDateTime(_selectedPainDateTime!)}",
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedPainDateTime == null ? Colors.grey[600] : Colors.black87,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {

                        PainEvent pain = PainEvent(dateTime: _selectedPainDateTime!);
                        await painProvider.addPainEvent(pain);

                        setState(() {
                          _selectedPainDateTime = DateTime.now();
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).translate("pain_logged")),
                            backgroundColor: Colors.green[700],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context).translate("log_pain_episode"),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RecentPainEventsList(painProvider),
        ],
      ),
    );
  }
}
