import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  final Color primary = const Color.fromARGB(255, 147, 45, 79);

  // Bulan yang sedang dipilih
  String selectedMonth = 'Januari';

  // Daftar bulan
  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User belum login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .orderBy('date', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('Belum ada transaksi'),
            );
          }

          // ==========================================
          // TOTAL PEMASUKAN DAN PENGELUARAN
          // BULAN YANG DIPILIH
          // ==========================================

          double income = 0;
          double expense = 0;

          // Grafik mingguan
          final List<double> weeklyIncome = [0, 0, 0, 0];
          final List<double> weeklyExpense = [0, 0, 0, 0];

          // Mengubah nama bulan menjadi angka
          final int selectedMonthIndex =
              months.indexOf(selectedMonth) + 1;

          // Tahun sekarang
          final int selectedYear = DateTime.now().year;

          // ==========================================
          // LOOP DATA TRANSAKSI
          // ==========================================

          for (var doc in docs) {
            final data =
                doc.data() as Map<String, dynamic>;

            // Ambil tanggal
            final date =
                (data['date'] as Timestamp).toDate();

            // Ambil jumlah
            final double amount =
                (data['amount'] as num?)?.toDouble() ?? 0;

            // Tipe transaksi
            final int type =
                (data['type'] as num?)?.toInt() ?? 2;

            // ========================================
            // FILTER BERDASARKAN BULAN DAN TAHUN
            // ========================================

            if (date.month == selectedMonthIndex &&
                date.year == selectedYear) {

              // ======================================
              // MENENTUKAN MINGGU
              // ======================================

              int week = ((date.day - 1) ~/ 7);

              if (week > 3) {
                week = 3;
              }

              // ======================================
              // PEMASUKAN
              // type == 1
              // ======================================

              if (type == 1) {
                income += amount;

                weeklyIncome[week] += amount;
              }

              // ======================================
              // PENGELUARAN
              // type == 2
              // ======================================

              if (type == 2) {
                expense += amount;

                weeklyExpense[week] += amount;
              }
            }
          }

          // ==========================================
          // SALDO
          // PEMASUKAN - PENGELUARAN
          // ==========================================

          final double balance = income - expense;

          // ==========================================
          // MAX VALUE GRAFIK
          // ==========================================

          double maxChartValue = 0;

          for (var value in weeklyIncome) {
            if (value > maxChartValue) {
              maxChartValue = value;
            }
          }

          for (var value in weeklyExpense) {
            if (value > maxChartValue) {
              maxChartValue = value;
            }
          }

          // ==========================================
          // TAMPILAN
          // ==========================================

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // ======================================
              // CARD KEUANGAN
              // ======================================

              _balanceCard(
                income,
                expense,
                balance,
              ),

              const SizedBox(height: 30),

              // ======================================
              // PERBANDINGAN KEUANGAN
              // ======================================

              Text(
                'Perbandingan Keuangan',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: [
                      // PEMASUKAN
                      PieChartSectionData(
                        value: income,
                        color: Colors.green,
                        title: 'Income',
                        radius: 80,
                      ),

                      // PENGELUARAN
                      PieChartSectionData(
                        value: expense,
                        color: Colors.red,
                        title: 'Expense',
                        radius: 80,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ======================================
              // GRAFIK MINGGUAN
              // ======================================

              Text(
                'Grafik Mingguan',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    maxY: maxChartValue == 0
                        ? 100000
                        : maxChartValue +
                            (maxChartValue * 0.2),

                    barGroups: [
                      for (int i = 0; i < 4; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [

                            // PEMASUKAN
                            BarChartRodData(
                              toY: weeklyIncome[i],
                              color: Colors.green,
                              width: 14,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),

                            // PENGELUARAN
                            BarChartRodData(
                              toY: weeklyExpense[i],
                              color: Colors.red,
                              width: 14,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                          ],
                        ),
                    ],

                    gridData: const FlGridData(
                      show: true,
                    ),

                    borderData: FlBorderData(
                      show: false,
                    ),

                    titlesData: FlTitlesData(

                      // ------------------------------
                      // ATAS
                      // ------------------------------

                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),

                      // ------------------------------
                      // KANAN
                      // ------------------------------

                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),

                      // ------------------------------
                      // KIRI
                      // ------------------------------

                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,

                          getTitlesWidget:
                              (value, meta) {
                            String text;

                            if (value >= 1000000) {
                              text =
                                  '${(value / 1000000).toStringAsFixed(1)}JT';
                            } else if (value >= 1000) {
                              text =
                                  '${(value / 1000).toStringAsFixed(0)}K';
                            } else {
                              text =
                                  value.toInt().toString();
                            }

                            return Text(
                              text,
                              style:
                                  GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),

                      // ------------------------------
                      // BAWAH
                      // ------------------------------

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,

                          getTitlesWidget:
                              (value, meta) {
                            const weeks = [
                              'W1',
                              'W2',
                              'W3',
                              'W4',
                            ];

                            final index =
                                value.toInt();

                            if (index < 0 ||
                                index >= weeks.length) {
                              return const SizedBox();
                            }

                            return Text(
                              weeks[index],
                              style:
                                  GoogleFonts.montserrat(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================================================
  // CARD KEUANGAN
  // ==================================================

  Widget _balanceCard(
    double income,
    double expense,
    double balance,
  ) {
    final money = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // ==========================================
          // JUDUL
          // ==========================================

          Text(
            'Keuangan $selectedMonth',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // ==========================================
          // DROPDOWN BULAN
          // ==========================================

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),

            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonth,

                isExpanded: true,

                dropdownColor: primary,

                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),

                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),

                items: months.map((month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(
                      month,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),

                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedMonth = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ==========================================
          // SALDO
          // ==========================================

          Text(
            'Saldo ${money.format(balance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // ==========================================
          // PEMASUKAN & PENGELUARAN
          // ==========================================

          Row(
            children: [

              Expanded(
                child: _moneyBox(
                  'Masuk',
                  income,
                  Colors.green,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _moneyBox(
                  'Keluar',
                  expense,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================================================
  // MONEY BOX
  // ==================================================

  Widget _moneyBox(
    String title,
    double value,
    Color color,
  ) {
    final money = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            money.format(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}