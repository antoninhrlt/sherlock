import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/levenshtein.dart';

void main() {
  test('levenshtein', () {
    int distance = levenshtein(a: 'kitten', b: 'sitting');
    debugPrint(distance.toString());

    distance = levenshtein(b: 'kitten', a: 'sitting');
    debugPrint(distance.toString());

    distance = levenshtein(a: 'saturday', b: 'sunday');
    debugPrint(distance.toString());

    distance = levenshtein(b: 'saturday', a: 'sunday');
    debugPrint(distance.toString());

    distance = levenshtein(a: 'per', b: 'pear');
    debugPrint(distance.toString());
  });
}
