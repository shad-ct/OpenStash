import 'dart:async';
import 'package:drift/drift.dart';
import '../database/database.dart';

class LibraryRepository {
  LibraryRepository(this._db);

  final AppDatabase _db;

  // -- Folders --

  Future<List<Folder>> getFolders() async {
    return _db.select(_db.folders).get();
  }

  Future<Folder> createFolder(String name) async {
    final folder = FoldersCompanion.insert(
      name: name,
      createdAt: DateTime.now(),
    );
    final id = await _db.into(_db.folders).insert(folder);
    return (await _db.select(_db.folders)..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<void> updateFolder(int id, String name) async {
    await (_db.update(_db.folders)..where((tbl) => tbl.id.equals(id))).write(FoldersCompanion(name: Value(name)));
  }

  Future<void> deleteFolder(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.savedIdeas)..where((tbl) => tbl.folderId.equals(id))).go();
      await (_db.delete(_db.folders)..where((tbl) => tbl.id.equals(id))).go();
    });
  }
  
  Future<Folder?> getDefaultFolder() async {
    final query = _db.select(_db.folders)..where((tbl) => tbl.isDefault.equals(true));
    return query.getSingleOrNull();
  }

  // -- Saved Ideas --

  Stream<List<SavedIdea>> watchSavedIdeas(int folderId) {
    final query = _db.select(_db.savedIdeas)..where((tbl) => tbl.folderId.equals(folderId))..orderBy([(t) => OrderingTerm.desc(t.savedAt)]);
    return query.watch();
  }

  Future<void> saveIdea({
    required String ideaId,
    required String articleId,
    required String articleTitle,
    required String articleUrl,
    required String textContent,
    String? imageUrl,
    required int folderId,
  }) async {
    await _db.into(_db.savedIdeas).insert(
      SavedIdeasCompanion.insert(
        id: ideaId,
        ideaId: ideaId,
        articleId: articleId,
        articleTitle: articleTitle,
        articleUrl: articleUrl,
        textContent: textContent,
        imageUrl: Value(imageUrl),
        folderId: folderId,
        savedAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> removeSavedIdea(String ideaId) async {
    await (_db.delete(_db.savedIdeas)..where((tbl) => tbl.id.equals(ideaId))).go();
  }

  Future<bool> isIdeaSaved(String ideaId) async {
    final countExp = _db.savedIdeas.id.count();
    final query = _db.selectOnly(_db.savedIdeas)..addColumns([countExp])..where(_db.savedIdeas.id.equals(ideaId));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return (result ?? 0) > 0;
  }
  
  Future<Set<String>> getSavedIdeaIdsForArticle(String articleId) async {
    final query = _db.selectOnly(_db.savedIdeas)..addColumns([_db.savedIdeas.id])..where(_db.savedIdeas.articleId.equals(articleId));
    final ids = await query.map((row) => row.read(_db.savedIdeas.id)!).get();
    return ids.toSet();
  }

  // -- Liked Ideas --

  Stream<List<LikedIdea>> watchLikedIdeas() {
    final query = _db.select(_db.likedIdeas)..orderBy([(t) => OrderingTerm.desc(t.likedAt)]);
    return query.watch();
  }

  Future<void> likeIdea({
    required String ideaId,
    required String articleId,
    required String articleTitle,
    required String articleUrl,
    required String textContent,
    String? imageUrl,
  }) async {
    await _db.into(_db.likedIdeas).insert(
      LikedIdeasCompanion.insert(
        id: ideaId,
        ideaId: ideaId,
        articleId: articleId,
        articleTitle: articleTitle,
        articleUrl: articleUrl,
        textContent: textContent,
        imageUrl: Value(imageUrl),
        likedAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> unlikeIdea(String ideaId) async {
    await (_db.delete(_db.likedIdeas)..where((tbl) => tbl.id.equals(ideaId))).go();
  }

  Future<bool> isIdeaLiked(String ideaId) async {
    final countExp = _db.likedIdeas.id.count();
    final query = _db.selectOnly(_db.likedIdeas)..addColumns([countExp])..where(_db.likedIdeas.id.equals(ideaId));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return (result ?? 0) > 0;
  }
  
  Future<Set<String>> getLikedIdeaIdsForArticle(String articleId) async {
    final query = _db.selectOnly(_db.likedIdeas)..addColumns([_db.likedIdeas.id])..where(_db.likedIdeas.articleId.equals(articleId));
    final ids = await query.map((row) => row.read(_db.likedIdeas.id)!).get();
    return ids.toSet();
  }
}

final libraryRepository = LibraryRepository(appDb);
