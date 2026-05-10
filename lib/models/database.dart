import 'dart:io';

import 'package:drift/drift.dart';
// These imports are used to open the database
import 'package:drift/native.dart';
import 'package:my_app/models/transaction_width_category.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'category.dart';
import 'transaction.dart';

part 'database.g.dart';

@DriftDatabase(
  // relative import for the drift file. Drift also supports `package:`
  // imports
  tables: [Categories, Transactions],
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD category
  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
    .get();
  }

  // update category
  Future updateCategoryRepo(int id, String name) async {
    return (update(categories)..where((tbl) => tbl.id.equals(id)))
    .write(CategoriesCompanion(name: Value(name)));
  }

  // delete category
  Future deleteCategoryRepo(int id) async {
    return(delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  // transaction
  Stream<List<TransactionWidthCategory>> getTransactionByDate(DateTime date) {
    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_Id))
    ])
      ..where(transactions.transaction_date.equals(date));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWidthCategory(
          transaction: row.readTable(transactions),
          category: row.readTable(categories),
        );
      }).toList();
    });
  }

    // update transaction
  Future updateTransactionRepo(int id, int amount, int categoryId, DateTime transactionDate, String nameDetails) async {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        amount: Value(amount),
        category_Id: Value(categoryId),
        transaction_date: Value(transactionDate),
        name: Value(nameDetails),
      )
    );
  }
    // delete transaction
  Future deleteTransactionRepo(int id) async {
    return(delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
