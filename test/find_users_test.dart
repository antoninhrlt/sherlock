import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/result.dart';
import 'package:sherlock/sherlock.dart';

void main() {
  final users = [
    {
      'firstName': 'Finn',
      'lastName': 'Thornton',
      'city': 'Edinburgh',
      'id': 1,
    },
    {
      'firstName': 'Suz',
      'lastName': 'Judy',
      'city': 'Paris',
      'id': 2,
    },
    {
      'firstName': 'Suz',
      'lastName': 'Crystal',
      'city': 'Edinburgh',
      'id': 3,
    },
  ];

  test('findUsers', () async {
    final sherlock = Sherlock(elements: users);
    final results = await sherlock.search(where: ['firstName'], input: 'f');
    debugPrint('results: ${results.sorted().unwrap()}');
  });
}
