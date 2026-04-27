import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class UserHabits extends Table {
  DateTimeColumn get date => dateTime()();
  IntColumn get articlesCompleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}

@DriftDatabase(tables: [UserHabits, Folders, SavedIdeas, LikedIdeas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await into(folders).insert(
          FoldersCompanion.insert(
            name: 'Read Later',
            isDefault: const Value(true),
            createdAt: DateTime.now(),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(folders);
          await m.createTable(savedIdeas);
          await m.createTable(likedIdeas);
          await into(folders).insert(
            FoldersCompanion.insert(
              name: 'Read Later',
              isDefault: const Value(true),
              createdAt: DateTime.now(),
            ),
          );
        }
      },
    );
  }
}

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class SavedIdeas extends Table {
  TextColumn get id => text()();
  TextColumn get ideaId => text()();
  TextColumn get articleId => text()();
  TextColumn get articleTitle => text()();
  TextColumn get articleUrl => text()();
  TextColumn get textContent => text()();
  IntColumn get folderId => integer().references(Folders, #id)();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LikedIdeas extends Table {
  TextColumn get id => text()();
  TextColumn get ideaId => text()();
  TextColumn get articleId => text()();
  TextColumn get articleTitle => text()();
  TextColumn get articleUrl => text()();
  TextColumn get textContent => text()();
  DateTimeColumn get likedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'openstash_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

final appDb = AppDatabase();
