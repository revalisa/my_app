import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/models/database.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
   HomePage({super.key, required this.selectedDate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // fungsi untuk membuat halaman bisa discroll
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            // card untuk menampilkan income dan expense
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  // row berfungsi untuk membuat layout mendatar
                      Row(
                        children: [
                          Container(
                            child: Icon(Icons.download, color: const Color.fromARGB(255, 120, 218, 118)),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 253, 253),
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
                                    color: Colors.white, fontSize: 12,fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Rp. 300.000.000",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold
                                  ),
                              )
                            ],
                          )
                      ]),
                      // expense
                      Row(
                        children: [
                          Container(
                            child: Icon(Icons.upload, color: const Color.fromARGB(255, 200, 99, 71)),
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
                                  "Expense",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white, fontSize: 12,fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Rp. 12.000.000",
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
                color: Color.fromARGB(255, 224, 173, 190),
                borderRadius: BorderRadius.circular(16),
              ),
            )
          ),

          // transaction history
          Padding(
            padding:  EdgeInsets.all(10),
            child: Text("Transaction History",
            style: GoogleFonts.montserrat(
               fontSize: 16, fontWeight: FontWeight.bold,
            ),),
          ),
          // menampilkan di transaksi home
          StreamBuilder(stream: database.getTransactionByDate(widget.selectedDate), 
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasData) {
              if (snapshot.data!.length > 0) {
                return ListView.builder(
                  // shrinkWrap berfungsi untuk membuat listview tidak mengambil semua ruang yang tersedia
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 10,
                        child: ListTile(
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            Icon(Icons.delete),
                            // kegunaan SizedBox untuk memberikan jarak antara icon delete dan edit
                            SizedBox(width: 10,), 
                            Icon(Icons.edit)],
                          ),
                          title: Text("Rp." + 
                          snapshot.data![index].transaction.amount
                          .toString()),
                          subtitle: Text(snapshot.data![index].category.name),
                          // kegunaan leading untuk menampilkan icon di depan title dan subtitle
                          leading: Container(
                            child: Icon( Icons.upload, color: const Color.fromARGB(255, 200, 99, 71)),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 253, 253),
                              borderRadius: BorderRadius.circular(8))
                            ),
                        ),
                      ),
                    );
                  },
                );
                } else {
                  return Center(
                    child: Text("data kosong"),
                  );
                }  
              } else {
                return Center(
                  child: Text("tidak ada data"),
                );
              }
            }
          }),
        ]
      )
      ),
    );
  }
}