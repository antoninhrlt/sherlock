import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/normalize.dart';
import 'package:sherlock/sherlock.dart';

void main() {
  test('normalize', () {
    var string = 'wéirdö nàmè AA';
    string = string.normalize(NormalizeSettings(
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
      normalizeSettings: NormalizeSettings(
        normalizeCase: false,
        normalizeCaseType: false,
        removeDiacritics: false,
      ),
    );

    sherlock.query(where: 'name', regex: r'^Something with a weird name$');
    debugPrint(sherlock.results.toString());

    sherlock.forget();
  });

  test('normalizeDiacritics', () {
    var sherlock = Sherlock(
      elements: elements,
      normalizeSettings: NormalizeSettings(
        normalizeCase: false,
        normalizeCaseType: false,
        removeDiacritics: true,
      ),
    );

    sherlock.query(where: 'name', regex: r'^Something with a weird name$');
    debugPrint(sherlock.results.toString());

    sherlock.forget();
  });

  test('normalizeCaseType', () {
    var sherlock = Sherlock(
      elements: elements,
      normalizeSettings: NormalizeSettings(
        normalizeCase: false,
        normalizeCaseType: true,
        removeDiacritics: false,
      ),
    );

    sherlock.query(where: 'name', regex: r'^something camel case$');
    debugPrint(sherlock.results.toString());
    sherlock.forget();

    sherlock.query(where: 'name', regex: r'^something snake case$');
    debugPrint(sherlock.results.toString());
    sherlock.forget();
  });

  test('normalizeCase', () {
    var sherlock = Sherlock(
      elements: elements,
      normalizeSettings: NormalizeSettings(
        normalizeCase: true,
        normalizeCaseType: false,
        removeDiacritics: false,
      ),
    );

    sherlock.query(where: 'name', regex: r'^something NOT UPPER case$');
    debugPrint(sherlock.results.toString());
    sherlock.forget();

    sherlock.normalizeSettings.caseSensitivity = true;
    sherlock.query(where: 'name', regex: r'^something NOT UPPER case$');
    debugPrint(sherlock.results.toString());

    sherlock.forget();
  });

  test('normalizeAll', () {
    var sherlock = Sherlock(
      elements: elements,
      normalizeSettings: NormalizeSettings(
        normalizeCase: true,
        normalizeCaseType: true,
        removeDiacritics: true,
      ),
    );

    sherlock.query(where: 'name', regex: r'^weirder than the weird$');
    debugPrint(sherlock.results.toString());
    sherlock.forget();
  });
}
