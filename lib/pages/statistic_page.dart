import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  final Color primary = const Color.fromARGB(255, 147, 45, 79);

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
              child: Text(snapshot.error.toString()),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('Belum ada transaksi'),
            );
          }


          int income = 0;
          int expense = 0;

          List<double> weeklyIncome = [0,0,0,0];
          List<double> weeklyExpense = [0,0,0,0];

          final now = DateTime.now();


          for (var doc in docs) {

            final data =
                doc.data() as Map<String,dynamic>;

            final date =
                (data['date'] as Timestamp).toDate();

            final amount =
                data['amount'] ?? 0;

            final type =
                data['type'] ?? 2;


            if(date.month == now.month &&
               date.year == now.year){

              int week =
                  ((date.day-1) ~/ 7);

              if(week > 3){
                week = 3;
              }


              if(type == 1){
                income += amount as int;
                weeklyIncome[week] +=
                    (amount).toDouble();
              }


              if(type == 2){
                expense += amount as int;
                weeklyExpense[week] +=
                    (amount).toDouble();
              }

            }
          }


          final balance = income-expense;

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


          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              _balanceCard(
                income,
                expense,
                balance,
              ),


              const SizedBox(height:30),


              Text(
                'Perbandingan Keuangan',
                style: GoogleFonts.montserrat(
                  fontSize:20,
                  fontWeight:FontWeight.bold,
                ),
              ),


              SizedBox(
                height:250,
                child: PieChart(
                  PieChartData(
                    sections:[
                      PieChartSectionData(
                        value: income.toDouble(),
                        color: Colors.green,
                        title:'Income',
                      ),

                      PieChartSectionData(
                        value: expense.toDouble(),
                        color: Colors.red,
                        title:'Expense',
                      ),
                    ],
                  ),
                ),
              ),


              const SizedBox(height:30),


              Text(
                'Grafik Mingguan',
                style: GoogleFonts.montserrat(
                  fontSize:20,
                  fontWeight:FontWeight.bold,
                ),
              ),


              SizedBox(
                height:300,
                child: BarChart(
                  BarChartData(

                    maxY: maxChartValue == 0
                        ? 100000
                        : maxChartValue + (maxChartValue * 0.2),

                    barGroups:[
                      for(int i = 0; i < 4; i++)

                        BarChartGroupData(
                          x:i,

                          barRods:[

                            BarChartRodData(
                              toY: weeklyIncome[i],
                              color: Colors.green,
                              width:14,
                              borderRadius: BorderRadius.circular(6),
                            ),


                            BarChartRodData(
                              toY: weeklyExpense[i],
                              color: Colors.red,
                              width:14,
                              borderRadius: BorderRadius.circular(6),
                            ),

                          ],
                        )
                    ],


                    gridData: FlGridData(
                      show:true,
                    ),


                    borderData: FlBorderData(
                      show:false,
                    ),


                    titlesData: FlTitlesData(

                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles:false,
                        ),
                      ),


                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles:false,
                        ),
                      ),


                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(

                          showTitles:true,

                          reservedSize:60,

                          getTitlesWidget:(value, meta){

                            String text;


                            if(value >= 1000000){
                              text =
                              '${(value/1000000).toStringAsFixed(1)}JT';
                            }

                            else if(value >=1000){
                              text =
                              '${(value/1000).toStringAsFixed(0)}K';
                            }

                            else{
                              text =
                              value.toInt().toString();
                            }


                            return Text(
                              text,
                              style:GoogleFonts.montserrat(
                                fontSize:10,
                                fontWeight:FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),


                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(

                          showTitles:true,

                          getTitlesWidget:(value, meta){

                            const weeks=[
                              'W1',
                              'W2',
                              'W3',
                              'W4',
                            ];


                            return Text(
                              weeks[value.toInt()],
                              style:GoogleFonts.montserrat(
                                fontWeight:FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),

                    ),

                  ),
                ),
              )

            ],
          );
        },
      ),
    );
  }



  Widget _balanceCard(
    int income,
    int expense,
    int balance,
  ){

    final money =
        NumberFormat.currency(
          locale:'id_ID',
          symbol:'Rp ',
          decimalDigits:0,
        );


    return Container(
      padding:const EdgeInsets.all(20),
      decoration:BoxDecoration(
        color:primary,
        borderRadius:BorderRadius.circular(25),
      ),

      child:Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children:[

          Text(
            'Keuangan Bulan Ini',
            style:GoogleFonts.montserrat(
              color:Colors.white,
              fontSize:20,
              fontWeight:FontWeight.bold,
            ),
          ),


          const SizedBox(height:15),


          Text(
            'Saldo ${money.format(balance)}',
            style:const TextStyle(
              color:Colors.white,
            ),
          ),


          const SizedBox(height:20),


          Row(
            children:[

              Expanded(
                child:_moneyBox(
                  'Masuk',
                  income,
                  Colors.green,
                ),
              ),


              const SizedBox(width:10),


              Expanded(
                child:_moneyBox(
                  'Keluar',
                  expense,
                  Colors.red,
                ),
              ),

            ],
          )

        ],
      ),
    );
  }



  Widget _moneyBox(
    String title,
    int value,
    Color color,
  ){

    final money =
        NumberFormat.currency(
          locale:'id_ID',
          symbol:'Rp ',
          decimalDigits:0,
        );


    return Container(
      padding:const EdgeInsets.all(12),
      decoration:BoxDecoration(
        color:Colors.white24,
        borderRadius:
            BorderRadius.circular(15),
      ),

      child:Column(
        children:[

          Text(
            title,
            style:
            const TextStyle(
              color:Colors.white,
            ),
          ),

          const SizedBox(height:8),

          Text(
            money.format(value),
            style:TextStyle(
              color:color,
              fontWeight:FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }
}