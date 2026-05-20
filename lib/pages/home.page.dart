import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/database.dart';
import 'package:my_app/models/transaction_width_category.dart';
import 'package:my_app/pages/transaction_page.dart';
import 'package:my_app/pages/statistic_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;

  HomePage({
    super.key,
    required this.selectedDate,
  });

  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

  appBar: AppBar(
    title: Text("Finance App"),
    actions: [

  Padding(
    padding: const EdgeInsets.only(right: 12),

    child: ElevatedButton.icon(

      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 147, 45, 79),
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      onPressed: () {

        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) =>
                StatisticPage(),
          ),
        );
      },

      icon: Icon(Icons.bar_chart),

      label: Text(
        "Chart",
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
],

  ),

  body: SingleChildScrollView(
      child: SafeArea(
        child: StreamBuilder<List<TransactionWidthCategory>>(
          stream: database.getTransactionByDate(widget.selectedDate),

          builder: (context, snapshot) {

            // loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // total income & expense
            int totalIncome = 0;
            int totalExpense = 0;

            // hitung total
            if (snapshot.hasData) {

              for (var item in snapshot.data!) {

                // type 1 = income
                if (item.category.type == 1) {
                  totalIncome += item.transaction.amount;
                }

                // type 2 = expense
                if (item.category.type == 2) {
                  totalExpense += item.transaction.amount;
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // CARD TOTAL
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

                        // PEMASUKAN
                        Row(
                          children: [

                            Container(
                              padding: EdgeInsets.all(8),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),

                              child: Icon(
                                Icons.download,
                                color: Colors.green,
                              ),
                            ),

                            SizedBox(width: 15),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  "Pemasukan",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 10),

                                Text(
                                  widget.formatCurrency
                                      .format(totalIncome),

                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // PENGELUARAN
                        Row(
                          children: [

                            Container(
                              padding: EdgeInsets.all(8),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),

                              child: Icon(
                                Icons.upload,
                                color: Colors.red,
                              ),
                            ),

                            SizedBox(width: 15),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  "Pengeluaran",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 10),

                                Text(
                                  widget.formatCurrency
                                      .format(totalExpense),

                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // TITLE TRANSAKSI
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Transaksi",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // LIST TRANSAKSI
                if (snapshot.hasData &&
                    snapshot.data!.isNotEmpty)

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    reverse: true,
                    itemCount: snapshot.data!.length,

                    itemBuilder: (context, index) {

                      final item = snapshot.data![index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),

                        child: Card(
                          elevation: 10,

                          child: ListTile(

                            // nominal
                            title: Text(
                              widget.formatCurrency.format(
                                item.transaction.amount,
                              ),
                            ),

                            // detail
                            subtitle: Text(
                              '${item.category.name} - ${item.transaction.name}',
                            ),

                            // icon
                            leading: Container(
                              padding: EdgeInsets.all(8),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),

                              child: Icon(
                                item.category.type == 2
                                    ? Icons.upload
                                    : Icons.download,

                                color:
                                    item.category.type == 2
                                        ? Colors.red
                                        : Colors.green,
                              ),
                            ),

                            // action button
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [

                                // DELETE
                                IconButton(
                                  onPressed: () async {

                                    await database
                                        .deleteTransactionRepo(
                                      item.transaction.id,
                                    );

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Berhasil menghapus data',
                                        ),
                                      ),
                                    );

                                    setState(() {});
                                  },

                                  icon: Icon(Icons.delete),
                                ),

                                SizedBox(width: 10),

                                // EDIT
                                IconButton(
                                  onPressed: () {

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TransactionPage(
                                          transactionWidthCategory:
                                              item,
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
                  )

                else

                  Center(
                    child: Text(
                      'Tidak ada data..!',
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ));
  }
}