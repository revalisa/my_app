import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/pages/category_page.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/transaction_page.dart';

class MainPages extends StatefulWidget {

  const MainPages({
    super.key,
  });

  @override
  State<MainPages> createState() =>
      _MainPagesState();
}

class _MainPagesState
    extends State<MainPages> {

  // ================= DATE =================
  late DateTime selectedDate;

  // ================= INDEX =================
  int currentIndex = 0;

  // ================= CHILDREN =================
  late List<Widget> children;

  // ================= INIT =================
  @override
  void initState() {

    super.initState();

    selectedDate = DateTime.now();

    updateView();
  }

  // ================= UPDATE VIEW =================
  void updateView() {

    children = [

      // HOME
      HomePage(
        selectedDate: selectedDate,
      ),

      // CATEGORY
      const CategoryPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // ================= APPBAR =================
      appBar:
          currentIndex == 0

              // HOME APPBAR
              ? CalendarAppBar(

                  accent:
                      const Color.fromARGB(
                    255,
                    147,
                    45,
                    79,
                  ),

                  backButton: false,

                  locale: 'id',

                  onDateChanged: (value) {

                    setState(() {

                      selectedDate = value;

                      updateView();
                    });
                  },

                  firstDate:
                      DateTime.now().subtract(

                    const Duration(
                      days: 365,
                    ),
                  ),

                  lastDate:
                      DateTime.now(),
                )

              // CATEGORY APPBAR
              : PreferredSize(

                  preferredSize:
                      const Size.fromHeight(
                    100,
                  ),

                  child: Container(

                    padding:
                        const EdgeInsets.only(
                      top: 50,
                      left: 16,
                    ),

                    alignment:
                        Alignment.centerLeft,

                    child: Text(

                      "Category",

                      style:
                          GoogleFonts.montserrat(

                        fontSize: 25,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

      // ================= FLOATING BUTTON =================
      floatingActionButton:
          currentIndex == 0

              ? FloatingActionButton(

                  backgroundColor:
                      const Color.fromARGB(
                    255,
                    222,
                    131,
                    161,
                  ),

                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),

                  onPressed: () {

                    Navigator.of(context)
                        .push(

                      MaterialPageRoute(

                        builder: (context) =>
                            const TransactionPage(),
                      ),
                    )
                        .then((value) {

                      setState(() {

                        updateView();
                      });
                    });
                  },
                )

              : null,

      floatingActionButtonLocation:
          FloatingActionButtonLocation
              .centerDocked,

      // ================= BODY =================
      body: children[currentIndex],

      // ================= BOTTOM NAVIGATION =================
      bottomNavigationBar: BottomAppBar(

        color:
            const Color.fromARGB(
          255,
          208,
          170,
          182,
        ),

        child: Row(

          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,

          children: [

            // HOME
            IconButton(

              onPressed: () {

                setState(() {

                  currentIndex = 0;

                  updateView();
                });
              },

              icon: Icon(

                Icons.home,

                color:
                    currentIndex == 0
                        ? Colors.white
                        : Colors.black,
              ),
            ),

            const SizedBox(
              width: 20,
            ),

            // CATEGORY
            IconButton(

              onPressed: () {

                setState(() {

                  currentIndex = 1;

                  updateView();
                });
              },

              icon: Icon(

                Icons.list,

                color:
                    currentIndex == 1
                        ? Colors.white
                        : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}