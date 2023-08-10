<div align="center">

<img alt="sherlock logo" src="https://raw.githubusercontent.com/antoninhrlt/sherlock/main/assets/sherlock.svg" width="45%">

**sherlock** is a library to perform efficient and customized **searches** on local data, for [Flutter](https://flutter.dev).

It provides a search engine, a tool to complete search inputs and can be easily integrated in a search bar widget.

<img src="https://raw.githubusercontent.com/antoninhrlt/sherlock/main/assets/search_bar.gif" style="border-radius: 30px" width="45%">

Sherlock in the new [`SearchBar`](https://api.flutter.dev/flutter/material/SearchBar-class.html) widget ! (Flutter 3.10.0) \
See this example [here](example/search_bar/lib/main.dart).

[Usage](#usage) •
[Overview](#overview) •
[Completion tool](#search-completion-tool) •
[Examples](example/README.md)

</div>

<p align="center">

</p>


## Usage
Sherlock needs the elements in which it (he?) will search. Priorities can be specified for results sorting, but it is not mandatory.

```dart
final foo = [
  {
    'col1': 'foo',
    'col2': ['foo1', 'foo2'],
    'col3': <non-string value>,
  },
  // Other elements...
];

// The bigger it is, the more important it is. 
final priorities = {
  'col2': 4,
  'col1': 3,
  // '*': 1,
};

final sherlock = Sherlock(elements: foo, priorities: priorities);

var results = sherlock
    .query(where: '<column>', regex: r'<regex expression>')
    .sorted()
    .unwrap();
```

> Note : this package is designed for researches on local data retrieved after an API call or something. It avoids requiring Internet during the search.

See the [examples](example/README.md).

## Overview
See also the [search completion tool](#search-completion-tool).

- ### Quick Sherlock
  Use to execute any task with a unique `Sherlock` instance. The function parameters are constructed like the `Sherlock` constructor plus a callback in which tasks are executed.

  Prototype
  ```dart
  Future<List<Element>> processUnique(
    List<Element> elements,
    PriorityMap priorities = const {'*': 1},
    NormalizationSettings normalization = /* default */,
    void Function(Sherlock sherlock) queries,
  })
  ```
  Usage
  ```dart
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

  final results = await Sherlock.processUnique(
    elements: users,
    fn: (sherlock) async {
      final resultsName = sherlock.queryMatch(where: 'firstName', match: 'Finn');
      final resultsCity = sherlock.queryMatch(where: 'city', match: 'Edinburgh');
      return [...await resultsName, ...await resultsCity];
    },
  );
  ```

- ### Create a `Sherlock` instance.
  Prototype
  ```dart
  Sherlock(
    List<Map<String, dynamic>> elements, 
    Map<String, int> priorities = {'*': 1},
    NormalizationSettings normalization = /* defaults */
  )
  ```
  Usage
  ```dart
  /// Users with their first and last name, and the city where they live.
  /// They also have an ID.
  List<Map<String, dynamic>> users = [
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

  final sherlock = Sherlock(elements: users)
  ```
  Specifying `priorities` :
  ```dart
  // First and last name have the same priority.
  // The city is less important.
  // The default priority is `1`. 
  Map<String, int> priorities = [
    'firstName': 3,
    'lastName': 3,
    'city': 2,
  ];

  final sherlock = Sherlock(elements: users, priorities: priorities);
  ```
  Specifying `normalization` : 
  ```dart
  final normalization = NormalizationSettings(
    normalizeCase: true,
    normalizeCaseType: false,
    removeDiacritics: true,
  );

  final sherlock = Sherlock(elements: users, normalization: normalization);
  ```
- ### Priorities
  The priority map (also known as "priorities") is used to define the priority of each column. If there is no priority set for a column, the default priority will be used instead.

  The default priority value can be specified, otherwise it will be set to `1` :
  ```dart
  // The city is the least important.
  Map<String, int> priorities = [
    'firstName': 3,
    'lastName': 3,
    'city': 1,
    '*': 2,
  ];
  ``` 
- ### Normalization settings
  The normalization settings are used to define the type of normalization that will be performed on the strings during searches.

  Prototype
  ```dart
  NormalizationSettings normalization;
  ```
  ```dart
  /// Out of the [Sherlock] class.

  NormalizationSettings(
    // If `true` : case insensitive.
    // If `false` : case sensitive.
    bool normalizeCase,
    // If `true` : no matter if it is snake or camel cased.
    // If `false` : it matters to be snake or camel cased.
    bool normalizeCaseType,
    // If `true` : keeps the diacritics.
    // If `false` : remove all the diacritics.
    bool removeDiacritics,
  )
  ```
  
  These settings are only used by `query` and `queryMatch`. The [smart search](#smart-search) uses its own normalization settings, which is :
  ```dart
  NormalizationSettings(
    normalizeCase: true,
    normalizeCaseType: false,
    removeDiacritics: true,
  );
  ```

- ### Results
  Every query function returns its research findings. These results are returned as `List<Result>` and can be sorted thanks to the extension function `SortResults.sorted`, then unwrap thanks to the other extension function `UnwrapResults.unwrap` which returns a `List<Map>`.

  Import
  ```dart
  import 'package:sherlock/result.dart';
  ```

  Prototypes
  ```dart  
  class Result {
    Map<String, dynamic> element;
    int priority;
  }

  extension SortResults on List<Result> {
    List<Result> sorted();
  }

  extension UnwrapResults on List<Result> {
    List<Map<String, dynamic>> unwrap();
  }
  ```

  Usages
  
  Results are sorted following the `priorities` map.
  ```dart
  final sherlock = Sherlock(/*...*/);
  List<Result> results = (await sherlock./* query */).sorted();
  ```

  Unwrapping results means getting just the `element` object from the `Result` object.
  ```dart
  final sherlock = Sherlock(/*...*/);
  List<Result> results = (await sherlock./* query */).sorted();
  List<Map> foundElements = results.unwrap();
  ```

  > Note: Getting results unsorted means the results will be in the order they were found.

  Also, the results can be sorted at the end after all queries are done :
  ```dart
  final sherlock = Sherlock(/*...*/);

  final Future<List<Result>> results1 = sherlock./* query */;
  final Future<List<Result>> results2 = sherlock./* query */;

  final allResults = [...await results1, ...await results2].sorted();
  ```
- ### Queries
  Every query returns its research findings (results) but they are not sorted. Click [here](#results) to learn how to manage them.

  Prototypes
  ```dart
  Future<List<Result>> query(
    String where = '*', 
    String regex, 
    NormalizationSettings specificNormalization = /* this.normalization */,
  ) 
  ```
  Usage
  ```dart
  /// All elements having a title, which contains the word 'game' or 'vr'.
  sherlock.query(where: 'title', regex: r'(game|vr)');

  /// All elements with in at least one of their fields which contain the word 
  /// 'cat'.
  final catsResults = sherlock.query(regex: r'cat');

  /// All elements having a title, which is equal to 'movie theatre'.
  sherlock.query(where: 'title', regex: r'^Movie Theatre$');

  /// All elements having a title, which is equal to 'Movie Theatre', the case 
  /// matters.
  sherlock.query(
    where: 'title', 
    regex: r'^Movie Theatre$', 
    specificNormalization: NormalizationSettings(
      normalizeCase: false,
      // other normalization settings are the one of [this.normalization].
    )
  );

  /// All elements with both words 'world' and 'pretty' in their descriptions.
  sherlock.query(where: 'description', regex: r'(?=.*pretty)(?=.*world).*');
  ```
  Prototype
  ```dart
  /// Searches for elements where [what] exists (is not null) in the column [where].
  Future<List<Result>> queryExist(String where, String what)
  ```
  Usage
  ```dart
  /// All activities where monday is specified in the opening hours.
  sherlock.queryExist(where: 'openingHours', what: 'monday');
  ```
  Prototypes
  ```dart
  Future<List<Result>> queryBool(
    String where = '*', 
    bool Function(dynamic value) fn,
  )

  Future<List<Result>> queryMatch(
    String where = '*', 
    dynamic match,
    NormalizationSettings specificNormalization = /* this.normalization */,
  )
  ```
  Usages
  ```dart
  /// All activities having a title which does not correspond to 'Parc'.
  sherlock.queryBool(where: 'title', fn: (value) => value != 'Parc');

  /// All activities starting at 7'o on tuesday.
  sherlock.queryBool(
    where: 'openingHours',
    fn: (value) => value['tuesday'][0] == 7,
  );
  ```
  ```dart
  /// All activities having a title corresponding to 'Parc', the case matters.
  sherlock.queryMatch(
    where: 'title', 
    match: 'Parc',     
    specificNormalization: NormalizationSettings(
      normalizeCase: false,
      // other normalization settings are the one of [this.normalization].
    ),
  );
  ```
  ```dart
  /// All activities having a title corresponding to 'parc', no matter the case.
  sherlock.queryMatch(
    where: 'title', 
    match: 'pArC',     
    specificNormalization: NormalizationSettings(
      normalizeCase: true,
      // other normalization settings are the one of [this.normalization].
    ),
  );
  ```

- ### Smart search
  Prototype
  ```dart
  Future<List<Result>> search(
    dynamic where = '*', 
    String input,     
    List<String> stopWords = StopWords.en,
  )
  ```
  Usages

  Perfect matches are searched first, it means they will be on top of the results if they exist.
  ```dart
  /// All elements having at least one of their field containing the word 'cats'
  sherlock.search(input: 'cAtS');
  /// Elements having their title or their categories containing the word 'cat'
  sherlock.search(where: ['title', 'categories'], input: 'cat');
  ```

## Search completion tool
When doing searches from an user's input, it might be useful to help them completing their search. That's why `SherlockCompletion` exists.

The results could be used in a search widget for example.

## Overview
- ### Create a `SherlockCompletion` instance
  Prototype
  ```dart
  SherlockCompletion(
    String where, 
    List<Map<String, dynamic>> elements,
  )
  ```
  Usage
  ```dart
  final places = [
    {
      'name': 'Africa discovery',
    },
    {
      'name': 'Fruits and vegetables market',
      'description': 'A cool place to buy fruits and vegetables',
    },
    {
      'name': 'Fresh fish store',
    },
    {
      'name': 'Ball pool',
    },
    {
      'name': 'Finland discovery',
    },
  ];

  final completer = SherlockCompletion(where: 'name', elements: places);
  ```
- ### Input
  Prototype
  ```dart
  Future<List<Result>> input(
    String input,
    bool caseSensitive = false,
    bool? caseSensitiveFurtherSearches,
    int minResults = -1,
    int maxResults = -1,
  )
  ```
  Usage
  ```dart
  // Find all the elements with names starting with 'fr'.
  await completer.input(input: 'fr');

  // Find all the elements with names starting with 'Fr', and the case matters.
  await completer.input(input: 'Fr', caseSensitive: true);  
  ```
  ```
  [Fruits and vegetables market, Fresh fish store]
  [Fruits and vegetables market, Fresh fish store]
  ```
  ```dart
  // Try to find at least 4 elements with names matching with 'fr'.
  await completer.input(input: 'fr', minResults: 4);

  // Try to find at least 3 elements with names matching with 'Fr', and the 
  // case matters only for the searches that might be performed if there is 
  // less than 3 results.
  await completer.input(
    input: 'Fr', 
    minResults: 3, 
    caseSensitiveFurtherSearches: true,
  );
  ```
  ```
  [Fruits and vegetables market, Fresh fish store, Best place to find fruits, Museum of Africa]
  [Fruits and vegetables market, Fresh fish store]
  ```
  ```dart
  // Find maximum 1 name matching with 'fr'.
  completion.input(input: 'fr', maxResults: 1);
  ```
  ```
  [Fruits and vegetables market]
  ```
  **Important note**: as you can see in the prototype, the `input` function 
  retuerns a list of `Result`, not strings. To print the output seen above, the 
  following has been done:
  ```dart
  final results = await completer.input(...);
  // Only get the completion strings from the results.
  final stringResults = completer.getStrings(fromResults: results);
  debugPrint(stringResults.toString());
  ```
- ### Results
  Prototypes
  ```dart
  Future<List<String>> getStrings(
    List<Result> fromResults
  );
  ```
  Usage
  ```dart
  List<Result> results = await completion.input(input: 'fr'));
  List<String> resultNames = await completer.getStrings(fromResults: results);
  print('names: $resultNames');
  ```
  ```
  names: [Fruits and vegetables market, Fresh fish store]
  ```

- ### Unchanged ranges of the string results
  Prototype
  ```dart
  Future<List<Range>> unchangedRanges({
    String input,
    List<String> results,
  )
  ```
  ```dart
  class Range {
    int start;
    int end;
  }
  ```
  Usage

  This can be used to highlight the unchanged part while displaying the possible completions.
  
  What it could look like :
  <p align="center">
    <img src="example/widget_completion.png" height="176"/>
  </p>

  ```dart
  const input = 'Fr';
  final results = await completer.input(input: input, minResults: 4);
  final stringResults = completer.getStrings(fromResults: results);

  // The case is ignored.
  List<Range> unchangedRanges = await completer.unchangedRanges(
    input: input, 
    results: stringResults,
  );

  print(results);
  print(unchangedRanges);
  ```
  ```
  [Fruits and vegetables market, Fresh fish store, Best place to find fruits, Museum of Africa]
  [[0, 2], [0, 2], [19, 21], [11, 13]]
  ```