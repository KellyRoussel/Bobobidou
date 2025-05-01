import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/pages/home_page/meals_tab/meals_tab.dart';
import 'package:bobobidou/pages/home_page/pain_events_tabs/pain_events_tab.dart';
import 'package:bobobidou/pages/home_page/section_card.dart';
import 'package:bobobidou/pages/home_page/section_title.dart';
import 'package:bobobidou/pages/language_settings_page.dart';
import 'package:bobobidou/pages/widgets/backup_button.dart';
import 'package:bobobidou/pages/widgets/ingredients_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal.dart';
import '../../models/pain_event.dart';
import '../../providers/meals_provider.dart';
import '../../providers/pain_provider.dart';
import '../analysis_page/analysis_page.dart';
import 'package:intl/intl.dart';
import '../theme_settings_page.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
            AppLocalizations.of(context).translate("app_title"),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),

        ),

        actions: [
          BackupButton(),
          IconButton(
            icon: Icon(
              Icons.color_lens,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: AppLocalizations.of(context).translate('theme_settings'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.language,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: AppLocalizations.of(context).translate('language'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageSettingsPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          indicatorWeight: 3,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          tabs: [
            Tab(
              icon: const Icon(Icons.restaurant),
              text: AppLocalizations.of(context).translate("meals_tab"),
            ),
            Tab(
              icon: const Icon(Icons.healing),
              text: AppLocalizations.of(context).translate("pain_tab"),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Meals Tab
          MealsTab(),

          // Pain Events Tab
          PainEventsTab()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalysisPage()),
          );
        },
        child: const Icon(Icons.insights),
      ),
    );
  }

}