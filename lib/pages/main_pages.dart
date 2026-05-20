import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/pages/category_page.dart';
import 'package:my_app/pages/home.page.dart';
import 'package:my_app/pages/transaction_page.dart';

class MainPages extends StatefulWidget {
  const MainPages({super.key});
  
  @override
  State<MainPages> createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> {
  late DateTime selectedDate;
  // late artinya variabel yang akan digunakan nanti, tapi belum diinisialisasi sekarang
  late List<Widget> _children ;
  // fungsi untuk menyimpan halaman yang akan ditampilkan ketika user menekan icon di bottom navigation bar
  late int currentIndex = 0;

  @override
  void initState() {
    updateView(0, DateTime.now());
    super.initState();
  }

  void updateView(int index, DateTime date) {
    setState(() {
      if (date != true) {
      selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      } 
      currentIndex = index;
      _children = [
        HomePage(selectedDate: selectedDate),
        CategoryPage()
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentIndex == 0 
      ? CalendarAppBar(
        accent: const Color.fromARGB(255, 147, 45, 79),
        backButton: false,
        locale: 'id',
        onDateChanged: (value) {
          setState(() {
            selectedDate = value;
            updateView(0, selectedDate);
          });
        },
        firstDate: DateTime.now().subtract(const Duration(days: 140)),
        lastDate: DateTime.now(),

      ) : PreferredSize(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Text("Category", style: GoogleFonts.montserrat(fontSize: 25, fontWeight: FontWeight.bold),),
          )), 
          // preferredSize untuk menentukan tinggi appbar ketika user berada di halaman category
          preferredSize: Size.fromHeight(200)),

      floatingActionButton: Visibility(
        visible: currentIndex == 0 ? true : false,
        child: FloatingActionButton(
          onPressed:(){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransactionPage(transactionWidthCategory: null,),
            ))
            .then((value) {
              setState(() {});
            }); 
          },
          backgroundColor: const Color.fromARGB(255, 222, 131, 161),
          child: Icon(Icons.add, color: Colors.white,),
        ),
      ),
      body: _children[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 208, 170, 182),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
        IconButton(onPressed:(){
          updateView(0, DateTime.now());
        }, icon: Icon(Icons.home)),
        SizedBox(
          width: 20,
        ),
        IconButton(onPressed:(){
          updateView(1, DateTime.now());
        }, icon: Icon(Icons.list)),
      ],),),
    );
  }
}