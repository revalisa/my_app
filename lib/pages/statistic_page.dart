import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/database.dart';
import '../models/transaction_width_category.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {

  final AppDb database = AppDb();

  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Statistic"),
      ),

      body: StreamBuilder<List<TransactionWidthCategory>>(

        stream: database.getAllTransactions(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // total
          int weeklyIncome = 0;
          int monthlyIncome = 0;
          int yearlyIncome = 0;

          int weeklyExpense = 0;
          int monthlyExpense = 0;
          int yearlyExpense = 0;

          DateTime now = DateTime.now();

          if (snapshot.hasData) {

            for (var item in snapshot.data!) {

              DateTime trxDate =
                  item.transaction.transaction_date;

              // SELISIH HARI
              int difference =
                  now.difference(trxDate).inDays;

              // MINGGU
              if (difference <= 7) {

                if (item.category.type == 1) {
                  weeklyIncome +=
                      item.transaction.amount;
                }

                if (item.category.type == 2) {
                  weeklyExpense +=
                      item.transaction.amount;
                }
              }

              // BULAN
              if (trxDate.month == now.month &&
                  trxDate.year == now.year) {

                if (item.category.type == 1) {
                  monthlyIncome +=
                      item.transaction.amount;
                }

                if (item.category.type == 2) {
                  monthlyExpense +=
                      item.transaction.amount;
                }
              }

              // TAHUN
              if (trxDate.year == now.year) {

                if (item.category.type == 1) {
                  yearlyIncome +=
                      item.transaction.amount;
                }

                if (item.category.type == 2) {
                  yearlyExpense +=
                      item.transaction.amount;
                }
              }
            }
          }

          return SingleChildScrollView(

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // WEEKLY
                  buildCard(
                    title: "Minggu Ini",
                    income: weeklyIncome,
                    expense: weeklyExpense,
                  ),

                  SizedBox(height: 20),

                  // MONTHLY
                  buildCard(
                    title: "Bulan Ini",
                    income: monthlyIncome,
                    expense: monthlyExpense,
                  ),

                  SizedBox(height: 20),

                  // YEARLY
                  buildCard(
                    title: "Tahun Ini",
                    income: yearlyIncome,
                    expense: yearlyExpense,
                  ),

                  SizedBox(height: 30),

                  Text(
                    "Grafik Bulanan",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),

                  Container(
                    height: 300,
                    padding: EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          color: Colors.grey.shade300,
                        )
                      ],
                    ),

                    child: BarChart(

                      BarChartData(

                        borderData:
                            FlBorderData(show: false),

                        gridData:
                            FlGridData(show: true),

                        titlesData: FlTitlesData(

                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                            ),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,

                              getTitlesWidget:
                                  (value, meta) {

                                switch (value.toInt()) {

                                  case 0:
                                    return Text("Min");

                                  case 1:
                                    return Text("Sen");

                                  case 2:
                                    return Text("Sel");

                                  case 3:
                                    return Text("Rab");

                                  case 4:
                                    return Text("Kam");

                                  case 5:
                                    return Text("Jum");

                                  case 6:
                                    return Text("Sab");
                                }

                                return Text("");
                              },
                            ),
                          ),
                        ),

                        barGroups: [

                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY:
                                    weeklyIncome.toDouble(),
                              ),
                            ],
                          ),

                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY:
                                    weeklyExpense.toDouble(),
                              ),
                            ],
                          ),

                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY:
                                    monthlyIncome.toDouble(),
                              ),
                            ],
                          ),

                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY:
                                    monthlyExpense.toDouble(),
                              ),
                            ],
                          ),

                          BarChartGroupData(
                            x: 4,
                            barRods: [
                              BarChartRodData(
                                toY:
                                    yearlyIncome.toDouble(),
                              ),
                            ],
                          ),

                          BarChartGroupData(
                            x: 5,
                            barRods: [
                              BarChartRodData(
                                toY:
                                    yearlyExpense.toDouble(),
                              ),
                            ],
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

  // CARD
  Widget buildCard({
    required String title,
    required int income,
    required int expense,
  }) {

    return Container(

      width: double.infinity,
      padding: EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Color.fromARGB(255, 224, 173, 190),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,

            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Pemasukan",

                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    formatCurrency.format(income),

                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Pengeluaran",

                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    formatCurrency.format(expense),

                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}