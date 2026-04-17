import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
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

      body: CategoryPage(),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
        IconButton(onPressed:(){}, icon: Icon(Icons.home)),
        SizedBox(
          width: 20,
        ),
        IconButton(onPressed:(){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryPage()),
          );
        }, icon: Icon(Icons.list)),
      ],),),
    );
  }
}
