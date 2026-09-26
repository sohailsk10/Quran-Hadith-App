/// Hadith Repository - Single source of truth for Hadith data

import '../datasources/local/hadith_local_datasource.dart';
import '../datasources/remote/hadith_remote_datasource.dart';
import '../../shared/models/hadith_models.dart';

class HadithRepository {
  final HadithLocalDataSource _localDataSource;
  final HadithRemoteDataSource _remoteDataSource;

  HadithRepository({
    required HadithLocalDataSource localDataSource,
    required HadithRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  Future<void> init() async {
    await _localDataSource.init();
  }

  // ============ COLLECTIONS ============

  Future<List<HadithCollection>> getAllCollections(
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final local = _localDataSource.getAllCollections();
      if (local.isNotEmpty) return local;
    }

    final remote = await _remoteDataSource.fetchCollections();
    await _localDataSource.saveCollections(remote);
    return remote;
  }

  Future<HadithCollection?> getCollection(String id,
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final local = _localDataSource.getCollection(id);
      if (local != null) return local;
    }

    final all = await getAllCollections(forceRefresh: true);
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<HadithCollectionDetail> getCollectionDetail(String collectionId,
      {bool forceRefresh = false}) async {
    final localCollection = _localDataSource.getCollection(collectionId);
    final localBooks = _localDataSource.getBooksByCollection(collectionId);

    if (!forceRefresh && localCollection != null && localBooks.isNotEmpty) {
      return HadithCollectionDetail(
          collection: localCollection, books: localBooks);
    }

    final remoteDetail =
        await _remoteDataSource.fetchCollectionDetail(collectionId);
    await _localDataSource.saveBooks(remoteDetail.books);
    return remoteDetail;
  }

  // ============ BOOKS ============

  Future<List<HadithBook>> getBooksByCollection(String collectionId,
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final local = _localDataSource.getBooksByCollection(collectionId);
      if (local.isNotEmpty) return local;
    }

    final remote = await _remoteDataSource.fetchBooks(collectionId);
    await _localDataSource.saveBooks(remote);
    return remote;
  }

  Future<HadithBook?> getBook(String id) async {
    return _localDataSource.getBook(id);
  }

  // ============ CHAPTERS ============

  Future<List<HadithChapter>> getChaptersByBook(String bookId,
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final local = _localDataSource.getChaptersByBook(bookId);
      if (local.isNotEmpty) return local;
    }

