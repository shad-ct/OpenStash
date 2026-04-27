import '../database/database.dart';
import 'package:drift/drift.dart';

class StreakRepository {
  final AppDatabase db;

  StreakRepository(this.db);

  /// Helper to normalize a DateTime to midnight (yyyy-MM-dd)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Upserts the date and increments the count
  Future<void> recordArticleCompleted(DateTime date) async {
    final normalizedDate = _normalizeDate(date);

    final habit = await (db.select(db.userHabits)
          ..where((t) => t.date.equals(normalizedDate)))
        .getSingleOrNull();

    if (habit != null) {
      // Increment count
      await db.update(db.userHabits).replace(
            habit.copyWith(articlesCompleted: habit.articlesCompleted + 1),
          );
    } else {
      // Insert new
      await db.into(db.userHabits).insert(
            UserHabitsCompanion.insert(
              date: normalizedDate,
              articlesCompleted: const Value(1),
            ),
          );
    }
  }

  /// Returns a List<DateTime> of all days where count > 0
  Future<List<DateTime>> getCompletedDates() async {
    final query = db.select(db.userHabits)..where((t) => t.articlesCompleted.isBiggerThanValue(0));
    final results = await query.get();
    return results.map((e) => e.date).toList();
  }
}

final streakRepository = StreakRepository(appDb);
