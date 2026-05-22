import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() =>
      _StatisticPageState();
}

class _StatisticPageState
    extends State<StatisticPage> {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final formatCurrency =
      NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xffF5F6FA),

      appBar: AppBar(

        elevation: 0,

        centerTitle: true,

        backgroundColor:
            const Color.fromARGB(
          255,
          147,
          45,
          79,
        ),

        title: Text(

          "Statistics",

          style:
              GoogleFonts.montserrat(

            color: Colors.white,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body:
          StreamBuilder<QuerySnapshot>(

        stream: firestore
            .collection('transactions')
            .orderBy('date')
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
                'Error: ${snapshot.error}',
              ),
            );
          }

          // EMPTY
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return Center(

              child: Text(

                "Belum ada transaksi",

                style:
                    GoogleFonts.montserrat(

                  fontSize: 18,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            );
          }

          final docs =
              snapshot.data!.docs;

          // ================= TOTAL =================
          int monthlyIncome = 0;
          int monthlyExpense = 0;

          // ================= WEEK =================
          List<double> weeklyIncome = [
            0,
            0,
            0,
            0
          ];

          List<double> weeklyExpense = [
            0,
            0,
            0,
            0
          ];

          // ================= PIE =================
          Map<String, double>
              categoryExpense = {};

          DateTime now =
              DateTime.now();

          // ================= LOOP =================
          for (var item in docs) {

            final data =
                item.data()
                    as Map<String,
                        dynamic>;

            // VALIDASI DATA
            if (data['date'] == null ||
                data['amount'] == null ||
                data['type'] == null) {
              continue;
            }

            DateTime trxDate =
                (data['date']
                        as Timestamp)
                    .toDate();

            int amount =
                data['amount'];

            int type =
                data['type'];

            String categoryName =
                data['category_name'] ??
                    'Lainnya';

            // FILTER BULAN INI
            if (trxDate.month ==
                    now.month &&
                trxDate.year ==
                    now.year) {

              // MINGGU
              int weekIndex =
                  ((trxDate.day - 1) /
                          7)
                      .floor();

              if (weekIndex > 3) {
                weekIndex = 3;
              }

              // PEMASUKAN
              if (type == 1) {

                monthlyIncome +=
                    amount;

                weeklyIncome[
                        weekIndex] +=
                    amount.toDouble();
              }

              // PENGELUARAN
              if (type == 2) {

                monthlyExpense +=
                    amount;

                weeklyExpense[
                        weekIndex] +=
                    amount.toDouble();

                // PIE CHART
                categoryExpense[
                        categoryName] =
                    (categoryExpense[
                                categoryName] ??
                            0) +
                        amount;
              }
            }
          }

          // ================= BALANCE =================
          int balance =
              monthlyIncome -
                  monthlyExpense;

          // ================= MAX CHART =================
          double maxValue = 0;

          for (var value
              in weeklyIncome) {

            if (value > maxValue) {
              maxValue = value;
            }
          }

          for (var value
              in weeklyExpense) {

            if (value > maxValue) {
              maxValue = value;
            }
          }

          return SingleChildScrollView(

            child: Padding(

              padding:
                  const EdgeInsets.all(
                16,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  // ================= CARD =================
                  Container(

                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(22),

                    decoration:
                        BoxDecoration(

                      borderRadius:
                          BorderRadius.circular(
                        28,
                      ),

                      gradient:
                          const LinearGradient(

                        colors: [

                          Color.fromARGB(
                            255,
                            147,
                            45,
                            79,
                          ),

                          Color.fromARGB(
                            255,
                            182,
                            87,
                            119,
                          ),
                        ],
                      ),
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(

                          "Keuangan Bulan Ini",

                          style:
                              GoogleFonts
                                  .montserrat(

                            color:
                                Colors.white,

                            fontSize: 22,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(

                          "Saldo : ${formatCurrency.format(balance)}",

                          style:
                              GoogleFonts
                                  .montserrat(

                            color: Colors
                                .white70,

                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        Row(

                          children: [

                            // PEMASUKAN
                            Expanded(

                              child:
                                  Container(

                                padding:
                                    const EdgeInsets
                                        .all(
                                  16,
                                ),

                                decoration:
                                    BoxDecoration(

                                  color: Colors
                                      .white24,

                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: Column(

                                  children: [

                                    const Icon(
                                      Icons
                                          .arrow_downward,
                                      color: Colors
                                          .green,
                                    ),

                                    const SizedBox(
                                      height:
                                          10,
                                    ),

                                    Text(

                                      "Pemasukan",

                                      style:
                                          GoogleFonts
                                              .montserrat(

                                        color: Colors
                                            .white,
                                      ),
                                    ),

                                    const SizedBox(
                                      height:
                                          8,
                                    ),

                                    Text(

                                      formatCurrency
                                          .format(
                                        monthlyIncome,
                                      ),

                                      textAlign:
                                          TextAlign
                                              .center,

                                      style:
                                          GoogleFonts
                                              .montserrat(

                                        color: Colors
                                            .greenAccent,

                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 15,
                            ),

                            // PENGELUARAN
                            Expanded(

                              child:
                                  Container(

                                padding:
                                    const EdgeInsets
                                        .all(
                                  16,
                                ),

                                decoration:
                                    BoxDecoration(

                                  color: Colors
                                      .white24,

                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: Column(

                                  children: [

                                    const Icon(
                                      Icons
                                          .arrow_upward,
                                      color: Colors
                                          .red,
                                    ),

                                    const SizedBox(
                                      height:
                                          10,
                                    ),

                                    Text(

                                      "Pengeluaran",

                                      style:
                                          GoogleFonts
                                              .montserrat(

                                        color: Colors
                                            .white,
                                      ),
                                    ),

                                    const SizedBox(
                                      height:
                                          8,
                                    ),

                                    Text(

                                      formatCurrency
                                          .format(
                                        monthlyExpense,
                                      ),

                                      textAlign:
                                          TextAlign
                                              .center,

                                      style:
                                          GoogleFonts
                                              .montserrat(

                                        color: Colors
                                            .redAccent,

                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ================= PIE CHART =================
                  Text(

                    "Kategori Pengeluaran",

                    style:
                        GoogleFonts
                            .montserrat(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(

                    height: 300,

                    child: PieChart(

                      PieChartData(

                        sections:
                            showingSections(
                          categoryExpense,
                        ),

                        centerSpaceRadius:
                            45,

                        sectionsSpace:
                            3,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 35,
                  ),

                  // ================= BAR CHART =================
                  Text(

                    "Grafik Mingguan",

                    style:
                        GoogleFonts
                            .montserrat(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(

                    height: 320,

                    child: BarChart(

                      BarChartData(

                        maxY:
                            maxValue == 0
                                ? 100000
                                : maxValue +
                                    50000,

                        alignment:
                            BarChartAlignment
                                .spaceAround,

                        gridData:
                            FlGridData(
                          show: true,
                        ),

                        borderData:
                            FlBorderData(
                          show: false,
                        ),

                        titlesData:
                            FlTitlesData(

                          topTitles:
                              AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles:
                                  false,
                            ),
                          ),

                          rightTitles:
                              AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles:
                                  false,
                            ),
                          ),

                          leftTitles:
                              AxisTitles(

                            sideTitles:
                                SideTitles(

                              showTitles:
                                  true,

                              reservedSize:
                                  50,

                              getTitlesWidget:
                                  (
                                value,
                                meta,
                              ) {

                                return Text(

                                  value
                                      .toInt()
                                      .toString(),

                                  style:
                                      GoogleFonts
                                          .montserrat(

                                    fontSize:
                                        10,
                                  ),
                                );
                              },
                            ),
                          ),

                          bottomTitles:
                              AxisTitles(

                            sideTitles:
                                SideTitles(

                              showTitles:
                                  true,

                              getTitlesWidget:
                                  (
                                value,
                                meta,
                              ) {

                                List<String>
                                    weeks = [

                                  "W1",
                                  "W2",
                                  "W3",
                                  "W4",
                                ];

                                return Padding(

                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 8,
                                  ),

                                  child: Text(

                                    weeks[value
                                        .toInt()],

                                    style:
                                        GoogleFonts
                                            .montserrat(

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        barGroups: [

                          makeGroupData(
                            0,
                            weeklyIncome[
                                0],
                            weeklyExpense[
                                0],
                          ),

                          makeGroupData(
                            1,
                            weeklyIncome[
                                1],
                            weeklyExpense[
                                1],
                          ),

                          makeGroupData(
                            2,
                            weeklyIncome[
                                2],
                            weeklyExpense[
                                2],
                          ),

                          makeGroupData(
                            3,
                            weeklyIncome[
                                3],
                            weeklyExpense[
                                3],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= BAR =================
  BarChartGroupData makeGroupData(
    int x,
    double income,
    double expense,
  ) {

    return BarChartGroupData(

      x: x,

      barsSpace: 6,

      barRods: [

        // PEMASUKAN
        BarChartRodData(

          toY: income,

          width: 14,

          color: Colors.green,

          borderRadius:
              BorderRadius.circular(
            8,
          ),
        ),

        // PENGELUARAN
        BarChartRodData(

          toY: expense,

          width: 14,

          color: Colors.red,

          borderRadius:
              BorderRadius.circular(
            8,
          ),
        ),
      ],
    );
  }

  // ================= PIE =================
    List<PieChartSectionData>
        showingSections(
      Map<String, double> data,
    ) {

      final colors = [
        Colors.green,
        Colors.red,
      ];

      // TOTAL
      double total = 0;

      for (var value in data.values) {
        total += value;
      }

      final entries =
          data.entries.toList();

      return List.generate(
        entries.length,
        (i) {

          final value =
              entries[i].value;

          // PERSENTASE
          final percentage =
              ((value / total) * 100);

          return PieChartSectionData(

            // VALUE ASLI
            value: value,

            // WARNA
            color:
                colors[
                    i %
                        colors.length],

            // TEXT %
            title:
                '${percentage.toStringAsFixed(1)}%',

            // BESAR TEXT
            titleStyle:
                GoogleFonts.montserrat(

              color: Colors.white,

              fontWeight:
                  FontWeight.bold,

              fontSize: 13,
            ),

            // BESAR PIE
            radius: 110,

            // POSISI TEXT %
            titlePositionPercentageOffset:
                0.6,

            // BORDER
            borderSide:
                const BorderSide(

              color: Colors.white,

              width: 2,
            ),
          );
    },
  );
}
}