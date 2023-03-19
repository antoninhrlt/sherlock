import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sherlock/widget/input.dart';
import 'package:sherlock/widget/watson.dart';

void main() {
  runApp(
    const MaterialApp(
      title: "Watson search bar demo",
      home: Scaffold(
        body: Center(
          child: WatsonSearchBar(
            iconized: true,
            searchInput: SearchInput(
              hintText: "Type here your search",
            ),
          ),
        ),
      ),
    ),
  );
}
