import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/pages/statistic_page.dart';
import 'package:my_app/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;

  final user = FirebaseAuth.instance.currentUser;
  final String userUid = FirebaseAuth.instance.currentUser?.uid ?? '';

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
  // ================= FIREBASE =================
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static const Color primaryColor = Color.fromARGB(255, 147, 45, 79);
  static const Color softPink = Color.fromARGB(255, 224, 173, 190);
  static const Color pageColor = Color.fromARGB(255, 252, 244, 249);

  // ================= DELETE =================
  Future<void> deleteTransaction(String id) async {
    try {
         await firestore
        .collection('users')
        .doc(widget.userUid)
        .collection('transactions')
        .doc(id)
        .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil menghapus data'),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus data: $e'),
          ),
        );
      }
    }
  }

  Future<void> confirmDelete(String id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus transaksi?'),
          content: const Text('Data yang sudah dihapus tidak bisa dikembalikan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await deleteTransaction(id);
    }
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Finance  Tracker',
              style: GoogleFonts.montserrat(
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: primaryColor.withOpacity(0.35),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.bar_chart,
              size: 18,
            ),
            label: Text(
              'Chart',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryItem({
    required String title,
    required int amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.formatCurrency.format(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryCard({
    // required artinya total pemasukan dan pengeluaran untuk tanggal yang dipilih
    required int totalIncome,
    required int totalExpense,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: softPink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // buildSummaryItem artinya membuat ringkasan
          buildSummaryItem(
            title: 'Pemasukan',
            amount: totalIncome,
            icon: Icons.download,
            iconColor: Colors.green,
          ),
          const SizedBox(width: 14),
          buildSummaryItem(
            title: 'Pengeluaran',
            amount: totalExpense,
            icon: Icons.upload,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }
  // buildEmptyState artinya membuat tampilan ketika tidak ada transaksi pada tanggal yang dipilih
  Widget buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: primaryColor.withOpacity(0.7),
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada transaksi',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tekan tombol + untuk menambahkan data.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // buildTransactionCard artinya membuat tampilan untuk setiap transaksi yang ada pada tanggal yang dipilih
  Widget buildTransactionCard({
    required QueryDocumentSnapshot item,
    required Map<String, dynamic> data,
  }) {
    final isExpense = data['type'] == 2;
    final amount = data['amount'] ?? 0;
    final categoryName = data['category_name'] ?? '-';
    final detail = data['detail'] ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(
          left: 14,
          right: 8,
          top: 8,
          bottom: 8,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: pageColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isExpense ? Icons.upload : Icons.download,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          widget.formatCurrency.format(amount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            '$categoryName - $detail',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.black.withOpacity(0.62),
            ),
          ),
        ),
        trailing: Wrap(
          spacing: 2,
          children: [
            IconButton(
              tooltip: 'Hapus',
              onPressed: () async {
                await confirmDelete(item.id);
              },
              icon: Icon(
                Icons.delete,
                color: Colors.black.withOpacity(0.58),
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => TransactionPage(
                      docId: item.id,
                    ),
                  ),
                )
                    .then((value) {
                  if (mounted) {
                    setState(() {});
                  }
                });
              },
              icon: const Icon(
                Icons.edit,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    final endDate = startDate.add(const Duration(days: 1));

    return Container(
      color: pageColor,
      child: SafeArea(
        top: false,
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('users')
              .doc(widget.userUid)
              .collection('transactions')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                'date',
                isLessThan: Timestamp.fromDate(endDate),
              )
              .orderBy(
                'date',
                descending: true,
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            int totalIncome = 0;
            int totalExpense = 0;

            for (final item in docs) {
              final data = item.data() as Map<String, dynamic>;
              final amount = data['amount'] ?? 0;

              if (data['type'] == 1) {
                totalIncome += amount as int;
              }

              if (data['type'] == 2) {
                totalExpense += amount as int;
              }
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(),
                  buildSummaryCard(
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Text(
                      'Transaksi',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (docs.isEmpty)
                    buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final item = docs[index];
                        final data = item.data() as Map<String, dynamic>;

                        return buildTransactionCard(
                          item: item,
                          data: data,
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
