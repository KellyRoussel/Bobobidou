import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/pages/analysis_page/analysis_page.dart';
import 'package:bobobidou/pages/journal/journal_page.dart';
import 'package:bobobidou/pages/settings_page.dart';
import 'package:flutter/material.dart';

/// App shell: three destinations in a bottom navigation bar.
/// Journal (log and review), Analysis (correlations), Settings (account,
/// appearance, language, data).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Pages are rebuilt when selected so the analysis always reflects the
    // latest entries.
    final page = switch (_index) {
      1 => AnalysisPage(onStartLogging: () => _select(0)),
      2 => const SettingsPage(),
      _ => const JournalPage(),
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(_index), child: page),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book_rounded),
            label: localizations.translate('nav_journal'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights_rounded),
            label: localizations.translate('nav_analysis'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: localizations.translate('nav_settings'),
          ),
        ],
      ),
    );
  }
}
