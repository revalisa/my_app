import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/pages/statistic_page.dart';
import 'package:my_app/pages/transaction_page.dart';

class HomePage extends StatefulWidget {

  final DateTime selectedDate;

  HomePage({
    super.key,
    required this.selectedDate,
  });

  final formatCurrency =
      NumberFormat.currency(

    locale: 'id_ID',

    symbol: 'Rp. ',

    decimalDigits: 0,
  );

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {

  // ================= FIREBASE =================
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // ================= DELETE =================
  Future<void> deleteTransaction(
    String id,
  ) async {

    try {

      await firestore
          .collection('transactions')
          .doc(id)
          .delete();

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              'Berhasil menghapus data',
            ),
          ),
        );
      }
    }

    catch (e) {

      debugPrint(
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // ================= APPBAR =================
      appBar: AppBar(

        title: const Text(
          "Finance App",
        ),

        actions: [

          Padding(

            padding:
                const EdgeInsets.only(
              right: 12,
            ),

            child:
                ElevatedButton.icon(

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    const Color.fromARGB(
                  255,
                  147,
                  45,
                  79,
                ),

                foregroundColor:
                    Colors.white,

                elevation: 3,

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
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

              icon: const Icon(
                Icons.bar_chart,
              ),

              label: Text(

                "Chart",

                style:
                    GoogleFonts.montserrat(

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: SafeArea(

        child:
            StreamBuilder<QuerySnapshot>(

          stream: firestore
              .collection(
                'transactions',
              )
              .orderBy(
                'date',
                descending: true,
              )
              .snapshots(),

          builder:
              (context, snapshot) {

            // LOADING
            if (snapshot.connectionState ==
                ConnectionState.waiting) {

              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            // ERROR
            if (snapshot.hasError) {

              return Center(

                child: Text(
                  snapshot.error
                      .toString(),
                ),
              );
            }

            // DATA
            final docs =
                snapshot.data?.docs ??
                    [];

            // TOTAL
            int totalIncome = 0;
            int totalExpense = 0;

            // HITUNG TOTAL
            for (var item in docs) {

              final data =
                  item.data()
                      as Map<String,
                          dynamic>;

              // income
              if (data['type'] == 1) {

                totalIncome +=
                    data['amount']
                        as int;
              }

              // expense
              if (data['type'] == 2) {

                totalExpense +=
                    data['amount']
                        as int;
              }
            }

            return SingleChildScrollView(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // ================= CARD TOTAL =================
                  Padding(

                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    child: Container(

                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            const Color.fromARGB(
                          255,
                          224,
                          173,
                          190,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),

                      child: Row(

                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [

                          // PEMASUKAN
                          Row(

                            children: [

                              Container(

                                padding:
                                    const EdgeInsets
                                        .all(8),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      Colors
                                          .white,

                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),

                                child:
                                    const Icon(

                                  Icons.download,

                                  color:
                                      Colors
                                          .green,
                                ),
                              ),

                              const SizedBox(
                                width: 15,
                              ),

                              Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(

                                    "Pemasukan",

                                    style:
                                        GoogleFonts
                                            .montserrat(

                                      color:
                                          Colors
                                              .white,

                                      fontSize:
                                          12,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  Text(

                                    widget
                                        .formatCurrency
                                        .format(
                                      totalIncome,
                                    ),

                                    style:
                                        GoogleFonts
                                            .montserrat(

                                      color:
                                          Colors
                                              .white,

                                      fontSize:
                                          14,

                                      fontWeight:
                                          FontWeight
                                              .bold,
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

                                padding:
                                    const EdgeInsets
                                        .all(8),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      Colors
                                          .white,

                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),

                                child:
                                    const Icon(

                                  Icons.upload,

                                  color:
                                      Colors.red,
                                ),
                              ),

                              const SizedBox(
                                width: 15,
                              ),

                              Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(

                                    "Pengeluaran",

                                    style:
                                        GoogleFonts
                                            .montserrat(

                                      color:
                                          Colors
                                              .white,

                                      fontSize:
                                          12,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  Text(

                                    widget
                                        .formatCurrency
                                        .format(
                                      totalExpense,
                                    ),

                                    style:
                                        GoogleFonts
                                            .montserrat(

                                      color:
                                          Colors
                                              .white,

                                      fontSize:
                                          14,

                                      fontWeight:
                                          FontWeight
                                              .bold,
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

                  // ================= TITLE =================
                  Padding(

                    padding:
                        const EdgeInsets.all(
                      10,
                    ),

                    child: Text(

                      "Transaksi",

                      style:
                          GoogleFonts.montserrat(

                        fontSize: 16,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  // ================= EMPTY =================
                  if (docs.isEmpty)

                    const Center(

                      child: Padding(

                        padding:
                            EdgeInsets.all(
                          20,
                        ),

                        child: Text(
                          'Tidak ada data..!',
                        ),
                      ),
                    )

                  // ================= LIST =================
                  else

                    ListView.builder(

                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemCount:
                          docs.length,

                      itemBuilder:
                          (context, index) {

                        final item =
                            docs[index];

                        final data =
                            item.data()
                                as Map<String,
                                    dynamic>;

                        return Padding(

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),

                          child: Card(

                            elevation: 10,

                            child: ListTile(

                              // NOMINAL
                              title: Text(

                                widget
                                    .formatCurrency
                                    .format(
                                  data['amount'],
                                ),
                              ),

                              // DETAIL
                              subtitle: Text(

                                '${data['category_name']} - ${data['detail']}',
                              ),

                              // ICON
                              leading: Container(

                                padding:
                                    const EdgeInsets
                                        .all(8),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      Colors
                                          .white,

                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),

                                child: Icon(

                                  data['type'] == 2
                                      ? Icons.upload
                                      : Icons.download,

                                  color:
                                      data['type'] == 2
                                          ? Colors.red
                                          : Colors.green,
                                ),
                              ),

                              // ACTION
                              trailing: Row(

                                mainAxisSize:
                                    MainAxisSize
                                        .min,

                                children: [

                                  // DELETE
                                  IconButton(

                                    onPressed:
                                        () async {

                                      await deleteTransaction(
                                        item.id,
                                      );
                                    },

                                    icon:
                                        const Icon(
                                      Icons.delete,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  // EDIT
                                  IconButton(

                                    onPressed:
                                        () {

                                      Navigator.of(
                                              context)
                                          .push(

                                        MaterialPageRoute(

                                          builder:
                                              (context) =>
                                                  TransactionPage(

                                            docId:
                                                item.id,
                                          ),
                                        ),
                                      );
                                    },

                                    icon:
                                        const Icon(
                                      Icons.edit,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}