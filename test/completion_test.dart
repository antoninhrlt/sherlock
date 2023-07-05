import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/completion.dart';
import 'package:sherlock/result.dart';

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

  test('completion', () async {
    List<Result> results = await completion.input(input: 'Fr');
    List<String> stringResults = await completion.getStrings(fromResults: results);
    debugPrint(stringResults.toString());

    debugPrint('---');

    results = await completion.input(input: 'Fr', minResults: 4);
    stringResults = await completion.getStrings(fromResults: results);
    debugPrint(stringResults.toString());
  });

  test('unchangedRanges', () async {
    const input = 'Fr';
    final results = await completion.input(input: input, minResults: 3);
    final stringResults = await completion.getStrings(fromResults: results);

    debugPrint(stringResults.toString());

    debugPrint(
      (await SherlockCompletion.unchangedRanges(input: input, results: stringResults)).toString(),
    );
  });

  test('readmeCompletion', () async {
    final a = await completion.input(input: 'fr');
    debugPrint(a.toString());

    final b = await completion.input(input: 'Fr', caseSensitive: true);
    debugPrint(b.toString());

    final c = await completion.input(input: 'fr', minResults: 4);
    debugPrint(c.toString());

    final d = await completion.input(
      input: 'Fr',
      minResults: 3,
      caseSensitiveFurtherSearches: true,
    );

    debugPrint(d.toString());

    final e = await completion.input(input: 'fr', maxResults: 1);
    debugPrint(e.toString());
  });
}
