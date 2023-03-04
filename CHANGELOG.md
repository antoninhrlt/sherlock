- # 0.1.0
  First actual release of the project. Description updated.
- # 0.0.15
  Levenshtein algorithm no longer used for the "starts with" query in smart 
  search.
- # 0.0.14
  Fix bug when the input length is greater than column value length.
- # 0.0.13
  Ameliorate the relevance of the search completion. Implement the stop-words.
- # 0.0.12
  Optional specific normalization for `query` and `queryMatch`. The Levenshtein 
  algorithm is now used in the smart search.
- # 0.0.11
  Levenshtein algorithm implemented but not used yet. Strings normalization 
  added. Completion for search input added.
- # 0.0.10
  Information about the priorities now clarified. Documentation improved about 
  the results. Function `sortResults` moved to the "result.dart" file.
- # 0.0.9
  Function to sort the results added. Type or value error for `where` is now 
  explicit. Move the examples to the "example" folder.
- # 0.0.8
  Query function `queryContain` removed. Make `query` more relevant in its way 
  to search. Results management updated.
- # 0.0.7
  Parameter `where` now optional in query functions. Fix a bug.
- # 0.0.6
  Wrong condition for type checking fixed.
- # 0.0.5
  Buggy change undone
- # 0.0.4
  Parameter `*` no longer mandatory in the priority map (default = 1). Smart 
  search improved for perfect mach with input.
- # 0.0.3
  Results sorted from the given priority map.
- # 0.0.2
  Parameter `where` now required for the smart search.
- # 0.0.1
  Package creation on [pub.dev](https://pub.dev/)
