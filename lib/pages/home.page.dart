import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/database.dart';
import 'package:my_app/models/transaction_width_category.dart';
import 'package:my_app/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
   HomePage({super.key, required this.selectedDate});

  final formatCurrency =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();
    @override
  Widget build(BuildContext context) {

  int totalIncome = 0;
  int totalExpense = 0;

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
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 224, 173, 190),
                  borderRadius: BorderRadius.circular(16),
              ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  // row berfungsi untuk membuat layout mendatar
                      Row(
                        children: [
                          Container(
                            child: Icon(Icons.download, color: Colors.green),
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
                                  "Pemasukan",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white, fontSize: 12,fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  widget.formatCurrency.format(totalIncome),
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
                            child: Icon(Icons.upload, color: Colors.red),
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
                                  "Pengeluaran",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white, fontSize: 12,fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  widget.formatCurrency.format(totalExpense),
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold
                                  ),
                              )
                            ],
                          )
                      ]
                      ),
                  ]),
            )
          ),

          // transaction history
          Padding(
            padding:  EdgeInsets.all(10),
            child: Text("Transaksi",
            style: GoogleFonts.montserrat(
               fontSize: 16, fontWeight: FontWeight.bold,
            ),),
          ),

          // menampilkan di transaksi home
          StreamBuilder<List<TransactionWidthCategory>>(
            stream: database.getTransactionByDate(widget.selectedDate), 
            builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasData) {
                for (var item in snapshot.data!) {
                  if (item.category.type == 2) {
                    totalExpense += item.transaction.amount;
                  } else {
                    totalIncome += item.transaction.amount;
                  }
                }
              if (snapshot.data!.length > 0) {
                return ListView.builder(
                  // shrinkWrap berfungsi untuk membuat listview tidak mengambil semua ruang yang tersedia
                  shrinkWrap: true,
                  // bouncingScrollPhysics berfungsi untuk memberikan efek bouncing saat scroll
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  // reverse berfungsi untuk membalik urutan data yang ditampilkan
                  reverse: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 10,
                        child: ListTile(
                          title: Text(
                                    'Rp. ${snapshot.data![index].transaction.amount}'),
                                subtitle: Text(
                                    '${snapshot.data![index].category.name} - ${snapshot.data![index].transaction.name} '),
                                leading: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    snapshot.data![index].category.type == 2
                                        ? Icons.upload
                                        : Icons.download,
                                    color:
                                        snapshot.data![index].category.type == 2
                                            ? Colors.red
                                            : Colors.green,
                                  ),
                                ),
                           trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          database.deleteTransactionRepo(
                                              snapshot
                                                  .data![index].transaction.id);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Berhasil menghapus data'),
                                            ),
                                          );
                                          setState(() {});
                                        },
                                        icon: Icon(Icons.delete)),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionPage(
                                              transactionWidthCategory:
                                                  snapshot.data![index],
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text('Tidak ada data..!'),
                      );
                    }
                  } else {
                    return Center(
                      child: Text('Tidak ada data..!'),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
