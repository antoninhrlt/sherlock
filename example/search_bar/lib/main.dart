import 'package:flutter/material.dart';
import 'package:sherlock/sherlock.dart';

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
        fontFamily: 'monospace',
      ),
      home: MyHomePage(title: ''),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  final List<Map<String, dynamic>> users = [
    {
      'firstName': 'Finn',
      'lastName': 'Thornton',
      'city': 'Edinburgh',
      'id': 1, // other types than string can be used.
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
      'hobbies': ['sport', 'programming'], // string lists can be used.
      'id': 3,
    },
  ];

  @override
  State<StatefulWidget> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  SearchController controller = SearchController();
  Sherlock? sherlock;
  var results = [];

  @override
  void initState() {
    super.initState();

    sherlock = Sherlock(elements: widget.users);

    controller.addListener(() {
      sherlock!.search(where: ['firstName'], input: controller.text);
      results = sherlock!.results;
      sherlock!.forget();
      debugPrint('results for \'${controller.text}\' : $results');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: SearchAnchor.bar(
          barHintText: 'Search user',
          isFullScreen: false,
          searchController: controller,
          suggestionsBuilder: (context, controller) {
            return results.map((e) => UserCard(user: e)).toList();
          },
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user['firstName'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                user['lastName'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.location_city),
          Text(user['city']),
        ],
      ),
    );
  }
}
