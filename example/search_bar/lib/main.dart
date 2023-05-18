import 'package:flutter/material.dart';
import 'package:sherlock/completion.dart';
import 'package:sherlock/result.dart';
import 'package:sherlock/sherlock.dart';
import 'package:sherlock/widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SherlockSearchBar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ExampleView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExampleView extends StatefulWidget {
  ExampleView({super.key});

  final List<Map<String, dynamic>> users = [
    {
      'name': 'Finn Thornton',
      'city': 'Edinburgh',
    },
    {
      'name': 'Suz Judy',
      'city': 'Paris',
    },
    {
      'name': 'Suz Crystal',
      'city': 'Edinburgh',
    },
  ];

  @override
  State<StatefulWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleView> {
  List<Map<String, dynamic>> results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SherlockSearchBar(
              sherlock: Sherlock(elements: widget.users),
              sherlockCompletion: SherlockCompletion(where: 'name', elements: widget.users),
              onSearch: (input, sherlock) {
                setState(() {
                  results = sherlock.search(input: input).sorted().unwrap();
                });
              },
            ),
            ...results.map((e) => UserCard(user: e)),
          ],
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 12, 12, 0),
            child: Icon(
              Icons.person,
              size: 52,
            ),
          ),
          Text(
            user['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(Icons.location_city),
          Text(user['city']),
        ],
      ),
    );
  }
}
