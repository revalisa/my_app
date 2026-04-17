import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // fungsi untuk membuat halaman bisa discroll
      child: SafeArea(
        child: Column(
          children:[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                child: Row(children: [
                  // row berfungsi untuk membuat layout mendatar
                  Row(
                    children: [
                      Container(
                        child: Icon(Icons.download, color: Colors.white),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8))
                        ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                              "Income",
                              style: GoogleFonts.montserrat(
                                color: Colors.white, fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "\$ 12.000",
                              style: GoogleFonts.montserrat(
                                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold
                              ),
                      
                          )
                        ],
                      )
                  ]
                  ),
              ]),

              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
                borderRadius: BorderRadius.circular(16),
              ),
            )
          ),],
        )),
    );
  }
}