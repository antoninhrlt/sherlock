import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/completion.dart';

void main() {
  final places = [
    {
      'name': 'Museum of Africa',
    },
    {
      'name': 'Best place to find fruits',
    },
    {
      'name': 'Fruits and vegetables market',
      'description': 'A cool place to buy fruits and vegetables',
    },
    {
      'name': 'Fresh fish store',
    },
    {
      'name': 'Ball pool',
    },
    {
      'name': 'Finland palace',
    },
    {
      'name': 90,
    },
  ];

  final completion = SherlockCompletion(where: 'name', elements: places);

  test('completion', () {
    List<String> results = completion.input(input: 'Fr');
    debugPrint(results.toString());
    debugPrint(completion.results.toString());

    debugPrint('---');

    results = completion.input(input: 'Fr', minResults: 4);
    debugPrint(results.toString());
    debugPrint(completion.results.toString());
  });

  test('unchangedRanges', () {
    const input = 'Fr';
    final results = completion.input(input: input, minResults: 3);
    debugPrint(results.toString());
    debugPrint(
      completion.unchangedRanges(input: input, results: results).toString(),
    );
  });

  test('readmeCompletion', () {
    final a = completion.input(input: 'fr');
    debugPrint(a.toString());

    final b = completion.input(input: 'Fr', caseSensitive: true);
    debugPrint(b.toString());

    final c = completion.input(input: 'fr', minResults: 4);
    debugPrint(c.toString());

    final d = completion.input(
      input: 'Fr',
      minResults: 3,
      caseSensitiveFurtherSearches: true,
    );
    debugPrint(d.toString());

    final e = completion.input(input: 'fr', maxResults: 1);
    debugPrint(e.toString());
  });
}
