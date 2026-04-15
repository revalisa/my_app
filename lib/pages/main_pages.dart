import 'package:flutter/material.dart';

class MainPages extends StatelessWidget {
  const MainPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed:(){},
        backgroundColor: Colors.lightBlueAccent, 
        child: Icon(Icons.add),
      ),
    );
  }
}