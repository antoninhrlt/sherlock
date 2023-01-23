import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/types.dart';
import 'package:sherlock/sherlock.dart';

void main() {
  final activities = [
    {
      'title': 'Sport with Jimmy',
    },
    {
      'title': 'Gym in London',
      'description': 'Come and do sport !',
    },
    {
      'title': 'Skydiving',
      'categories': ['sport', 'extreme'],
    },
    {
      'title': 'Coding camp',
      'description': 'Let\'s code together',
      'categories': ['IT'],
    },
  ];

  test('priority', () {
    PriorityMap columnPriorities = {
      'title': 4,
      'categories': 3,
      'description': 2,
      '*': 1,
    };

    var sherlock = Sherlock(elements: activities, priorities: columnPriorities);
    sherlock.search(where: '*', input: 'sport');

    debugPrint(sherlock.results.toString());
  });

  test('priority2', () {
    PriorityMap columnPriorities = {
      'title': 3,
      'description': 3,
      '*': 1,
    };

    var sherlock = Sherlock(elements: activities, priorities: columnPriorities);
    sherlock.search(where: '*', input: 'sport');

    debugPrint(sherlock.results.toString());
  });
}
