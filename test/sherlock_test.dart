import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/normalize.dart';
import 'package:sherlock/result.dart';
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
  test('query', () {
    /// All activities where their title is the string 'Extreme VR'.
    final results1 = sherlock.query(where: 'title', regex: r'^Extreme VR$').sorted().unwrap();
    debugPrint(results1.toString());

    /// All activities where their title contains the word 'vr'.
    final results2 = sherlock.query(where: 'title', regex: r'vr').sorted().unwrap();
    debugPrint(results2.toString());

    /// All activities where their title contains the word 'live' or 'vr'.
    final results3 = sherlock.query(where: 'title', regex: r'(live|vr)').sorted().unwrap();
    debugPrint(results3.toString());

    /// All activities where their description contains the word 'live'.
    final results4 = sherlock.query(where: 'description', regex: r'(live)').sorted().unwrap();
    debugPrint(results4.toString());

    /// All activities where their description or title contains the word 'cat'.
    List<Result> results5 = sherlock.query(where: 'title', regex: r'cat');
    results5 += sherlock.query(where: 'description', regex: r'cat');

    final results5_2 = results5.sorted().unwrap();

    debugPrint(results5_2.toString());

    /// All activities where at least one column's value contains the word 'vr'.
    final results6 = sherlock.query(where: '*', regex: r'vr').sorted().unwrap();
    debugPrint(results6.toString());

    /// Invalid query
    final results7 = sherlock.query(where: 'id', regex: r'foo').sorted().unwrap();
    debugPrint(results7.toString());

    /// All elements with both words 'live' and 'stream' in their descriptions.
    final results8 = sherlock.query(where: 'description', regex: r'(?=.*live)(?=.*stream).*').sorted().unwrap();
    debugPrint(results8.toString());
  });

  test('queryExist', () {
    /// All activities where are monday is specified in the opening hours.
    final results = sherlock.queryExist(where: 'openingHours', what: 'monday').sorted().unwrap();
    debugPrint(results.toString());
  });

  test('queryBool', () {
    /// All activities having a title which does not correspond to 'Parc'.
    final results1 = sherlock.queryBool(where: 'title', fn: (value) => value != 'Parc').sorted().unwrap();
    debugPrint(results1.toString());

    /// All activities having at least one column's value corresponding to
    /// 'VR immersion'.
    final results2 = sherlock.queryBool(where: '*', fn: (value) => value == 'VR immersion').sorted().unwrap();
    debugPrint(results2.toString());

    /// All activities starting at 7'o on tuesday.
    final results3 = sherlock
        .queryBool(
          where: 'openingHours',
          fn: (value) => value['tuesday'][0] == 7,
        )
        .sorted()
        .unwrap();

    debugPrint(results3.toString());
  });

  test('queryMatch', () {
    final sherlock = Sherlock(
      elements: activities,
      normalization: const NormalizationSettings.matching(),
    );

    /// All activities having a title corresponding to 'Parc'.
    final results1 = sherlock.queryMatch(where: 'title', match: 'Parc').sorted().unwrap();
    debugPrint(results1.toString());

    /// All activities having a title corresponding to 'parc', no matter
    /// the case.
    final results2 = sherlock
        .queryMatch(
          where: 'title',
          match: 'pArC',
          specificNormalization: const NormalizationSettings(
            normalizeCase: true,
            normalizeCaseType: false,
            removeDiacritics: false,
          ),
        )
        .sorted()
        .unwrap();
    debugPrint(results2.toString());

    /// All activities having at least one column's value corresponding to
    /// 'VR immersion'.
    final results3 = sherlock.queryMatch(where: '*', match: 'VR immersion').sorted().unwrap();
    debugPrint(results3.toString());
  });

  test('where', () {
    sherlock.query(regex: r'');
    try {
      sherlock.search(where: 5, input: '');
    } catch (e) {
      debugPrint(e.toString());
    }
    try {
      sherlock.search(where: 'foo', input: '');
    } catch (e) {
      debugPrint(e.toString());
    }
  });
}
