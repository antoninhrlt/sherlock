# sherlock
Search engine for Flutter. Search in a map list with regular expressions or by smart search for user search

## Usage
```dart
final foo = [
    {
        'foo1': 'bar',
        'foo2': ['bar1', 'bar2'],
        'foo3': <non-string value>,
    },
    // Other elements...
];

final sherlock = Sherlock(elements: foo);
sherlock.query(where: '<column>', regex: r'<regex expression>');

List<Map> results = sherlock.results;
sherlock.forget(); // clear the results

// Other queries...
```

## Example

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
        'description': 'Paris',
        'id': 2,
    },
    {
        'firstName': 'Suz',
        'lastName': 'Crystal',
        'description': 'Edinburgh',
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
    debugPrint(sherlock.results.toString());
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

    Find more examples in [tests](test/sherlock_test.dart) !
