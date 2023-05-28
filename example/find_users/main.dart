import 'package:flutter/material.dart';
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

  final sherlock = Sherlock(elements: users);
  sherlock
      .queryMatch(where: 'firstName', match: 'Suz')
      .then((results) => debugPrint('Found users: ${results.sorted().unwrap()}'));
}
