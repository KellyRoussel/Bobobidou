import 'package:bobobidou/providers/pain_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../section_title.dart';

class RecentPainEventsList extends StatelessWidget {
  final PainProvider painProvider;
  final int maxItems=30;
  const RecentPainEventsList(this.painProvider, {super.key});

  @override
  Widget build(BuildContext context) {

    String _formatDateTime(DateTime dateTime) {
      final locale = AppLocalizations.of(context).locale.languageCode;
      return DateFormat('dd MMM yyyy - HH:mm', locale).format(dateTime);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(AppLocalizations.of(context).translate("recent_pain"),),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: painProvider.painEvents.isEmpty
              ? Center(
            child: Text(
              AppLocalizations.of(context).translate("no_pain"),
              style: TextStyle(
                color:Colors.grey[600],
                fontSize: 16,
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: painProvider.painEvents.length > maxItems ? maxItems : painProvider.painEvents.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey[600]),
            itemBuilder: (context, index) {
              final reversedIndex = painProvider.painEvents.length - 1 - index;
              if (reversedIndex < 0) return const SizedBox.shrink();

              final pain = painProvider.painEvents[reversedIndex];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent.withOpacity(0.2),
                  child: const Icon(Icons.healing, color: Colors.redAccent),
                ),
                title: Text(
                  AppLocalizations.of(context).translate("pain_episode"),
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[600]),
                ),
                subtitle: Text(_formatDateTime(pain.dateTime), style: TextStyle(color: Colors.grey[600]),),
              );
            },
          ),
        ),
      ],
    );
  }
}
