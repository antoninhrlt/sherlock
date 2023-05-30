import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
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
  test('queryUnique', () async {
    final results = await Sherlock.processUnique(
      elements: activities,
      fn: (sherlock) async {
        final resultsName = sherlock.queryMatch(where: 'firstName', match: 'Finn');
        final resultsCity = sherlock.queryMatch(where: 'city', match: 'Edinburgh');
        return [...await resultsName, ...await resultsCity];
      },
    );
  });

  test('query', () async {
    /// All activities where their title is the string 'Extreme VR'.
    final results1 = await sherlock.query(where: 'title', regex: r'^Extreme VR$');
    debugPrint(results1.sorted().unwrap().toString());

    /// All activities where their title contains the word 'vr'.
    final results2 = await sherlock.query(where: 'title', regex: r'vr');
    debugPrint(results2.sorted().unwrap().toString());

    /// All activities where their title contains the word 'live' or 'vr'.
    final results3 = await sherlock.query(where: 'title', regex: r'(live|vr)');
    debugPrint(results3.sorted().unwrap().toString());

    /// All activities where their description contains the word 'live'.
    final results4 = await sherlock.query(where: 'description', regex: r'(live)');
    debugPrint(results4.sorted().unwrap().toString());

    /// All activities where their description or title contains the word 'cat'.
    List<Result> results5 = await sherlock.query(where: 'title', regex: r'cat');
    results5 += await sherlock.query(where: 'description', regex: r'cat');

    final results5_2 = results5.sorted().unwrap();

    debugPrint(results5_2.toString());

    /// All activities where at least one column's value contains the word 'vr'.
    final results6 = await sherlock.query(where: '*', regex: r'vr');
    debugPrint(results6.sorted().unwrap().toString());

    /// Invalid query
    final results7 = await sherlock.query(where: 'id', regex: r'foo');
    debugPrint(results7.sorted().unwrap().toString());

    /// All elements with both words 'live' and 'stream' in their descriptions.
    final results8 = await sherlock.query(where: 'description', regex: r'(?=.*live)(?=.*stream).*');
    debugPrint(results8.sorted().unwrap().toString());
  });

  test('queryExist', () async {
    /// All activities where are monday is specified in the opening hours.
    final results = await sherlock.queryExist(where: 'openingHours', what: 'monday');
    debugPrint(results.sorted().unwrap().toString());
  });

  test('queryBool', () async {
    /// All activities having a title which does not correspond to 'Parc'.
    final results1 = await sherlock.queryBool(where: 'title', fn: (value) => value != 'Parc');
    debugPrint(results1.sorted().unwrap().toString());

    /// All activities having at least one column's value corresponding to
    /// 'VR immersion'.
    final results2 = await sherlock.queryBool(where: '*', fn: (value) => value == 'VR immersion');
    debugPrint(results2.sorted().unwrap().toString());

    /// All activities starting at 7'o on tuesday.
    final results3 = await sherlock.queryBool(
      where: 'openingHours',
      fn: (value) => value['tuesday'][0] == 7,
    );

    debugPrint(results3.sorted().unwrap().toString());
  });

  test('queryMatch', () async {
    final sherlock = Sherlock(
      elements: activities,
      normalization: const NormalizationSettings.matching(),
    );

    /// All activities having a title corresponding to 'Parc'.
    final results1 = await sherlock.queryMatch(where: 'title', match: 'Parc');
    debugPrint(results1.sorted().unwrap().toString());

    /// All activities having a title corresponding to 'parc', no matter
    /// the case.
    final results2 = await sherlock.queryMatch(
      where: 'title',
      match: 'pArC',
      specificNormalization: const NormalizationSettings(
        normalizeCase: true,
        normalizeCaseType: false,
        removeDiacritics: false,
      ),
    );
    debugPrint(results2.sorted().unwrap().toString());

    /// All activities having at least one column's value corresponding to
    /// 'VR immersion'.
    final results3 = await sherlock.queryMatch(where: '*', match: 'VR immersion');
    debugPrint(results3.sorted().unwrap().toString());
  });

  test('where', () async {
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
