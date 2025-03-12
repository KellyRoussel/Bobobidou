import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  @override
  void initState() {
    super.initState();
    // Chargement initial des données d'analyse
    final analysisProvider =
    Provider.of<AnalysisProvider>(context, listen: false);
    analysisProvider.loadAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analyse des Ingrédients"),
      ),
      body: Consumer<AnalysisProvider>(
        builder: (context, analysisProvider, child) {
          final involvement = analysisProvider.ingredientInvolvement;
          final sortedEntries = involvement.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          if (sortedEntries.isEmpty) {
            return const Center(child: Text("Aucune donnée disponible"));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await analysisProvider.loadAnalysis();
            },
            child: ListView.builder(
              itemCount: sortedEntries.length,
              itemBuilder: (context, index) {
                final entry = sortedEntries[index];
                return ListTile(
                  title: Text(entry.key),
                  trailing: Text("Impliqué ${entry.value} fois"),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
