import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/meals_provider.dart';
import '../section_title.dart';

class RecentMealsList extends StatelessWidget {
  final MealsProvider mealsProvider;
  const RecentMealsList(this.mealsProvider, {super.key});
  final int maxItems=30;



  @override
  Widget build(BuildContext context) {

    String _formatDateTime(DateTime dateTime) {
      final locale = AppLocalizations.of(context).locale.languageCode;
      return DateFormat('dd MMM yyyy - HH:mm', locale).format(dateTime);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(AppLocalizations.of(context).translate("recent_meals"),),
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
          child: mealsProvider.meals.isEmpty
              ? Center(
            child: Text(
              AppLocalizations.of(context).translate("no_meals"),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: mealsProvider.meals.length > maxItems ? maxItems : mealsProvider.meals.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey[600]),
            itemBuilder: (context, index) {
              final reversedIndex = mealsProvider.meals.length - 1 - index;
              if (reversedIndex < 0) return const SizedBox.shrink();

              final meal = mealsProvider.meals[reversedIndex];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Icon(Icons.restaurant, color: Theme.of(context).primaryColor),
                ),
                title: Text(
                  meal.ingredients.join(", "),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[600]),
                ),
                subtitle: Text(_formatDateTime(meal.dateTime),
                  style: TextStyle(color: Colors.grey[600]),),
              );
            },
          ),
        ),
      ],
    );
  }
}
