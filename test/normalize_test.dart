import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/result.dart';
import 'package:sherlock/sherlock.dart';

void main() {
  test('normalize', () async {
    var string = 'wéirdö nàmè AA';
    string = string.normalize(const NormalizationSettings(
      normalizeCase: true,
      normalizeCaseType: false,
      removeDiacritics: true,
    ));

    debugPrint(string);
  });

  final elements = [
    {
      'name': 'Sômething wîth â wéird nàmè',
    },
    {
      'name': 'somethingCamelCase',
    },
    {
      'name': 'something_snake_case',
    },
    {
      'name': 'something not upper case',
    },
    {
      'name': 'WéîrderThan tHë_wèirD',
    }
  ];

  test('normalizeNothing', () async {
    var sherlock = Sherlock(
      elements: elements,
      normalization: const NormalizationSettings(
        normalizeCase: false,
        normalizeCaseType: false,
        removeDiacritics: false,
      ),
    );

    final results = await sherlock.query(where: 'name', regex: r'^Something with a weird name$');
    debugPrint(results.sorted().unwrap().toString());
  });

  test('normalizeDiacritics', () async {
    var sherlock = Sherlock(
      elements: elements,
      normalization: const NormalizationSettings(
        normalizeCase: false,
        normalizeCaseType: false,
        removeDiacritics: true,
      ),
    );

    final results = await sherlock.query(where: 'name', regex: r'^Something with a weird name$');
    debugPrint(results.sorted().unwrap().toString());
  });

  test('normalizeCaseType', () async {
    var sherlock = Sherlock(
      elements: elements,
      normalization: const NormalizationSettings(
        normalizeCase: false,
        normalizeCaseType: true,
        removeDiacritics: false,
      ),
    );

    final results1 = await sherlock.query(where: 'name', regex: r'^something camel case$');
    debugPrint(results1.sorted().unwrap().toString());

    final results2 = await sherlock.query(where: 'name', regex: r'^something snake case$');
    debugPrint(results2.sorted().unwrap().toString());
  });

  test('normalizeCase', () async {
    var sherlock = Sherlock(
      elements: elements,
      normalization: const NormalizationSettings(
        normalizeCase: true,
        normalizeCaseType: false,
        removeDiacritics: false,
      ),
    );

    final results1 = await sherlock.query(where: 'name', regex: r'^something NOT UPPER case$');
    debugPrint(results1.sorted().unwrap().toString());

    final results2 = await sherlock.query(
      where: 'name',
      regex: r'^something NOT UPPER case$',
      specificNormalization: const NormalizationSettings(
        normalizeCase: false,
        normalizeCaseType: false,
        removeDiacritics: false,
      ),
    );

    debugPrint(results2.sorted().unwrap().toString());
  });

  test('normalizeAll', () async {
    var sherlock = Sherlock(
      elements: elements,
      normalization: const NormalizationSettings(
        normalizeCase: true,
        normalizeCaseType: true,
        removeDiacritics: true,
      ),
    );

    final results = await sherlock.query(where: 'name', regex: r'^weirder than the weird$');
    debugPrint(results.sorted().unwrap().toString());
  });

  test('specificNormalize', () async {
    var sherlock = Sherlock(
      elements: elements,
      normalization: const NormalizationSettings(
        normalizeCase: true,
        normalizeCaseType: true,
        removeDiacritics: true,
      ),
    );

    final results1 = await sherlock.query(where: 'name', regex: r'^something with a weird name$');
    debugPrint(results1.sorted().unwrap().toString());

    final results2 = await sherlock.query(
      where: 'name',
      regex: r'^something with a weird name$',
      specificNormalization: const NormalizationSettings(
        normalizeCase: true,
        normalizeCaseType: true,
        removeDiacritics: false,
      ),
    );

    debugPrint(results2.sorted().unwrap().toString());
  });
}
