| Example | Information |
| -- | -- |
| 0.0.0 ✔ | You can use it properly :) |
| 0.0.0 ▲ | An upper version is recommended, but this version can be used properly |
| 0.0.0 🛇 | Version that should never have been published as this, it contains bugs or it is incorrect |

- # 0.2.1 ✔
  Completion results now as `Result`s or strings.
- # 0.2.0 ✔
  Everything now asynchronous. Most variables finalised. Declarative way.  
- # 0.1.7 ✔
  Fix duplicates bug, issue #6
- # 0.1.6 🛇
  Results are now returned by each function, and not stored by the `Sherlock` 
  object. See the README.md for new usages.
- # 0.1.5 ▲
  New widget `SherlockSearchBar` using the new `SearchBar` widget for quick 
  integration. Update of the example.
- # 0.1.4 ▲
  Just update the README.md.
- # 0.1.3 ▲
  Some fixes and example using the new `SearchBar` widget.
- # 0.1.2 🛇
  Introduce flexible regex for smart search.
- # 0.1.1 🛇
  Description updated in the "README.md" file too.
- # 0.1.0 🛇
  First actual release of the project. Description updated.
- # 0.0.15 🛇
  Levenshtein algorithm no longer used for the "starts with" query in smart 
  search.
- # 0.0.14 🛇
  Fix bug when the input length is greater than column value length.
- # 0.0.13 🛇
  Ameliorate the relevance of the search completion. Implement the stop-words.
- # 0.0.12 🛇
  Optional specific normalization for `query` and `queryMatch`. The Levenshtein 
  algorithm is now used in the smart search.
- # 0.0.11 🛇
  Levenshtein algorithm implemented but not used yet. Strings normalization 
  added. Completion for search input added.
- # 0.0.10 🛇
  Information about the priorities now clarified. Documentation improved about 
  the results. Function `sortResults` moved to the "result.dart" file.
- # 0.0.9 🛇
  Function to sort the results added. Type or value error for `where` is now 
  explicit. Move the examples to the "example" folder.
- # 0.0.8 🛇
  Query function `queryContain` removed. Make `query` more relevant in its way 
  to search. Results management updated.
- # 0.0.7 🛇
  Parameter `where` now optional in query functions. Fix a bug.
- # 0.0.6 🛇
  Wrong condition for type checking fixed.
- # 0.0.5 🛇
  Buggy change undone
- # 0.0.4 🛇
  Parameter `*` no longer mandatory in the priority map (default = 1). Smart 
  search improved for perfect mach with input.
- # 0.0.3 🛇
  Results sorted from the given priority map.
- # 0.0.2 🛇
  Parameter `where` now required for the smart search.
- # 0.0.1 🛇
  Package creation on [pub.dev](https://pub.dev/)
