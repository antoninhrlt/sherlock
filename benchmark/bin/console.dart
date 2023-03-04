import 'dart:io';

import 'package:duration/duration.dart';
import 'package:sherlock/normalize.dart';
import 'package:sherlock/sherlock.dart';
import 'dart:convert';

void input(String input) {
  File('lib/elements.json').readAsString().then((String contents) {
    final jsonDecoded = jsonDecode(contents);

    final elements = List<Map<String, dynamic>>.from(jsonDecoded);

    var sherlock = Sherlock(
      elements: elements,
      priorities: {
        'address': 10,
        'about': 5,
      },
      normalization: NormalizationSettings(
        normalizeCase: true,
        normalizeCaseType: false,
        removeDiacritics: true,
      ),
    );

    final stopwatch = Stopwatch()..start();
    sherlock.search(input: input);

    Duration s = stopwatch.elapsed;
    printDuration(s, tersity: DurationTersity.millisecond);
  });
}

void main() {
  input('louisiana');
  input('ipsum');
  input('ipsum louisiana');
  input('ipsum in louisiana');
  input('Hawaii COLORADO');
  input('Hawaii COLORADO');
  input('non dolor Texas');
  input('non dolor Texas ipsum louisiana hawaii');
}
