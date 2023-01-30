# sherlock
Collection of search and smart search functions, for local data and given priorities

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
sherlock.query(where: '<column>', regex: r'<regex expression>');

List<Map> results = sherlock.results;
sherlock.forget(); // clear the results

// Other queries...
```

> Note : this package is designed for searches in local data retrieved after an API call or something. It avoids requiring Internet during the search.

See the [examples](#examples).

## Overview
- ### Create a `Sherlock` instance.
  Prototype
  ```dart
  Sherlock(
    List<Map<String, dynamic>> elements, 
    Map<String, int> priorities = {'*': 1},
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

- ### Results
  Performed queries add the matching elements to the field `unsortedResults`, which can be used to get the results as `Result` objects.

  After that, the results can be retrieved sorted and unwrapped.

  Prototypes
  ```dart
  List<Map<String, dynamic>> get results; // sorted results
  List<Result> unsortedResults;

  void forget(); // resets the results
  ```
  ```dart
  /// Out of the [Sherlock] class.
  
  class Result {
    Map<String, dynamic> element;
    int priority;
  }

  List<Result> sortResults(List<Result> unsortedResults);

  extension UnwrapResults on List<Result> {
    List<Map<String, dynamic>> unwrap();
  }
  ```

  Usages
  
  Results sorted following the `priorities` map.
  ```dart
  final sherlock = Sherlock(/*...*/);
  // Queries...
  final results = sherlock.results;
  ```
  Getting results unsorted means the results will be in the order they were found. Each `Result` contain the actual result (an element matching with the query) and its priority.
  ```dart
  final sherlock = Sherlock(/*...*/);
  // Queries...
  final results = sherlock.unsortedResults;
  ```
  Also, the results can be sorted later :
  ```dart
  final unsortedResults = sherlock.unsortedResults;
  final results = sortResults(unsortedResults);
  ```
  But also unwrapped, in order to get elements instead of `Result` objects.
    ```dart
  final results = sortResults(unsortedResults).unwrap();
  ```
  Reset the values to perform new unrelated queries.
  ```dart
  final sherlock = Sherlock(/*...*/);
  // Queries...
  final results = sherlock.results; // save the results.
  sherlock.forget(); // `sherlock.results == []`.
  // Queries...
  ```
- ### Queries
  Prototypes
  ```dart
  void query(String where, String regex, bool caseSensitive = false) 
  ```
  Usages
  ```dart
  /// All elements having a title, which contains the word 'game' or 'vr'.
  sherlock.query(where: 'title', regex: r'(game|vr)');

  /// All elements with in at least one of their fields which contain the word 
  /// 'cat'.
  sherlock.query(where: '*', regex: r'cat');

  /// All elements having a title, which is equal to 'movie theatre'.
  sherlock.query(where: 'title', regex: r'^Movie Theatre$');
  /// All elements having a title, which is equal to 'Movie Theatre', the case 
  /// matter.
  sherlock.query(where: 'title', regex: r'^Movie Theatre$', caseSensitive: true);

  /// All elements with both words 'world' and 'pretty' in their descriptions.
  sherlock.query(where: 'description', regex: r'(?=.*pretty)(?=.*world).*');
  ```
  Prototype
  ```dart
  /// Searches for elements where [what] exists (is not null) in the column [where].
  void queryExist(String where, String what)
  ```
  Usage
  ```dart
  /// All activities where monday is specified in the opening hours.
  sherlock.queryExist(where: 'openingHours', what: 'monday');
  ```
  Prototypes
  ```dart
  void queryBool(String where, bool Function(dynamic value) fn)

  void queryMatch(String where, dynamic match) {
    queryBool(where: where, fn: (value) => value == match);
  }
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
  sherlock.queryMatch(where: 'title', match: 'Parc');
  ```
  ```dart
  /// All activities having a title corresponding to 'parc', no matter the case.
  sherlock.queryMatch(where: 'title', match: 'pArC', caseSensitive: false);
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
