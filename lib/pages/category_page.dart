import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../models/database.dart'; 


class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;
  int type = 2;
  final AppDb database = AppDb();
  TextEditingController categoryNameController = TextEditingController();

  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.categories).insertReturning(
      CategoriesCompanion.insert(
        name: name, type: type, createdAt: now, updatedAt: now));
    print('Masuk :' + row.toString());
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future updateCategory(int categoryId, String NewName) async {
   return await database.updateCategoryRepo(categoryId, NewName);
  }

  void openCategoryDialog(Category? category) {
    if (category != null) {
      categoryNameController.text = category.name;
    } ;
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
                    controller: categoryNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Category Name",), 
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(onPressed: (){
                    if( category == null) {
                      insert(categoryNameController.text, isExpense ? 2 : 1);// insert category
                    }
                    else {
                      updateCategory(category.id, categoryNameController.text);
                      // update category
                    }
                    Navigator.of(context, rootNavigator: true)
                    .pop('dialog');
                    categoryNameController.clear();
                    setState(() {});
                  }, 
                  child: Text("Save"))
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
                      type = value ? 2 : 1;
                    });
                  } , 
                  // innactiveTrackColor untuk warna track saat switch dalam keadaan off, inactiveThumbColor untuk warna thumb saat switch dalam keadaan off, activeColor untuk warna thumb saat switch dalam keadaan on
                  inactiveTrackColor: const Color.fromARGB(255, 198, 235, 198), 
                  inactiveThumbColor: const Color.fromARGB(255, 120, 218, 118),
                  // activecolor untuk warna thumb saat switch dalam keadaan on
                  activeThumbColor: const Color.fromARGB(255, 200, 99, 71),
                ),
                IconButton(onPressed: () {
                  openCategoryDialog(null);
                }, icon: Icon(Icons.add)),
              ],
            ),
          ),
          FutureBuilder<List<Category>>(
            future: getAllCategory(type),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                // jika ada datanya
                if (snapshot.hasData) {
                  if (snapshot.data!.length > 0) {
                    return ListView.builder(
                      // shrinkWrap untuk mengatur ukuran ListView sesuai dengan jumlah item yang ada, 
                      //reverse untuk membalik urutan item dalam ListView, 
                      //physics untuk mengatur perilaku scroll pada ListView
                      shrinkWrap: true,
                      reverse: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 10,
                            child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {},
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        openCategoryDialog(snapshot.data![index]);
                                      },
                                    )
                                  ],
                                ),
                                leading: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: (isExpense)
                                        ? Icon(Icons.upload,
                                            color: Colors.redAccent[400])
                                        : Icon(
                                            Icons.download,
                                            color: Colors.greenAccent[400],
                                          )),
                                title: Text(snapshot.data![index].name)),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text('Tidak ada data..!!'),
                    );
                  }
                } else {
                  return Center(
                    child: Text('Tidak ada data..!!'),
                  );
                }
              }
            },
          )
        ],
      ));
  }
}