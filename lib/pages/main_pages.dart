import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/pages/category_page.dart';
import 'package:my_app/pages/home.page.dart';

class MainPages extends StatefulWidget {
  const MainPages({super.key});
  
  @override
  State<MainPages> createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> {
  final List<Widget> _children = [HomePage(), CategoryPage()];
  // fungsi untuk menyimpan halaman yang akan ditampilkan ketika user menekan icon di bottom navigation bar
  int currentIndex = 0;
  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentIndex == 0 
      ? CalendarAppBar(
        accent: const Color.fromARGB(255, 176, 119, 138),
        backButton: false,
        locale: 'id',
        onDateChanged: (value) =>
          print(value),
          firstDate: DateTime.now().subtract(Duration(days:140)),
          lastDate: DateTime.now(),
      ) : PreferredSize(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
            child: Text("Category", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),),
          )), 
          preferredSize: Size.fromHeight(100)),

      floatingActionButton: Visibility(
        visible: currentIndex == 0 ? true : false,
        child: FloatingActionButton(
          onPressed:(){},
          backgroundColor: const Color.fromARGB(255, 220, 129, 160), 
          child: Icon(Icons.add, color: Colors.white,),
        ),
      ),
      body: _children[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
        IconButton(onPressed:(){
          onTabTapped(0);
        }, icon: Icon(Icons.home)),
        SizedBox(
          width: 20,
        ),
        IconButton(onPressed:(){
          onTabTapped(1);
        }, icon: Icon(Icons.list)),
      ],),),
    );
  }
}