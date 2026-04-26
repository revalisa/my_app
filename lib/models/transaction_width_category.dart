import 'database.dart';

class TransactionWidthCategory {
  final Transaction transaction;
  final Category category;
  TransactionWidthCategory({
    // required artinya apa yang di dalamnya wajib diisi, kalau tidak maka akan error
    required this.transaction,
    required this.category,
  });
}