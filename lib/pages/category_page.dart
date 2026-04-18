import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';  


class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;

  void openCategoryDialog() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Category"),
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text(
                    (isExpense) 
                    ? "Add Expense" 
                    :"Add Income", 
                    style: GoogleFonts.montserrat(fontSize:18, fontWeight: FontWeight.bold,
                    color: (isExpense) 
                    ? Color.fromARGB(255, 200, 99, 71)
                    : Color.fromARGB(255, 96, 196, 94))
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Category Name",), 
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(onPressed: (){}, child: Text("Save"))
                ],
              )
            ),
          ),
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                IconButton(onPressed: () {
                  openCategoryDialog();
                }, icon: Icon(Icons.add)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              // elevation untuk memberikan efek bayangan pada card
              elevation: 10,
              child: ListTile(
                leading: (isExpense) 
                  ? Icon(Icons.upload, color: const Color.fromARGB(255, 200, 99, 71)) 
                  : Icon(Icons.download, color: const Color.fromARGB(255, 120, 218, 118)),
                title: Text(
                  "Shopping",
                ),
                // trailing untuk menampilkan icon edit dan delete pada setiap kategori
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                  SizedBox(width: 10,),
                  IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
                ],
              ),
            ),
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              // elevation untuk memberikan efek bayangan pada card
              elevation: 10,
              child: ListTile(
                leading: (isExpense) 
                  ? Icon(Icons.upload, color: const Color.fromARGB(255, 200, 99, 71)) 
                  : Icon(Icons.download, color: const Color.fromARGB(255, 120, 218, 118)),
                title: Text(
                  "Food",
                ),
                // trailing untuk menampilkan icon edit dan delete pada setiap kategori
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                  SizedBox(width: 10,),
                  IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
                ],
              ),
            ),
            )
          )
        ],
      ));
  }
}