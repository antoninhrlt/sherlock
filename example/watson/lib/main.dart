import 'package:flutter/material.dart';
import 'package:sherlock/sherlock.dart';
import 'package:sherlock/widget/watson.dart';

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

  runApp(
    MaterialApp(
      title: 'Watson search bar demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WatsonSearchBar Demo'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
          child: WatsonSearchBar(
            onSubmit: (submittedText) {
              sherlock.search(input: submittedText);
              debugPrint('(results) ${sherlock.results}');
              return sherlock;
            },
            onTextChanged: (textChanged) {
              debugPrint('(textChanged) $textChanged');
            },
            buildResults: (sherlock) => Results(sherlock: sherlock),
            hintText: 'Search an activity',
            iconize: true,
            initiallyIconized: true,
          ),
        ),
      ),
    ),
  );
}

class Results extends StatelessWidget {
  final Sherlock sherlock;

  const Results({
    super.key,
    required this.sherlock,
  });

  @override
  Widget build(BuildContext context) {
    List<Result> results = [];
    debugPrint('result: ${results}');

    for (final result in sherlock.results) {
      results.add(Result(result: result));
    }

    return Column(children: results);
  }
}

class Result extends StatelessWidget {
  final Map<String, dynamic> result;

  const Result({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(result['title']),
          Text(result['description']),
        ],
      ),
    );
  }
}
