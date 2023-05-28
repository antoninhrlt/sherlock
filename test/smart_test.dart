import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/result.dart';
import 'package:sherlock/sherlock.dart';

import 'sherlock_test.dart';

void main() {
  test('uniqueSmartSearch', () async {
    var sherlock = Sherlock(elements: activities);

    var results = await sherlock.search(where: '*', input: 'cAtS');
    debugPrint(results.sorted().unwrap().toString());
  });

  test('smartSearch', () async {
    var sherlock = Sherlock(elements: activities);

    var results = await sherlock.search(where: '*', input: 'cAtS');
    debugPrint(results.sorted().unwrap().toString());

    results = await sherlock.search(where: '*', input: 'live online');
    debugPrint(results.sorted().unwrap().toString());

    results = await sherlock.search(where: ['title'], input: 'live online');
    debugPrint(results.sorted().unwrap().toString());

    results = await sherlock.search(where: '*', input: 'extreme Vr');
    debugPrint(results.sorted().unwrap().toString());

    results = await sherlock.search(where: ['title', 'categories'], input: 'cats');
    debugPrint(results.sorted().unwrap().toString());
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

  test('smartSearch2', () async {
    var sherlock = Sherlock(elements: activities2);

    var results = await sherlock.search(where: ['title'], input: 'fun surfing');
    debugPrint(results.sorted().unwrap().toString());

    results = await sherlock.search(where: ['title'], input: 'fun sarfing');
    debugPrint(results.sorted().unwrap().toString());

    results = await sherlock.search(where: ['title'], input: 'fun zarfing');
    debugPrint(results.sorted().unwrap().toString());

    results = await sherlock.search(where: ['title'], input: 'fon zarfing');
    debugPrint(results.sorted().unwrap().toString());

    results = await sherlock.search(where: ['title'], input: 'zarfing');
    debugPrint(results.sorted().unwrap().toString());
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

  test('stopWords', () async {
    var sherlock = Sherlock(elements: activities3);
    var results = await sherlock.search(where: ['title'], input: 'with the friends the');
    debugPrint(results.sorted().unwrap().toString());
  });
}
