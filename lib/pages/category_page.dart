import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() =>
      _CategoryPageState();
}

class _CategoryPageState
    extends State<CategoryPage> {

  // ================= FIREBASE =================
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // ================= SWITCH =================
  bool isExpense = true;

  // ================= TYPE =================
  int type = 2;

  // ================= CONTROLLER =================
  final TextEditingController
      categoryNameController =
      TextEditingController();

  // ================= INSERT =================
  Future<void> insertCategory(
    String name,
    int type,
  ) async {

    try {

      await firestore
          .collection('categories')
          .add({

        'name': name,
        'type': type,

        // gunakan Timestamp firebase
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              'Category berhasil ditambahkan',
            ),
          ),
        );
      }
    }

    catch (e) {

      debugPrint(e.toString());

      if (mounted) {

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
  }

  // ================= UPDATE =================
  Future<void> updateCategory(
    String id,
    String newName,
  ) async {

    try {

      await firestore
          .collection('categories')
          .doc(id)
          .update({

        'name': newName,
        'updatedAt': Timestamp.now(),
      });

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              'Category berhasil diupdate',
            ),
          ),
        );
      }
    }

    catch (e) {

      debugPrint(e.toString());
    }
  }

  // ================= DELETE =================
  Future<void> deleteCategory(
    String id,
  ) async {

    try {

      await firestore
          .collection('categories')
          .doc(id)
          .delete();

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              'Category berhasil dihapus',
            ),
          ),
        );
      }
    }

    catch (e) {

      debugPrint(e.toString());
    }
  }

  // ================= DIALOG =================
  void openCategoryDialog(
    DocumentSnapshot? category,
  ) {

    // EDIT
    if (category != null) {

      final data =
          category.data()
              as Map<String, dynamic>;

      categoryNameController.text =
          data['name'] ?? '';
    }

    // ADD
    else {

      categoryNameController.clear();
    }

    showDialog(

      context: context,

      builder: (BuildContext context) {

        return AlertDialog(

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Text(

            category == null
                ? "Tambah Category"
                : "Edit Category",

            style:
                GoogleFonts.montserrat(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              // TYPE TEXT
              Text(

                isExpense
                    ? "Expense"
                    : "Income",

                style:
                    GoogleFonts.montserrat(

                  fontSize: 18,

                  fontWeight:
                      FontWeight.bold,

                  color: isExpense
                      ? Colors.red
                      : Colors.green,
                ),
              ),

              const SizedBox(height: 20),

              // INPUT
              TextFormField(

                controller:
                    categoryNameController,

                decoration: InputDecoration(

                  hintText:
                      " Category",

                  border:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // BUTTON
              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color.fromARGB(
                      255,
                      147,
                      45,
                      79,
                    ),

                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                  ),

                  onPressed: () async {

                    // VALIDASI
                    if (categoryNameController
                        .text
                        .trim()
                        .isEmpty) {

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(

                        const SnackBar(
                          content: Text(
                            '  category wajib diisi',
                          ),
                        ),
                      );

                      return;
                    }

                    // INSERT
                    if (category == null) {

                      await insertCategory(

                        categoryNameController
                            .text
                            .trim(),

                        isExpense
                            ? 2
                            : 1,
                      );
                    }

                    // UPDATE
                    else {

                      await updateCategory(

                        category.id,

                        categoryNameController
                            .text
                            .trim(),
                      );
                    }

                    if (mounted) {

                      Navigator.pop(context);
                    }

                    categoryNameController
                        .clear();
                  },

                  child: Text(

                    "Simpan",

                    style:
                        GoogleFonts.montserrat(

                      color: Colors.white,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= DISPOSE =================
  @override
  void dispose() {

    categoryNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(

        child: Column(

          children: [

            // ================= HEADER =================
            Padding(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),

              child: Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  // SWITCH
                  Row(

                    children: [

                      Text(

                        isExpense
                            ? "Expense"
                            : "Income",

                        style:
                            GoogleFonts
                                .montserrat(

                          fontWeight:
                              FontWeight.bold,

                          color: isExpense
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),

                      Switch(

                        value: isExpense,

                        onChanged: (value) {

                          setState(() {

                            isExpense = value;

                            // FIX
                            type = isExpense
                                ? 2
                                : 1;
                          });
                        },

                        activeThumbColor:
                            Colors.red,

                        inactiveThumbColor:
                            Colors.green,
                      ),
                    ],
                  ),

                  // ADD BUTTON
                  FloatingActionButton.small(

                    backgroundColor:
                        const Color.fromARGB(
                      255,
                      147,
                      45,
                      79,
                    ),

                    onPressed: () {

                      openCategoryDialog(
                        null,
                      );
                    },

                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ================= LIST =================
            Expanded(

              child:
                  StreamBuilder<QuerySnapshot>(

                // FIX QUERY
                stream: firestore
                    .collection('categories')
                    .where(
                      'type',
                      isEqualTo: type,
                    )
                    .snapshots(),

                builder:
                    (context, snapshot) {

                  // LOADING
                  if (snapshot
                          .connectionState ==
                      ConnectionState
                          .waiting) {

                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  // ERROR
                  if (snapshot.hasError) {

                    return Center(

                      child: Text(
                        'Error: ${snapshot.error}',
                      ),
                    );
                  }

                  // DATA
                  final docs =
                      snapshot.data?.docs ??
                          [];

                  // EMPTY
                  if (docs.isEmpty) {

                    return Center(

                      child: Text(

                        "Tidak ada category",

                        style:
                            GoogleFonts
                                .montserrat(
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  // LIST
                  return ListView.builder(

                    itemCount: docs.length,

                    itemBuilder:
                        (context, index) {

                      final item =
                          docs[index];

                      final data =
                          item.data()
                              as Map<String,
                                  dynamic>;

                      return Padding(

                        padding:
                            const EdgeInsets
                                .symmetric(

                          horizontal: 16,
                          vertical: 6,
                        ),

                        child: Card(

                          elevation: 3,

                          shape:
                              RoundedRectangleBorder(

                            borderRadius:
                                BorderRadius
                                    .circular(
                              18,
                            ),
                          ),

                          child: ListTile(

                            contentPadding:
                                const EdgeInsets
                                    .all(12),

                            // ICON
                            leading:
                                CircleAvatar(

                              backgroundColor:
                                  isExpense
                                      ? Colors.red
                                          .shade100
                                      : Colors
                                          .green
                                          .shade100,

                              child: Icon(

                                isExpense
                                    ? Icons.upload
                                    : Icons
                                        .download,

                                color:
                                    isExpense
                                        ? Colors
                                            .red
                                        : Colors
                                            .green,
                              ),
                            ),

                            // TITLE
                            title: Text(

                              // FIX NULL
                              data['name'] ??
                                  '-',

                              style:
                                  GoogleFonts
                                      .montserrat(

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            // ACTION
                            trailing: Row(

                              mainAxisSize:
                                  MainAxisSize
                                      .min,

                              children: [

                                // DELETE
                                IconButton(

                                  onPressed:
                                      () async {

                                    bool? confirm =
                                        await showDialog(

                                      context:
                                          context,

                                      builder:
                                          (_) {

                                        return AlertDialog(

                                          title:
                                              const Text(
                                            'Hapus Category',
                                          ),

                                          content:
                                              const Text(
                                            'Yakin ingin menghapus?',
                                          ),

                                          actions: [

                                            TextButton(

                                              onPressed:
                                                  () {

                                                Navigator.pop(
                                                  context,
                                                  false,
                                                );
                                              },

                                              child:
                                                  const Text(
                                                'Batal',
                                              ),
                                            ),

                                            TextButton(

                                              onPressed:
                                                  () {

                                                Navigator.pop(
                                                  context,
                                                  true,
                                                );
                                              },

                                              child:
                                                  const Text(
                                                'Hapus',
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm ==
                                        true) {

                                      await deleteCategory(
                                        item.id,
                                      );
                                    }
                                  },

                                  icon:
                                      const Icon(
                                    Icons.delete,
                                    color:
                                        Colors
                                            .red,
                                  ),
                                ),

                                // EDIT
                                IconButton(

                                  onPressed:
                                      () {

                                    openCategoryDialog(
                                      item,
                                    );
                                  },

                                  icon:
                                      const Icon(
                                    Icons.edit,
                                    color:
                                        Colors
                                            .blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}