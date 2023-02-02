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
    }
  ];

  final sherlock = Sherlock(elements: activities);
  sherlock.query(where: '*', regex: r'sport');
}
