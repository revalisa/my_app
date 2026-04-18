import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
 bool isExpense = true;
 List<String> list = ['Makan dan Jajan', 'Transportasi', 'film'];
  late String dropDownValue = list.first;
  TextEditingController dateController =TextEditingController();
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
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Ammout"),
              ),
            ),
            SizedBox(height: 25,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Text('Category', 
                  style: GoogleFonts.montserrat(fontSize: 16,),),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: dropDownValue,
                isExpanded: true,
                icon: Icon(Icons.arrow_back),
                items: list.map<DropdownMenuItem<String>>((String value){
                  return DropdownMenuItem<String>(
                  value: value, 
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String ? value){}),
            ),
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
                    firstDate: DateTime(1999), 
                    lastDate: DateTime(2099));

                    if (pickedDate != null){
                      String formatedDate = 
                        DateFormat('yyyy-MM-dd').format(pickedDate);

                      dateController.text =formatedDate;
                    }
                }
              ),
            ),
            SizedBox(height: 25,),
            Center(child: ElevatedButton(onPressed: (){}, child: Text("Save")),)
          ],
      ))),
      );
  }
}