    final parts = bookId.split('_');
    if (parts.length >= 2) {
      final collectionId = parts[0];
      final bookNumber = int.tryParse(parts[1]) ?? 1;
      final remote =
          await _remoteDataSource.fetchChapters(collectionId, bookNumber);
      await _localDataSource.saveChapters(remote);
      return remote;
    }
    return [];
  }

  // ============ HADITHS ============

  Future<HadithBookDetail> getHadithsByBook(
    String collectionId,
    int bookNumber, {
    int page = 1,
    int perPage = 50,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && page == 1) {
      final local = _localDataSource.getHadithsByBook(collectionId, bookNumber);
      if (local.isNotEmpty) {
        final book = _localDataSource.getBook('${collectionId}_$bookNumber');
        return HadithBookDetail(
          book: book ??
              HadithBook(
                id: '${collectionId}_$bookNumber',
                collectionId: collectionId,
                bookNumber: bookNumber,
                name: 'Book $bookNumber',
                nameArabic: '',
                hadithStartNumber: 1,
                hadithEndNumber: local.length,
                totalHadiths: local.length,
                chapters: [],
              ),
          hadiths: local,
          currentPage: 1,
          totalPages: 1,
          hasMore: false,
        );
      }
    }

    final remote = await _remoteDataSource.fetchHadithsByBook(
      collectionId,
      bookNumber,
      page: page,
      perPage: perPage,
    );
    await _localDataSource.saveHadiths(remote.hadiths);
    return remote;
  }

  Future<List<Hadith>> getHadithsByChapter(String chapterId,
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final local = _localDataSource.getHadithsByChapter(chapterId);
      if (local.isNotEmpty) return local;
    }

    final chapter = _localDataSource.getChapter(chapterId);
    if (chapter != null) {
      final parts = chapter.bookId.split('_');
      if (parts.length >= 2) {
        final collectionId = parts[0];
        final bookNumber = int.tryParse(parts[1]) ?? 1;
        final remote = await _remoteDataSource.fetchHadithsByChapter(
          collectionId,
          bookNumber,
          chapter.chapterNumber,
        );
        await _localDataSource.saveHadiths(remote);
        return remote;
      }
    }
    return [];
  }

  Future<Hadith?> getHadith(String collectionId, int hadithNumber,
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final local =
          _localDataSource.getHadithByNumber(collectionId, hadithNumber);
      if (local != null) return local;
    }

    final remote =
        await _remoteDataSource.fetchHadith(collectionId, hadithNumber);
    await _localDataSource.saveHadiths([remote]);
    return remote;
  }

  Future<List<Hadith>> getFavoriteHadiths() async {
    return _localDataSource.getFavoriteHadiths();
  }

  Future<void> toggleFavorite(String hadithId, bool isFavorite) async {
    await _localDataSource.toggleFavorite(hadithId, isFavorite);
  }

  // ============ SEARCH ============

  Future<List<Hadith>> search({
    required String query,
    String? collectionId,
    String languageCode = 'en',
    HadithGrade? gradeFilter,
    List<String>? topicFilter,
  }) async {
    final local = _localDataSource.searchHadiths(
      query,
      collectionId: collectionId,
      languageCode: languageCode,
      gradeFilter: gradeFilter,
      topicFilter: topicFilter,
    );

    if (local.isNotEmpty) return local;

    final remoteResponse = await _remoteDataSource.search(
      query: query,
      collectionId: collectionId,
      language: languageCode,
      page: 1,
      perPage: 50,
    );

    await _localDataSource.saveHadiths(remoteResponse.hadiths);
    return remoteResponse.hadiths;
  }

  // ============ NARRATORS ============

  Future<List<Narrator>> getAllNarrators({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final local = _localDataSource.getAllNarrators();
      if (local.isNotEmpty) return local;
    }

    final remote = await _remoteDataSource.fetchNarrators();
    await _localDataSource.saveNarrators(remote);
    return remote;
  }

  Future<List<Narrator>> getNarratorsByIds(List<String> narratorIds) async {
    final result = <Narrator>[];
    for (final id in narratorIds) {
      final n = _localDataSource.getNarrator(id);
      if (n != null) result.add(n);
    }
    return result;
  }

  Future<List<Hadith>> getRelatedHadiths({
    required String collectionId,
    required int hadithNumber,
    int limit = 10,
  }) async {
    final local = _localDataSource.getRelatedHadiths(collectionId, hadithNumber,
        limit: limit);
    if (local.isNotEmpty) return local;

    try {
      final remote = await _remoteDataSource
          .fetchRelatedHadiths(collectionId, hadithNumber, limit: limit);
      await _localDataSource.saveHadiths(remote);
      return remote;
    } catch (_) {
      return [];
    }
  }

  // ============ TOPICS ============

  Future<List<HadithTopic>> getAllTopics({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final local = _localDataSource.getAllTopics();
      if (local.isNotEmpty) return local;
    }

    final remote = await _remoteDataSource.fetchTopics();
    await _localDataSource.saveTopics(remote);
    return remote;
  }

  Future<List<HadithTopic>> getTopLevelTopics() async {
    return _localDataSource.getTopLevelTopics();
  }

  Future<List<HadithTopic>> getChildTopics(String parentId) async {
    return _localDataSource.getChildTopics(parentId);
  }

  Future<List<Hadith>> getHadithsByTopic(String topicId,
      {int page = 1, int perPage = 50}) async {
    final remote = await _remoteDataSource.fetchHadithsByTopic(topicId,
        page: page, perPage: perPage);
    await _localDataSource.saveHadiths(remote);
    return remote;
  }

  Future<HadithTopic> getHadithTopic(String topicId) async {
    final local = _localDataSource.getTopic(topicId);
    if (local != null) return local;

    final remote = await _remoteDataSource.fetchTopic(topicId);
    await _localDataSource.saveTopic(remote);
    return remote;
  }

  Future<List<HadithTopic>> getRelatedTopics(String topicId) async {
    final local = _localDataSource.getRelatedTopics(topicId);
    if (local.isNotEmpty) return local;

    final remote = await _remoteDataSource.fetchRelatedTopics(topicId);
    await _localDataSource.saveTopics(remote);
    return remote;
  }

  // ============ RANDOM ============

  Future<Hadith?> getRandomHadith({String? collectionId}) async {
    try {
      final hadith =
          await _remoteDataSource.fetchRandomHadith(collectionId: collectionId);
      await _localDataSource.saveHadiths([hadith]);
      return hadith;
    } catch (_) {
      return null;
    }
  }

  // ============ BOOKMARKS ============

  Future<void> addBookmark(HadithBookmark bookmark) async {
    await _localDataSource.addBookmark(bookmark);
  }

  Future<void> removeBookmark(String id) async {
    await _localDataSource.removeBookmark(id);
  }

  Future<List<HadithBookmark>> getAllBookmarks() async {
    return _localDataSource.getAllBookmarks();
  }

  // ============ UTILITY ============

  Future<void> clearAllData() async {
    await _localDataSource.clearAllData();
  }

  Future<void> close() async {
    await _localDataSource.close();
  }
}
