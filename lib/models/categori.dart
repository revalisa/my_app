import 'package:drift/drift.dart';


@DataClassName('Categories')
class Categori extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 128)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updateddAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

}