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

  final List<Map<String, dynamic>> characters = [
    {
      'name': 'Jiji',
      'description': 'Black cat with large white eyes and black pupils',
      'from': 'Kiki\'s delivery service',
      'by': 'Studio Ghibli',
      'image': 'https://i.pinimg.com/originals/10/f5/b8/10f5b8f9a07cbebd069fe90e0c8417c9.jpg',
    },
    {
      'name': 'Haku',
      'description': 'He has straight, dark green hair in a bob haircut and slanted, green eyes',
      'from': 'Spirited Away',
      'by': 'Studio Ghibli',
      'image': 'https://i.pinimg.com/736x/21/72/ff/2172ff97bf332adb0c2c003fa2746688.jpg',
    },
    {
      'name': 'Soot Sprites',
      'description': 'They are small, round balls made from the soot that dwells in old and abandoned houses',
      'from': 'My Neighbor Totoro',
      'by': 'Studio Ghibli',
      'image':
          'https://media0.giphy.com/media/oje6kPRIef6Gk/200.gif?cid=6c09b952152c6g4ft5pmn8bgv6knnhnx8mqvac8mu37xmzlx&ep=v1_gifs_search&rid=200.gif&ct=g',
    },
  ];

  @override
  State<StatefulWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleView> {
  List<Map<String, dynamic>> _results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SherlockSearchBar(
              isFullScreen: true,
              sherlock: Sherlock(elements: widget.characters),
              sherlockCompletion: SherlockCompletion(where: 'by', elements: widget.characters),
              sherlockCompletionMinResults: 1,
              onSearch: (input, sherlock) {
                setState(() {
                  _results = sherlock.search(input: input).sorted().unwrap();
                });
              },
              completionsBuilder: (context, completions) => SherlockCompletionsBuilder(
                completions: completions,
                buildCompletion: (completion) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(
                        completion,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.check),
                      const Icon(Icons.close)
                    ],
                  ),
                ),
              ),
            ),
            if (_results.isNotEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 0, 0),
                child: Text(
                  'Results',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ..._results.map((e) => CharacterCard(character: e)),
          ],
        ),
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  final Map<String, dynamic> character;

  const CharacterCard({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Image.network(
                  character['image'],
                  width: 65,
                  height: 65,
                ),
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        character['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' by ${character['by']}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    character['description'],
                    overflow: TextOverflow.clip,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(3, 0, 8, 0),
              child: VerticalDivider(
                color: Colors.black,
                thickness: 0.2,
                width: 1,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.movie),
                Text(
                  character['from'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
