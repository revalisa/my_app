import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // ================= FIREBASE =================
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ================= SWITCH =================
  bool isExpense = true;

  // ================= TYPE =================
  int type = 2;

  // ================= CONTROLLER =================
  final TextEditingController categoryNameController = TextEditingController();

  static const Color primaryColor = Color.fromARGB(255, 147, 45, 79);
  static const Color pageColor = Color.fromARGB(255, 252, 244, 249);

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ================= INSERT =================
  Future<void> insertCategory(String name, int type) async {
    try {
      await firestore.collection('categories').add({
        'name': name,
        'type': type,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      showMessage('Category berhasil ditambahkan');
    } catch (e) {
      debugPrint(e.toString());
      showMessage('Error: $e');
    }
  }

  // ================= UPDATE =================
  Future<void> updateCategory(String id, String newName) async {
    try {
      await firestore.collection('categories').doc(id).update({
        'name': newName,
        'updatedAt': Timestamp.now(),
      });

      showMessage('Category berhasil diupdate');
    } catch (e) {
      debugPrint(e.toString());
      showMessage('Error: $e');
    }
  }

  // ================= DELETE =================
  Future<void> deleteCategory(String id) async {
    try {
      await firestore.collection('categories').doc(id).delete();

      showMessage('Category berhasil dihapus');
    } catch (e) {
      debugPrint(e.toString());
      showMessage('Error: $e');
    }
  }

  Future<void> confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Category'),
          content: const Text('Yakin ingin menghapus category ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deleteCategory(id);
    }
  }

  // ================= DIALOG =================
  void openCategoryDialog(DocumentSnapshot? category) {
    if (category != null) {
      final data = category.data() as Map<String, dynamic>;
      categoryNameController.text = data['name'] ?? '';
    } else {
      categoryNameController.clear();
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            category == null ? 'Tambah Category' : 'Edit Category',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isExpense ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExpense ? Icons.upload : Icons.download,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isExpense ? 'Expense' : 'Income',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: categoryNameController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Nama Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onFieldSubmitted: (_) async {
                  await saveCategory(category, dialogContext);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await saveCategory(category, dialogContext);
                  },
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
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

  Future<void> saveCategory(
    DocumentSnapshot? category,
    BuildContext dialogContext,
  ) async {
    final name = categoryNameController.text.trim();

    if (name.isEmpty) {
      showMessage('Category wajib diisi');
      return;
    }

    if (category == null) {
      await insertCategory(name, isExpense ? 2 : 1);
    } else {
      await updateCategory(category.id, name);
    }

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }

    categoryNameController.clear();
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    categoryNameController.dispose();
    super.dispose();
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 2),
            child: Row(
              children: [
                Text(
                  isExpense ? 'Expense' : 'Income',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: isExpense,
                  onChanged: (value) {
                    setState(() {
                      isExpense = value;
                      type = isExpense ? 2 : 1;
                    });
                  },
                  activeColor: Colors.red,
                  activeTrackColor: Colors.red.shade100,
                  inactiveThumbColor: Colors.green,
                  inactiveTrackColor: Colors.green.shade100,
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 46,
            height: 46,
            child: FloatingActionButton(
              heroTag: 'addCategory',
              elevation: 6,
              backgroundColor: primaryColor,
              onPressed: () {
                openCategoryDialog(null);
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: primaryColor.withOpacity(0.65),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada category',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tekan tombol + untuk menambahkan category.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryCard({
    required QueryDocumentSnapshot item,
    required Map<String, dynamic> data,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        leading: CircleAvatar(
          radius: 21,
          backgroundColor: isExpense ? Colors.red.shade100 : Colors.green.shade100,
          child: Icon(
            isExpense ? Icons.upload : Icons.download,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          data['name'] ?? '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        trailing: Wrap(
          spacing: 6,
          children: [
            IconButton(
              tooltip: 'Hapus',
              onPressed: () async {
                await confirmDelete(item.id);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: () {
                openCategoryDialog(item);
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: pageColor,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            buildHeader(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final item = docs[index];
                      final data = item.data() as Map<String, dynamic>;

                      return buildCategoryCard(
                        item: item,
                        data: data,
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
