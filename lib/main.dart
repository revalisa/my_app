import 'package:flutter/material.dart';
import 'package:my_app/pages/main_pages.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor:  const Color.fromARGB(255, 231, 183, 199),) ),
      home: MainPages(),
    );
  }
}