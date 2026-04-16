import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:my_app/pages/home.page.dart';


class MainPages extends StatelessWidget {
  const MainPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        accent: const Color.fromARGB(255, 176, 119, 138),
        backButton: false,
        locale: 'id',
        onDateChanged: (value) =>
          print(value),
          firstDate: DateTime.now().subtract(Duration(days:140)),
          lastDate: DateTime.now(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed:(){},
        backgroundColor: const Color.fromARGB(255, 220, 129, 160), 
        child: Icon(Icons.add, color: Colors.white,),
      ),

      body: HomePage(),

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