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
    'title': 'Extreme VR 2',
    'description': 'VR immersion',
    'id': 3,
  },
  {
    'title': 'Extreme VR',
    'description': 'VR immersion',
    'id': 4,
  },
  {
    'title': 'Meet cats',
    'categories': ['online'],
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

final sherlock = Sherlock(elements: activities);

/// Tests have to be run one by one, never all together because it's threaded
/// and they use the same [Sherlock] instance.
void main() {
  test('hello', () {
    assert(helloSherlock());
  });

  test('query', () {
    /// All activities where their title is the string 'Extreme VR'.
    sherlock.query(where: 'title', regex: r'^Extreme VR$');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

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
    sherlock.query(where: 'title', regex: r'cat', caseSensitive: true);
    sherlock.query(where: 'description', regex: r'cat');

    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities where at least one column's value contains the word 'vr'.
    sherlock.query(where: '*', regex: r'vr');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// Invalid query
    sherlock.query(where: 'id', regex: r'foo');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All elements with both words 'live' and 'stream' in their descriptions.
    sherlock.query(where: 'description', regex: r'(?=.*live)(?=.*stream).*');
    debugPrint(sherlock.results.toString());

    sherlock.forget();
  });

  test('queryExist', () {
    /// All activities where are monday is specified in the opening hours.
    sherlock.queryExist(where: 'openingHours', what: 'monday');
    debugPrint(sherlock.results.toString());

    sherlock.forget();
  });

  test('queryBool', () {
    /// All activities having a title which does not correspond to 'Parc'.
    sherlock.queryBool(where: 'title', fn: (value) => value != 'Parc');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities having at least one column's value corresponding to
    /// 'VR immersion'.
    sherlock.queryBool(where: '*', fn: (value) => value == 'VR immersion');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities having a title which correspond to 'Extreme VR'.
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities starting at 7'o on tuesday.
    sherlock.queryBool(
      where: 'openingHours',
      fn: (value) => value['tuesday'][0] == 7,
    );
    debugPrint(sherlock.results.toString());

    sherlock.forget();
  });

  test('queryMatch', () {
    /// All activities having a title corresponding to 'Parc'.
    sherlock.queryMatch(where: 'title', match: 'Parc');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities having a title corresponding to 'parc', no matter
    /// the case.
    sherlock.queryMatch(where: 'title', match: 'pArC', caseSensitive: true);
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities having at least one column's value corresponding to
    /// 'VR immersion'.
    sherlock.queryMatch(where: '*', match: 'VR immersion');
    debugPrint(sherlock.results.toString());

    sherlock.forget();
  });
}
