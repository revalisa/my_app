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
  State<TransactionPage> createState() =>
      _TransactionPageState();
}

class _TransactionPageState
    extends State<TransactionPage> {

  // ================= FIREBASE =================
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // ================= SWITCH =================
  bool isExpense = true;

  // ================= TYPE =================
  int type = 2;

  // ================= CONTROLLER =================
  final TextEditingController
      amountController =
      TextEditingController();

  final TextEditingController
      detailController =
      TextEditingController();

  final TextEditingController
      dateController =
      TextEditingController();

  // ================= CATEGORY =================
  String? selectedCategoryId;
  String? selectedCategoryName;

  // ================= INSERT =================
  Future<void> insertTransaction() async {

    try {

      await firestore
          .collection('transactions')
          .add({

        'amount':
            int.parse(
          amountController.text,
        ),

        'detail':
            detailController.text,

        'categoryId':
            selectedCategoryId,

        'category_name':
            selectedCategoryName,

        'type':
            type,

        'date':
            Timestamp.fromDate(
          DateTime.parse(
            dateController.text,
          ),
        ),

        'createdAt':
            Timestamp.now(),

        'updatedAt':
            Timestamp.now(),
      });

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              'Transaction berhasil disimpan',
            ),
          ),
        );
      }
    }

    catch (e) {

      debugPrint(
        e.toString(),
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    }
  }

  // ================= UPDATE =================
  Future<void> updateTransaction() async {

    try {

      await firestore
          .collection('transactions')
          .doc(widget.docId)
          .update({

        'amount':
            int.parse(
          amountController.text,
        ),

        'detail':
            detailController.text,

        'categoryId':
            selectedCategoryId,

        'category_name':
            selectedCategoryName,

        'type':
            type,

        'date':
            Timestamp.fromDate(
          DateTime.parse(
            dateController.text,
          ),
        ),

        'updatedAt':
            Timestamp.now(),
      });

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              'Transaction berhasil diupdate',
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

  // ================= GET TRANSACTION =================
  Future<void> getTransactionDetail() async {

    if (widget.docId == null) return;

    try {

      final doc =
          await firestore
              .collection('transactions')
              .doc(widget.docId)
              .get();

      if (!doc.exists) return;

      final data =
          doc.data();

      if (data == null) return;

      amountController.text =
          data['amount']
              .toString();

      detailController.text =
          data['detail'] ?? '';

      selectedCategoryId =
          data['categoryId'];

      selectedCategoryName =
          data['category_name'];

      type =
          data['type'] ?? 2;

      isExpense =
          type == 2;

      Timestamp timestamp =
          data['date'];

      DateTime date =
          timestamp.toDate();

      dateController.text =
          DateFormat(
            'yyyy-MM-dd',
          ).format(date);

      setState(() {});
    }

    catch (e) {

      debugPrint(
        e.toString(),
      );
    }
  }

  // ================= INIT =================
  @override
  void initState() {

    super.initState();

    dateController.text =
        DateFormat(
          'yyyy-MM-dd',
        ).format(
          DateTime.now(),
        );

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

          widget.docId == null
              ? 'Add Transaction'
              : 'Edit Transaction',
        ),
      ),

      body: SingleChildScrollView(

        child: SafeArea(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ================= SWITCH =================
              Row(

                children: [

                  Switch(

                    value: isExpense,

                    onChanged: (value) {

                      setState(() {

                        isExpense =
                            value;

                        type =
                            isExpense
                                ? 2
                                : 1;

                        selectedCategoryId =
                            null;

                        selectedCategoryName =
                            null;
                      });
                    },

                    activeThumbColor:
                        Colors.red,

                    inactiveThumbColor:
                        Colors.green,
                  ),

                  Text(

                    isExpense
                        ? 'Expense'
                        : 'Income',

                    style:
                        GoogleFonts.montserrat(

                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              // ================= AMOUNT =================
              Padding(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: TextFormField(

                  keyboardType:
                      TextInputType.number,

                  controller:
                      amountController,

                  decoration:
                      const InputDecoration(

                    border:
                        UnderlineInputBorder(),

                    labelText:
                        "Amount",
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // ================= CATEGORY =================
              Padding(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: Text(

                  'Category',

                  style:
                      GoogleFonts.montserrat(

                    fontSize: 16,
                  ),
                ),
              ),

              StreamBuilder<QuerySnapshot>(

                stream: firestore
                    .collection(
                      'categories',
                    )
                    .where(
                      'type',
                      isEqualTo: type,
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

                  // EMPTY
                  if (docs.isEmpty) {

                    return const Padding(

                      padding:
                          EdgeInsets.all(16),

                      child: Text(
                        'Category kosong',
                      ),
                    );
                  }

                  // DEFAULT CATEGORY
                  selectedCategoryId ??=
                      docs.first.id;

                  selectedCategoryName ??=
                      (docs.first.data()
                              as Map<String,
                                  dynamic>)['name'];

                  return Padding(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    child:
                        DropdownButton<String>(

                      value:
                          selectedCategoryId,

                      isExpanded: true,

                      items:
                          docs.map((item) {

                        final data =
                            item.data()
                                as Map<String,
                                    dynamic>;

                        return DropdownMenuItem<String>(

                          value:
                              item.id,

                          child: Text(
                            data['name'],
                          ),
                        );
                      }).toList(),

                      onChanged: (value) {

                        setState(() {

                          selectedCategoryId =
                              value;

                          final selected =
                              docs.firstWhere(
                            (e) =>
                                e.id ==
                                value,
                          );

                          selectedCategoryName =
                              (selected.data()
                                      as Map<String,
                                          dynamic>)['name'];
                        });
                      },
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 25,
              ),

              // ================= DATE =================
              Padding(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: TextField(

                  readOnly: true,

                  controller:
                      dateController,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Enter Date",
                  ),

                  onTap: () async {

                    DateTime? pickedDate =
                        await showDatePicker(

                      context:
                          context,

                      initialDate:
                          DateTime.now(),

                      firstDate:
                          DateTime.now()
                              .subtract(
                        const Duration(
                          days: 365,
                        ),
                      ),

                      lastDate:
                          DateTime.now(),
                    );

                    if (pickedDate != null) {

                      dateController.text =
                          DateFormat(
                            'yyyy-MM-dd',
                          ).format(
                            pickedDate,
                          );
                    }
                  },
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // ================= DETAIL =================
              Padding(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: TextFormField(

                  controller:
                      detailController,

                  decoration:
                      const InputDecoration(

                    border:
                        UnderlineInputBorder(),

                    labelText:
                        "Details",
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // ================= SAVE BUTTON =================
              Center(

                child: ElevatedButton(

                  onPressed: () async {

                    // VALIDASI
                    if (amountController
                        .text
                        .isEmpty) {

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(

                        const SnackBar(
                          content: Text(
                            'Amount wajib diisi',
                          ),
                        ),
                      );

                      return;
                    }

                    if (dateController
                        .text
                        .isEmpty) {

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(

                        const SnackBar(
                          content: Text(
                            'Tanggal wajib diisi',
                          ),
                        ),
                      );

                      return;
                    }

                    // INSERT
                    if (widget.docId ==
                        null) {

                      await insertTransaction();
                    }

                    // UPDATE
                    else {

                      await updateTransaction();
                    }

                    if (mounted) {

                      Navigator.pop(
                        context,
                        true,
                      );
                    }
                  },

                  child: const Text(
                    "Save",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}