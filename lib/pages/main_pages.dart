import 'package:flutter/material.dart';

class MainPages extends StatelessWidget {
  const MainPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed:(){},
        backgroundColor: Colors.pinkAccent, 
        child: Icon(Icons.add, color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
        IconButton(onPressed:(){}, icon: Icon(Icons.home)),
        SizedBox(
          width: 20,
        ),
        IconButton(onPressed:(){}, icon: Icon(Icons.list)),
      ],),),
    );
  }
}