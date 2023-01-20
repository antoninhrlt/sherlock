import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/sherlock.dart';

void main() {
  test('hello', () {
    assert(helloSherlock());
  });

  test('seek', () {
    final activities = [
      {
        'title': 'Surf',
        'description': 'Live the wave',
        'id': 1,
      },
      {
        'title': 'LiveStream',
        'description': 'Watch live streams',
        'id': 4,
      },
      {
        'title': 'Extreme VR',
        'description': 'VR immersion',
        'id': 2,
      },
      {
        'title': 'Extreme VR 2',
        'description': 'New VR immersion',
        'id': 3,
      }
    ];

    final sherlock = Sherlock(elements: activities);

    /// All activities where their title contains the word 'vr'.
    sherlock.query(where: 'title', regex: r'vr');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities where their title contains the word 'live' or 'vr'.
    sherlock.query(where: 'title', regex: r'(live|vr)');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    /// All activities where at least one column's value contains the word 'vr'.
    //sherlock.query(where: '*', what: 'vr');
    //debugPrint(sherlock.results.toString());
  });
}
