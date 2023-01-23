import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/sherlock.dart';

import 'sherlock_test.dart';

void main() {
  test('smartSearch', () {
    var sherlock = Sherlock(elements: activities);

    sherlock.search(where: '*', input: 'cAtS');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    sherlock.search(where: '*', input: 'live online');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    sherlock.search(where: '*', input: 'extreme Vr');
    debugPrint(sherlock.results.toString());

    sherlock.forget();

    sherlock.search(where: ['title', 'categories'], input: 'cats');
    debugPrint(sherlock.results.toString());

    sherlock.forget();
  });

  final activities2 = [
    {
      'title': 'Surfing',
    },
    {
      'title': 'Amazing and fun surfing with friends',
    },
    {
      'title': 'Fun surfing',
    },
  ];

  test('smartSearch2', () {
    var sherlock = Sherlock(elements: activities2);
    sherlock.search(where: ['title'], input: 'fun surfing');
    debugPrint(sherlock.results.toString());
  });
}
