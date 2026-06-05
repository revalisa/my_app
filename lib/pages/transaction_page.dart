import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  // FIREBASE DOC ID
  final String? docId;

  const TransactionPage({
    super.key,
    this.docId,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  // ================= FIREBASE =================
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ================= SWITCH =================
  bool isExpense = true;

  // ================= TYPE =================
  int type = 2;

  // ================= CONTROLLER =================
  final TextEditingController amountController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // ================= CATEGORY =================
  String? selectedCategoryId;
  String? selectedCategoryName;

  // ================= AMOUNT CALCULATOR =================
  int calculateAmount(String input) {
    final cleanInput = input.replaceAll(' ', '');

    if (cleanInput.isEmpty) {
      throw Exception('Amount wajib diisi');
    }

    if (!RegExp(r'^[0-9+]+$').hasMatch(cleanInput)) {
      throw Exception('Amount hanya boleh angka dan tanda +');
    }

    final numbers = cleanInput.split('+');
    int total = 0;

    for (final number in numbers) {
      if (number.isEmpty) {
        throw Exception('Format amount tidak valid');
      }

      total += int.parse(number);
    }

    return total;
  }

  Future<Map<String, dynamic>> buildTransactionData({
    bool isUpdate = false,
  }) async {
    if (selectedCategoryId == null || selectedCategoryName == null) {
      throw Exception('Category wajib dipilih');
    }

    final amount = calculateAmount(amountController.text);
    final date = DateTime.tryParse(dateController.text);

    if (date == null) {
      throw Exception('Tanggal tidak valid');
    }

    final data = <String, dynamic>{
      'amount': amount,
      'detail': detailController.text.trim(),
      'categoryId': selectedCategoryId,
      'category_name': selectedCategoryName,
      'type': type,
      'date': Timestamp.fromDate(date),
      'updatedAt': Timestamp.now(),
    };

    if (!isUpdate) {
      data['createdAt'] = Timestamp.now();
    }

    return data;
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ================= INSERT =================
  Future<void> insertTransaction() async {
    try {
      final data = await buildTransactionData();

      await firestore.collection('transactions').add(data);

      showMessage('Transaction berhasil disimpan');
    } catch (e) {
      debugPrint(e.toString());
      showMessage('Error: $e');
    }
  }

  // ================= UPDATE =================
  Future<void> updateTransaction() async {
    if (widget.docId == null) return;

    try {
      final data = await buildTransactionData(isUpdate: true);

      await firestore.collection('transactions').doc(widget.docId).update(data);

      showMessage('Transaction berhasil diupdate');
    } catch (e) {
      debugPrint(e.toString());
      showMessage('Error: $e');
    }
  }

  // ================= GET TRANSACTION =================
  Future<void> getTransactionDetail() async {
    if (widget.docId == null) return;

    try {
      final doc = await firestore.collection('transactions').doc(widget.docId).get();

      if (!doc.exists) return;

      final data = doc.data();

      if (data == null) return;

      amountController.text = data['amount'].toString();
      detailController.text = data['detail'] ?? '';
      selectedCategoryId = data['categoryId'];
      selectedCategoryName = data['category_name'];
      type = data['type'] ?? 2;
      isExpense = type == 2;

      final timestamp = data['date'];

      if (timestamp is Timestamp) {
        dateController.text = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
      showMessage('Error: $e');
    }
  }

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    getTransactionDetail();
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    amountController.dispose();
    detailController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.docId == null ? 'Add Transaction' : 'Edit Transaction',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= SWITCH =================
              Row(
                children: [
                  Switch(
                    value: isExpense,
                    onChanged: (value) {
                      setState(() {
                        isExpense = value;
                        type = isExpense ? 2 : 1;
                        selectedCategoryId = null;
                        selectedCategoryName = null;
                      });
                    },
                    activeThumbColor: Colors.red,
                    inactiveThumbColor: Colors.green,
                  ),
                  Text(
                    isExpense ? 'Expense' : 'Income',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ================= AMOUNT =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: amountController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Amount',
                    hintText: 'nominal harga',
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= CATEGORY =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Category',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                  ),
                ),
              ),

              StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('categories')
                    .where(
                      'type',
                      isEqualTo: type,
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
                      child: Text(snapshot.error.toString()),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    selectedCategoryId = null;
                    selectedCategoryName = null;

                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Category kosong'),
                    );
                  }

                  final categoryStillExists = docs.any(
                    (item) => item.id == selectedCategoryId,
                  );

                  if (selectedCategoryId == null || !categoryStillExists) {
                    final firstCategory = docs.first;
                    final firstData = firstCategory.data() as Map<String, dynamic>;

                    selectedCategoryId = firstCategory.id;
                    selectedCategoryName = firstData['name'];
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<String>(
                      value: selectedCategoryId,
                      isExpanded: true,
                      items: docs.map((item) {
                        final data = item.data() as Map<String, dynamic>;

                        return DropdownMenuItem<String>(
                          value: item.id,
                          child: Text(data['name'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedCategoryId = value;

                          final selected = docs.firstWhere(
                            (item) => item.id == value,
                          );

                          selectedCategoryName =
                              (selected.data() as Map<String, dynamic>)['name'];
                        });
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // ================= DATE =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  readOnly: true,
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Date',
                  ),
                  onTap: () async {
                    final today = DateTime.now();
                    final currentDate =
                        DateTime.tryParse(dateController.text) ?? today;

                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: currentDate,
                      firstDate: today.subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: today,
                    );

                    if (pickedDate != null) {
                      dateController.text = DateFormat('yyyy-MM-dd').format(
                        pickedDate,
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // ================= DETAIL =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: detailController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Details',
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= SAVE BUTTON =================
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (amountController.text.trim().isEmpty) {
                      showMessage('Amount wajib diisi');
                      return;
                    }

                    if (dateController.text.trim().isEmpty) {
                      showMessage('Tanggal wajib diisi');
                      return;
                    }

                    if (selectedCategoryId == null) {
                      showMessage('Category wajib dipilih');
                      return;
                    }

                    if (widget.docId == null) {
                      await insertTransaction();
                    } else {
                      await updateTransaction();
                    }

                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
