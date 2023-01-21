import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/sherlock.dart';

final activities = [
  {
    'title': 'Surf',
    'description': 'Live the wave',
    'id': 1,
  },
  {
    'title': 'LiveStream',
    'description': 'Watch live streams',
    'id': 2,
  },
  {
    'title': 'Extreme VR',
    'description': 'VR immersion',
    'id': 3,
  },
  {
    'title': 'Extreme VR 2',
    'description': 'New VR immersion',
    'id': 4,
  },
  {
    'title': 'Meet cats',
    'description': 'Cool thing to do',
    'id': 5,
  },
  {
    'title': 'Meet dogs',
    'description': 'Don\'t you want to meet cats ?',
    'id': 6,
  },
  {
    'title': 'Parc',
    'openingHours': {
      'monday': [7, 17],
      'tuesday': [7, 18],
    },
    'id': 7,
  },
  {
    'title': 'Parc',
    'openingHours': {
      'tuesday': [5, 22],
    },
    'id': 8,
  }
];

void main() {
  test('hello', () {
    assert(helloSherlock());
  });

  test('query', () {
    final sherlock = Sherlock(elements: activities);

    /// All activities where their title contains the word 'vr'.
    sherlock.query(where: 'title', regex: r'vr');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities where their title contains the word 'live' or 'vr'.
    sherlock.query(where: 'title', regex: r'(live|vr)');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities where their description contains the word 'live'.
    sherlock.query(where: 'description', regex: r'(live)');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities where their description or title contains the word 'cat'.
    sherlock.query(where: 'title', regex: r'cat');
    sherlock.query(where: 'description', regex: r'cat');

    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities where at least one column's value contains the word 'vr'.
    sherlock.query(where: '*', regex: r'vr');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities where are monday is specified in the opening hours.
    sherlock.queryExists(where: 'openingHours', what: 'monday');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities having a title corresponding to 'Parc'.
    sherlock.queryBool(where: 'title', fn: (value) => value == 'Parc');
    debugPrint(sherlock.results.toString());

    sherlock.forget();
  });
}
