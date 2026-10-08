import 'package:bobobidou/models/meal.dart';
import 'package:bobobidou/models/pain_event.dart';
import 'package:bobobidou/services/csv_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const labels = CsvExportLabels(
    date: 'Date',
    time: 'Heure',
    type: 'Type',
    ingredients: 'Ingrédients',
    meal: 'Repas',
    pain: 'Douleur',
  );

  test('builds a chronological timeline with BOM and ; separator', () {
    final csv = CsvExportService.buildCsv(
      [
        Meal(dateTime: DateTime(2026, 10, 7, 12, 30), ingredients: ['pâtes', 'tomate']),
        Meal(dateTime: DateTime(2026, 10, 6, 19, 5), ingredients: []),
      ],
      [PainEvent(dateTime: DateTime(2026, 10, 7, 15, 10))],
      labels,
    );

    expect(
      csv,
      '﻿Date;Heure;Type;Ingrédients\r\n'
      '2026-10-06;19:05;Repas;\r\n'
      '2026-10-07;12:30;Repas;pâtes, tomate\r\n'
      '2026-10-07;15:10;Douleur;\r\n',
    );
  });

  test('quotes fields containing separators or quotes', () {
    final csv = CsvExportService.buildCsv(
      [Meal(dateTime: DateTime(2026, 1, 1, 8), ingredients: ['sel; poivre', 'pain "maison"'])],
      [],
      labels,
    );

    expect(csv.split('\r\n')[1], '2026-01-01;08:00;Repas;"sel; poivre, pain ""maison"""');
  });
}
