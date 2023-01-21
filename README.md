# sherlock
Search engine for Flutter. Search in a map list with regular expressions or by smart search for user search

## Usage
Sherlock needs the elements in which he will search.
A priorities map can be specified for results sorting, but it is not mandatory.
```dart
final foo = [
    {
        'col1': 'foo',
        'col2': ['foo1', 'foo2'],
        'col3': <non-string value>,
    },
    // Other elements...
];

/// The bigger it is, the more important it is. 
final priorities = {
  'col2': 4,
  'col1': 3,
  '*': 1, // all others
};

final sherlock = Sherlock(elements: foo, priorities: priorities);
sherlock.query(where: '<column>', regex: r'<regex expression>');

List<Map> results = sherlock.results;
sherlock.forget(); // clear the results

// Other queries...
```

See the [examples](#examples).

## Overview
- ### Create a `Sherlock` instance.
  Prototype
  ```dart
  Sherlock(
    List<Map<String, dynamic>> elements, 
    Map<String, int> priorities = const {'*': 1},
  )
  ```
  Usages
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
  Specifying a `priorities` map :
  ```dart
  // First and last name have the same importance.
  // The city is less important.
  // Default importance is `1`. 
  Map<String, int> priorities = [
    'firstName': 3,
    'lastName': 3,
    'city': 2,
    '*': 1,
  ];

  final sherlock = Sherlock(elements: users, priorities: priorities);
  ```
- ### Results
  Performed queries add the matching elements to the private field `_unsortedResults`.
  After that, the results can be retrieved sorted or unsorted

  Prototypes
  ```dart
  List<Map<String, dynamic>> get results; // sorted results
  List<Map<String, dynamic>> get unsortedResults;

  void forget(); // resets the results
  ```
  Usages
  Results sorted following the `priorities` map.
  ```dart
  final sherlock = Sherlock(/*...*/);
  // Queries...
  final results = sherlock.results;
  ```
  Getting results unsorted mean the `priorities` are completely ignored.
  ```dart
  final sherlock = Sherlock(/*...*/);
  // Queries...
  final results = sherlock.unsortedResults;
  ```
  Reset the values to perform new unrelated queries.
  ```dart
  final sherlock = Sherlock(/*...*/);
  // Queries...
  final results = sherlock.results; // save the results.
  sherlock.forget(); // `sherlock.results` == `{}`.
  // Queries...
  ```
- ### Queries
  Prototypes/Definitions
  ```dart
  void query(
    String where,
    String regex,
    bool caseSensitive = false,
  ) {
    queryContain(where, regex, caseSensitive);
  }

  void queryContain(
    String where,
    String regex,
    bool caseSensitive = false,
  )

  void queryExist(
    String where, 
    String what
  )
  
  void queryBool(
    String where,
    bool Function(dynamic value) fn,
  )

  void queryMatch(String where, dynamic match) {
    queryBool(where: where, fn: (value) => value == match);
  }
  ```
  Usages
  ```dart
  /// All elements where their title contains the word 'game' or 'vr'.
  sherlock.query(where: 'title', regex: r'(game|vr)');

  /// All elements with 'cat' in at least one of their fields.
  sherlock.query(where: '*', regex: r'cat');
  ```
  ```dart
  /// All activities where monday is specified in the opening hours.
  sherlock.queryExist(where: 'openingHours', what: 'monday');
  ```
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
  /// All activities having a title corresponding to 'Parc'.
  sherlock.queryMatch(where: 'title', match: 'Parc');
  ```

- Smart search
  Prototype
  ```dart
  void search(dynamic where, String input)
  ```

  Usages
  
  Perfect matches are searched first, it means they will be on top of the `results` if they exist.
  ```dart
  /// All elements having at least one of their field containing the word 'cats'
  sherlock.search(where: '*', input: 'cAtS');
  /// Elements having their title or their categories containing the word 'cat'
  sherlock.search(where: ['title', 'categories'], input: 'cat');
  ```

## Examples

- ## Find users with a specific name
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
    ```
    ```dart
    final sherlock = Sherlock(elements: users);
    sherlock.queryMatch(where: 'firstName', match: 'Suz');

    print(sherlock.results);
    ```
    ```
    [
      {
        firstName: Suz, 
        lastName: Judy, 
        city: Paris, 
        id: 2
      }, 
      {
        firstName: Suz, 
        lastName: Crystal, 
        city: Edinburgh, 
        id: 3
      }
    ]
    ```
- ## Find activities related to sport
    ```dart
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
      },
    ];
    ```
    ```dart
    final sherlock = Sherlock(elements: activities);
    sherlock.query(where: '*', regex: r'sport');
    print(sherlock.results);
    ```
    ```
    [
      {
        title: Sport with Jimmy
      }, 
      {
        title: Gym in London, 
        description: Come and do sport !
      }, 
      {
        title: Skydiving, 
        categories: [sport, extreme]
      }
    ]
    ```

    Find more examples in the [tests](test/) !
