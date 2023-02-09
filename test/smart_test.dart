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

    sherlock.search(where: ['title'], input: 'live online');
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
    sherlock.forget();

    sherlock.search(where: ['title'], input: 'fun sarfing');
    debugPrint(sherlock.results.toString());
    sherlock.forget();

    sherlock.search(where: ['title'], input: 'fun zarfing');
    debugPrint(sherlock.results.toString());
    sherlock.forget();

    sherlock.search(where: ['title'], input: 'fon zarfing');
    debugPrint(sherlock.results.toString());
    sherlock.forget();

    sherlock.search(where: ['title'], input: 'zarfing');
    debugPrint(sherlock.results.toString());
    sherlock.forget();
  });

  final activities3 = [
    {
      'title': 'The park of fun',
    },
    {
      'title': 'Amazing and fun surfing for friends',
    },
    {
      'title': 'Fun surfing',
    },
    {
      'title': 'With friends',
    },
    {
      'title': 'Friends TV show',
    },
    {
      'title': 'F',
    },
  ];

  test('stopWords', () {
    var sherlock = Sherlock(elements: activities3);
    sherlock.search(where: ['title'], input: 'with the friends the');

    debugPrint(sherlock.results.toString());
    sherlock.forget();
  });
}
