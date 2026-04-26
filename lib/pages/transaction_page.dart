import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/transaction_width_category.dart';
import '../models/database.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWidthCategory? transactionWidthCategory;
  const TransactionPage({Key? key, required this.transactionWidthCategory}) :
    super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final AppDb database = AppDb();
  bool isExpense = true;
  late int type;
  List<String> list = ['Makan dan Jajan', 'Transportasi', 'film'];
  late String dropDownValue = list.first;
  TextEditingController dateController =TextEditingController();
  TextEditingController detailController = TextEditingController();
  TextEditingController ammountController = TextEditingController();
  Category? selectedCategory;
  // insert transaction ke database
  Future insert(
    int amount, DateTime date, String newDetail, int categoryId) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(
      TransactionsCompanion.insert(
        name: newDetail, category_Id: categoryId, transaction_date: date, amount: amount, createdAt: now, updatedAt: now));
    print('Masuk :' + row.toString());
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }
  // override initState untuk menginisialisasi nilai type berdasarkan isExpense
  @override
  void initState() {
    super.initState();
    if (widget.transactionWidthCategory != null){
      updateTransactionView(widget, widget.transactionWidthCategory!);
    }
    type = isExpense ? 2 : 1;
  }

  void updateTransactionView(TransactionPage widget, TransactionWidthCategory transactionWidthCategory) async {
    ammountController.text = 
      transactionWidthCategory.transaction.amount.toString();
    dateController.text = 
      DateFormat('yyyy-MM-dd').format(transactionWidthCategory.transaction.transaction_date);
    detailController.text = transactionWidthCategory.transaction.name;
    type = transactionWidthCategory.category.type;
    (type == 2) ? isExpense = true : isExpense = false;
    selectedCategory = transactionWidthCategory.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Transaction")),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
              // crossAxis untuk mengatur perataan pada kiri kanan
              // mainAxisAlignment atas bawah
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  value: isExpense, 
                  onChanged: (bool value) {
                    setState(() {
                      isExpense = value;
                      type = (isExpense) ? 2 : 1;
                      selectedCategory = null;
                    });
                  } , 
                  // innactiveTrackColor untuk warna track saat switch dalam keadaan off, inactiveThumbColor untuk warna thumb saat switch dalam keadaan off, activeColor untuk warna thumb saat switch dalam keadaan on
                  inactiveTrackColor: const Color.fromARGB(255, 198, 235, 198), 
                  inactiveThumbColor: const Color.fromARGB(255, 120, 218, 118),
                  // activecolor untuk warna thumb saat switch dalam keadaan on
                  activeThumbColor: const Color.fromARGB(255, 200, 99, 71),
                ),
                Text(isExpense ? 'Expense' :'Income', 
                style: GoogleFonts.montserrat(fontSize: 14),)
              ],
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: ammountController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Amount"),
              ),
            ),
            SizedBox(height: 25,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Text('Category', 
                  style: GoogleFonts.montserrat(fontSize: 16,),),
            ),
            FutureBuilder<List<Category>>(
              future: getAllCategory(isExpense ? 2 : 1), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0){
                      selectedCategory == (selectedCategory == null) 
                      ? snapshot.data!.first 
                      : selectedCategory;
                      print('Masuk :' + snapshot.data.toString());
                      return  Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButton<Category>(
                          value: (selectedCategory == null) 
                          ? snapshot.data!.first 
                          : selectedCategory,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_downward),
                          items: (snapshot.data!).map((Category item){
                            return DropdownMenuItem<Category>(
                              value: item, 
                              child: Text(item.name),
                            );
                          }).toList(),
                          // onChanged untuk menangani perubahan nilai dropdown
                          onChanged: (Category ? value){
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                      );
                    } else {
                      return Center(child: Text("data kosong"));
                      }
                  } else {return Center(
                      child: Text("tidak ada data"),
                    );
                  }
                }
              }),
            SizedBox( height: 25,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                // readonly digunakan agar date tidak bisa diedit
                readOnly: true,
                controller: dateController,
                decoration: InputDecoration(labelText: "Enter Date"),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context, 
                    initialDate:DateTime.now(), 
                    firstDate: DateTime.now().subtract(const Duration(days: 140)),
                    lastDate: DateTime.now()
                  );
                    if (pickedDate != null){
                      String formatedDate = 
                        DateFormat('yyyy-MM-dd').format(pickedDate);

                      dateController.text =formatedDate;
                    }
                }
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: detailController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                labelText: "Details"),
              ),
            ),
            SizedBox(height: 25),
            Center(child: ElevatedButton(onPressed: (){
              insert(
                int.parse(ammountController.text), 
                DateTime.parse(dateController.text), 
                detailController.text, 
                selectedCategory!.id);
                // setelah insert data, kembali ke halaman sebelumnya
              Navigator.pop(context, true);
            }, child: Text("Save")),)
          ],
      ))),
      );
  }
}