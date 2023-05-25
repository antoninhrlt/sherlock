import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/normalize.dart';
import 'package:sherlock/sherlock.dart';

void main() {
  test('normalize', () {
    var string = 'wéirdö nàmè AA';
    string = string.normalize(NormalizationSettings(
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

  test('normalizeNothing', () {
    var sherlock = Sherlock(
      elements: elements,
      normalization: NormalizationSettings(
        normalizeCase: false,
        normalizeCaseType: false,
        removeDiacritics: false,
      ),
    );

    final results = sherlock.query(where: 'name', regex: r'^Something with a weird name$');
    debugPrint(results.toString());
  });

  test('normalizeDiacritics', () {
    var sherlock = Sherlock(
      elements: elements,
      normalization: NormalizationSettings(
        normalizeCase: false,
        normalizeCaseType: false,
        removeDiacritics: true,
      ),
    );

    final results = sherlock.query(where: 'name', regex: r'^Something with a weird name$');
    debugPrint(results.toString());
  });

  test('normalizeCaseType', () {
    var sherlock = Sherlock(
      elements: elements,
      normalization: NormalizationSettings(
        normalizeCase: false,
        normalizeCaseType: true,
        removeDiacritics: false,
      ),
    );

    final results1 = sherlock.query(where: 'name', regex: r'^something camel case$');
    debugPrint(results1.toString());

    final results2 = sherlock.query(where: 'name', regex: r'^something snake case$');
    debugPrint(results2.toString());
  });

  test('normalizeCase', () {
    var sherlock = Sherlock(
      elements: elements,
      normalization: const NormalizationSettings(
        normalizeCase: true,
        normalizeCaseType: false,
        removeDiacritics: false,
      ),
    );

    final results1 = sherlock.query(where: 'name', regex: r'^something NOT UPPER case$');
    debugPrint(results1.toString());

    final results2 = sherlock.query(
      where: 'name',
      regex: r'^something NOT UPPER case$',
      specificNormalization: const NormalizationSettings(
        normalizeCase: false,
        normalizeCaseType: false,
        removeDiacritics: false,
      ),
    );

    debugPrint(results2.toString());
  });

  test('normalizeAll', () {
    var sherlock = Sherlock(
      elements: elements,
      normalization: const NormalizationSettings(
        normalizeCase: true,
        normalizeCaseType: true,
        removeDiacritics: true,
      ),
    );

    final results = sherlock.query(where: 'name', regex: r'^weirder than the weird$');
    debugPrint(results.toString());
  });

  test('specificNormalize', () {
    var sherlock = Sherlock(
      elements: elements,
      normalization: const NormalizationSettings(
        normalizeCase: true,
        normalizeCaseType: true,
        removeDiacritics: true,
      ),
    );

    final results1 = sherlock.query(where: 'name', regex: r'^something with a weird name$');
    debugPrint(results1.toString());

    final results2 = sherlock.query(
      where: 'name',
      regex: r'^something with a weird name$',
      specificNormalization: const NormalizationSettings(
        normalizeCase: true,
        normalizeCaseType: true,
        removeDiacritics: false,
      ),
    );

    debugPrint(results2.toString());
  });
}
