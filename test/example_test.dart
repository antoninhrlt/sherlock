import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/sherlock.dart';

void main() {
  test('findUsersWithSpecificName', () {
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

    final sherlock = Sherlock(elements: users);
    sherlock.queryMatch(where: 'firstName', match: 'Suz');
    debugPrint(sherlock.results.toString());
  });

  test('findActivitiesRelatedToSport', () {
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
      }
    ];

    final sherlock = Sherlock(elements: activities);
    sherlock.query(where: '*', regex: r'sport');
    debugPrint(sherlock.results.toString());
  });
}
