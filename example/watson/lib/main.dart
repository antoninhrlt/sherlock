import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sherlock/widget/watson.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: WatsonSearchBar(),
        ),
      ),
    ),
  );
}
