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

  int touchedIndex = -1;
  final AppDb database = AppDb();

  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 147, 45, 79),
        title: Text(
          "Statistics",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<TransactionWidthCategory>>(
        stream: database.getAllTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Belum ada transaksi",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          int monthlyIncome = 0;
          int monthlyExpense = 0;

          List<double> weeklyIncome = [0, 0, 0, 0];
          List<double> weeklyExpense = [0, 0, 0, 0];

          Map<String, int> yearlyCategoryExpense = {};

          DateTime now = DateTime.now();

          for (var item in snapshot.data!) {
            DateTime trxDate = item.transaction.transaction_date;

            if (trxDate.month == now.month &&
                trxDate.year == now.year) {
              int weekIndex = ((trxDate.day - 1) / 7).floor();

              if (weekIndex > 3) {
                weekIndex = 3;
              }

              if (item.category.type == 1) {
                monthlyIncome += item.transaction.amount;
                weeklyIncome[weekIndex] +=
                    item.transaction.amount;
              }

              if (item.category.type == 2) {
                monthlyExpense += item.transaction.amount;
                weeklyExpense[weekIndex] +=
                    item.transaction.amount;
              }
            }

            if (trxDate.year == now.year &&
                item.category.type == 2) {
              String categoryName = item.category.name;

              yearlyCategoryExpense[categoryName] =
                  (yearlyCategoryExpense[categoryName] ??
                          0) +
                      item.transaction.amount;
            }
          }

          int balance = monthlyIncome - monthlyExpense;

          double maxValue = [
            ...weeklyIncome,
            ...weeklyExpense
          ].fold(0, (prev, element) {
            return element > prev ? element : prev;
          });

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 147, 45, 79),
                          Color.fromARGB(255, 182, 87, 119),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                          color: const Color.fromARGB(255, 214, 111, 145)
                              
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Keuangan Bulan Ini",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Saldo: ${formatCurrency.format(balance)}",
                          style: GoogleFonts.montserrat(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius:
                                      BorderRadius.circular(
                                          20),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Pemasukan",
                                          style: GoogleFonts
                                              .montserrat(
                                            color:
                                                Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      formatCurrency.format(
                                          monthlyIncome),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: GoogleFonts
                                          .montserrat(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius:
                                      BorderRadius.circular(
                                          20),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Pengeluaran",
                                          style: GoogleFonts
                                              .montserrat(
                                            color:
                                                Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      formatCurrency.format(
                                          monthlyExpense),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: GoogleFonts
                                          .montserrat(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 13,
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
                  const SizedBox(height: 35),

                  // =========================
                  // PIE CHART CATEGORY
                  // =========================

                  Text(
                    "Kategori Pengeluaran",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 147, 45, 79),
                          Color.fromARGB(255, 182, 87, 119),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                          color: const Color.fromARGB(255, 214, 111, 145)
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 320,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (
                                  FlTouchEvent event,
                                  pieTouchResponse,
                                ) {
                                  setState(() {
                                    if (!event
                                            .isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse
                                                .touchedSection ==
                                            null) {
                                      touchedIndex = -1;
                                      return;
                                    }

                                    touchedIndex = pieTouchResponse
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData:
                                  FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections:
                                  showingSections(
                                yearlyCategoryExpense,
                              ),
                            ),
                            duration: const Duration(
                              milliseconds: 800,
                            ),
                            curve: Curves.easeInOut,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),
                  Text(
                    "Grafik Mingguan",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 147, 45, 79),
                          Color.fromARGB(255, 182, 87, 119),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                          color: Colors.pinkAccent
                              .withOpacity(0.4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.bar_chart,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Weekly Transactions",
                              style: GoogleFonts
                                  .montserrat(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              alignment:
                                  BarChartAlignment
                                      .spaceAround,
                              maxY: maxValue == 0
                                  ? 100000
                                  : maxValue + 50000,
                              gridData:
                                  FlGridData(show: false),
                              borderData:
                                  FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 55,
                                    getTitlesWidget:
                                        (value, meta) {
                                      String text = "";

                                      if (value >=
                                          1000000) {
                                        text =
                                            "${(value / 1000000).toStringAsFixed(1)}M";
                                      } else if (value >=
                                          1000) {
                                        text =
                                            "${(value / 1000).toStringAsFixed(0)}K";
                                      } else {
                                        text = value
                                            .toInt()
                                            .toString();
                                      }

                                      return Text(
                                        text,
                                        style: GoogleFonts
                                            .montserrat(
                                          color: Colors
                                              .white70,
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (value, meta) {
                                      List<String> titles = [
                                        "W1",
                                        "W2",
                                        "W3",
                                        "W4",
                                      ];

                                      return Padding(
                                        padding:
                                            const EdgeInsets
                                                .only(
                                          top: 10,
                                        ),
                                        child: Text(
                                          titles[
                                              value.toInt()],
                                          style: GoogleFonts
                                              .montserrat(
                                            color:
                                                Colors.white,
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
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData:
                                    BarTouchTooltipData(
                                 
                                  getTooltipColor:
                                      (group) {
                                    return Colors.white;
                                  },
                                  getTooltipItem: (
                                    group,
                                    groupIndex,
                                    rod,
                                    rodIndex,
                                  ) {
                                    String title =
                                        rodIndex == 0
                                            ? "Income"
                                            : "Expense";

                                    return BarTooltipItem(
                                      "$title\n${formatCurrency.format(rod.toY)}",
                                      GoogleFonts
                                          .montserrat(
                                        color: Colors.black,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              barGroups: [
                                makeGroupData(
                                  0,
                                  weeklyIncome[0],
                                  weeklyExpense[0],
                                ),
                                makeGroupData(
                                  1,
                                  weeklyIncome[1],
                                  weeklyExpense[1],
                                ),
                                makeGroupData(
                                  2,
                                  weeklyIncome[2],
                                  weeklyExpense[2],
                                ),
                                makeGroupData(
                                  3,
                                  weeklyIncome[3],
                                  weeklyExpense[3],
                                ),
                              ],
                            ),
                            duration:
                                const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            buildIndicator(
                              color: Colors.greenAccent,
                              text: "Income",
                            ),
                            const SizedBox(width: 20),
                            buildIndicator(
                              color: Colors.orangeAccent,
                              text: "Expense",
                            ),
                          ],
                        ),
                      ],
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

  BarChartGroupData makeGroupData(
    int x,
    double income,
    double expense,
  ) {
    return BarChartGroupData(
      x: x,
      barsSpace: 5,
      barRods: [
        BarChartRodData(
          toY: income,
          width: 12,
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              Colors.greenAccent,
              Colors.green,
            ],
          ),
        ),
        BarChartRodData(
          toY: expense,
          width: 12,
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              Colors.orangeAccent,
              Colors.red,
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(
    Map<String, int> data,
  ) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    final total = data.values.fold(
      0,
      (prev, item) => prev + item,
    );

    final entries = data.entries.toList();

    return List.generate(entries.length, (i) {
      final isTouched = i == touchedIndex;

      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 120.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;

      final percentage =
          ((entries[i].value / total) * 100)
              .toStringAsFixed(0);

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: entries[i].value.toDouble(),
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(
              color: Colors.black,
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: _Badge(
          entries[i].key,
          size: widgetSize,
          borderColor: Colors.white,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }

  Widget buildIndicator({
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.text, {
    required this.size,
    required this.borderColor,
  });

  final String text;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Text(
          text.characters.first.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: size * .35,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}