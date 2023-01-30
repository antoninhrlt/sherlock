import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherlock/string.dart';

void main() {
  test('normalizeSnakeCase', () {
    var x = [
      'hello_world',
      '_hello',
      '_hello_world_yes',
      'hello_world_yes',
      'hello_world_',
    ];

    for (var y in x) {
      debugPrint(normalizeSnakeCase(y));
    }
  });

  test('normalizeCamelCase', () {
    var x = [
      'helloWorld',
      'Hello',
      'HelloWorldYes',
      'helloWorldYes',
      'helloWorldYesNo',
      'helloWorldX',
    ];

    for (var y in x) {
      debugPrint(normalizeCamelCase(y));
    }
  });
}
