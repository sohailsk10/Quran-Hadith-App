/// Local data source for Hadith data using Hive

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../shared/models/hadith_models.dart';
import '../../../shared/models/settings_models.dart';

class HadithLocalDataSource {
  // Box names
  static const String _collectionsBox = 'hadith_collections';
  static const String _booksBox = 'hadith_books';
  static const String _chaptersBox = 'hadith_chapters';
  static const String _hadithsBox = 'hadiths';
  static const String _narratorsBox = 'narrators';
  static const String _topicsBox = 'hadith_topics';
  static const String _bookmarksBox = 'hadith_bookmarks';
  static const String _searchIndexBox = 'hadith_search_index';

  // Boxes
  late Box<HadithCollection> _collectionsBoxInstance;
  late Box<HadithBook> _booksBoxInstance;
  late Box<HadithChapter> _chaptersBoxInstance;
  late Box<Hadith> _hadithsBoxInstance;
  late Box<Narrator> _narratorsBoxInstance;
  late Box<HadithTopic> _topicsBoxInstance;
  late Box<HadithBookmark> _bookmarksBoxInstance;
  late Box<Map<String, dynamic>> _searchIndexBoxInstance;

  /// Initialize all boxes
  Future<void> init() async {
    // Register adapters
    if (!Hive.isAdapterRegistered(20)) Hive.registerAdapter(HadithCollectionAdapter());
    if (!Hive.isAdapterRegistered(21)) Hive.registerAdapter(CollectionAuthenticityAdapter());
    if (!Hive.isAdapterRegistered(22)) Hive.registerAdapter(HadithBookAdapter());
    if (!Hive.isAdapterRegistered(23)) Hive.registerAdapter(HadithChapterAdapter());
    if (!Hive.isAdapterRegistered(24)) Hive.registerAdapter(HadithAdapter());
    if (!Hive.isAdapterRegistered(25)) Hive.registerAdapter(HadithGradeAdapter());
    if (!Hive.isAdapterRegistered(26)) Hive.registerAdapter(HadithBookmarkAdapter());
    if (!Hive.isAdapterRegistered(27)) Hive.registerAdapter(BookmarkColorAdapter());
    if (!Hive.isAdapterRegistered(28)) Hive.registerAdapter(NarratorAdapter());
    if (!Hive.isAdapterRegistered(29)) Hive.registerAdapter(NarratorReliabilityAdapter());
    if (!Hive.isAdapterRegistered(30)) Hive.registerAdapter(HadithTopicAdapter());

    // Open boxes
    _collectionsBoxInstance = await Hive.openBox<HadithCollection>(_collectionsBox);
    _booksBoxInstance = await Hive.openBox<HadithBook>(_booksBox);
    _chaptersBoxInstance = await Hive.openBox<HadithChapter>(_chaptersBox);
    _hadithsBoxInstance = await Hive.openBox<Hadith>(_hadithsBox);
    _narratorsBoxInstance = await Hive.openBox<Narrator>(_narratorsBox);
    _topicsBoxInstance = await Hive.openBox<HadithTopic>(_topicsBox);
    _bookmarksBoxInstance = await Hive.openBox<HadithBookmark>(_bookmarksBox);
    _searchIndexBoxInstance = await Hive.openBox<Map<String, dynamic>>(_searchIndexBox);
  }

  // ============ COLLECTIONS ============

  Future<void> saveCollections(List<HadithCollection> collections) async {
    await _collectionsBoxInstance.clear();
    final map = {for (var c in collections) c.id: c};
    await _collectionsBoxInstance.putAll(map);
  }

  List<HadithCollection> getAllCollections() {
    return _collectionsBoxInstance.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  HadithCollection? getCollection(String id) {
    return _collectionsBoxInstance.get(id);
  }

  Future<void> updateCollectionDownloadStatus(
    String id,
    bool downloaded, {
    String? localPath,
  }) async {
    final collection = _collectionsBoxInstance.get(id);
    if (collection != null) {
      // Note: HadithCollection doesn't have isDownloaded in its constructor
      // This would need to be added to the model or handled differently
    }
  }

  // ============ BOOKS ============

  Future<void> saveBooks(List<HadithBook> books) async {
    await _booksBoxInstance.clear();
    final map = {for (var b in books) b.id: b};
    await _booksBoxInstance.putAll(map);
  }

  List<HadithBook> getAllBooks() {
    return _booksBoxInstance.values.toList()
      ..sort((a, b) => a.bookNumber.compareTo(b.bookNumber));
  }

  List<HadithBook> getBooksByCollection(String collectionId) {
    return _booksBoxInstance.values
        .where((b) => b.collectionId == collectionId)
        .toList()
      ..sort((a, b) => a.bookNumber.compareTo(b.bookNumber));
  }

  HadithBook? getBook(String id) {
    return _booksBoxInstance.get(id);
  }

  // ============ CHAPTERS ============

  Future<void> saveChapters(List<HadithChapter> chapters) async {
    await _chaptersBoxInstance.clear();
    final map = {for (var c in chapters) c.id: c};
    await _chaptersBoxInstance.putAll(map);
  }

  List<HadithChapter> getChaptersByBook(String bookId) {
    return _chaptersBoxInstance.values
        .where((c) => c.bookId == bookId)
        .toList()
      ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
  }

  HadithChapter? getChapter(String id) {
    return _chaptersBoxInstance.get(id);
  }

  // ============ HADITHS ============

  Future<void> saveHadiths(List<Hadith> hadiths) async {
    await _hadithsBoxInstance.clear();
    final map = {for (var h in hadiths) h.id: h};
    await _hadithsBoxInstance.putAll(map);
  }

  List<Hadith> getAllHadiths() {
    return _hadithsBoxInstance.values.toList()
      ..sort((a, b) => a.hadithNumber.compareTo(b.hadithNumber));
  }

  List<Hadith> getHadithsByCollection(String collectionId) {
    return _hadithsBoxInstance.values
        .where((h) => h.collectionId == collectionId)
        .toList()
      ..sort((a, b) => a.hadithNumber.compareTo(b.hadithNumber));
  }

  List<Hadith> getHadithsByBook(String collectionId, int bookNumber) {
    return _hadithsBoxInstance.values
        .where((h) => h.collectionId == collectionId && h.bookNumber == bookNumber)
        .toList()
      ..sort((a, b) => (a.bookHadithNumber ?? 0).compareTo(b.bookHadithNumber ?? 0));
  }

  List<Hadith> getHadithsByChapter(String chapterId) {
    return _hadithsBoxInstance.values
        .where((h) => h.chapterId == chapterId)
        .toList()
      ..sort((a, b) => (a.bookHadithNumber ?? 0).compareTo(b.bookHadithNumber ?? 0));
  }

  Hadith? getHadith(String id) {
    return _hadithsBoxInstance.get(id);
  }

  Hadith? getHadithByNumber(String collectionId, int hadithNumber) {
    try {
      return _hadithsBoxInstance.values.firstWhere(
        (h) => h.collectionId == collectionId && h.hadithNumber == hadithNumber,
      );
    } catch (_) {
      return null;
    }
  }

  List<Hadith> getFavoriteHadiths() {
    return _hadithsBoxInstance.values
        .where((h) => h.isFavorite)
        .toList()
      ..sort((a, b) => (b.addedToFavorites ?? DateTime.now()).compareTo(a.addedToFavorites ?? DateTime.now()));
  }

  Future<void> toggleFavorite(String hadithId, bool isFavorite) async {
    final hadith = _hadithsBoxInstance.get(hadithId);
    if (hadith != null) {
      await _hadithsBoxInstance.put(
        hadithId,
        hadith.copyWith(
          isFavorite: isFavorite,
          addedToFavorites: isFavorite ? DateTime.now() : null,
        ),
      );
    }
  }

  // ============ SEARCH ============

  List<Hadith> getRelatedHadiths(String collectionId, int hadithNumber, {int limit = 10}) {
    final hadith = getHadithByNumber(collectionId, hadithNumber);
    if (hadith == null) return [];

    // Find related hadiths based on shared topics, narrators, or similar text
    final results = <String, int>{};

    for (final h in _hadithsBoxInstance.values) {
      if (h.id == hadith.id) continue;
      if (h.collectionId != collectionId) continue;

      int score = 0;

      // Shared topics
      for (final topic in hadith.topics) {
        if (h.topics.contains(topic)) {
          score += 3;
        }
      }

      // Shared narrators
      for (final narrator in hadith.narrators) {
        if (h.narrators.contains(narrator)) {
          score += 2;
        }
      }

      // Same book
      if (h.bookNumber == hadith.bookNumber) {
        score += 5;
      }

      // Same chapter
      if (h.chapterId == hadith.chapterId) {
        score += 10;
      }

      if (score > 0) {
        results[h.id] = score;
      }
    }

    final sortedIds = results.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedIds
        .take(limit)
        .map((e) => _hadithsBoxInstance.get(e.key)!)
        .whereType<Hadith>()
        .toList();
  }

  Future<void> buildSearchIndex() async {
    await _searchIndexBoxInstance.clear();

    final index = <String, List<String>>{}; // word -> list of hadith IDs

    for (final hadith in _hadithsBoxInstance.values) {
      // Index translations
      for (final entry in hadith.translations.entries) {
        final words = entry.value.toLowerCase().split(RegExp(r'\W+'));
        for (final word in words) {
          if (word.length > 2) {
            index.putIfAbsent(word, () => []).add(hadith.id);
          }
        }
      }

      // Index narrators
      for (final narrator in hadith.narrators) {
        final words = narrator.toLowerCase().split(RegExp(r'\W+'));
        for (final word in words) {
          if (word.length > 2) {
            index.putIfAbsent(word, () => []).add(hadith.id);
          }
        }
      }

      // Index topics
      for (final topic in hadith.topics) {
        final words = topic.toLowerCase().split(RegExp(r'\W+'));
        for (final word in words) {
          if (word.length > 2) {
            index.putIfAbsent(word, () => []).add(hadith.id);
          }
        }
      }

      // Index keywords
      for (final keyword in hadith.keywords) {
        final words = keyword.toLowerCase().split(RegExp(r'\W+'));
        for (final word in words) {
          if (word.length > 2) {
            index.putIfAbsent(word, () => []).add(hadith.id);
          }
        }
      }
    }

    // Save index
    for (final entry in index.entries) {
      await _searchIndexBoxInstance.put(entry.key, entry.value.toSet().toList());
    }
  }

  List<Hadith> searchHadiths(String query, {
    String? collectionId,
    String languageCode = 'en',
    HadithGrade? gradeFilter,
    List<String>? topicFilter,
  }) {
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) return [];

    // Try exact match first
    var results = <String, int>{}; // hadithId -> score

    // Search in index
    final words = lowerQuery.split(RegExp(r'\s+'));
    for (final word in words) {
      final hadithIds = _searchIndexBoxInstance.get(word);
      if (hadithIds != null) {
        for (final id in hadithIds) {
          results[id] = (results[id] ?? 0) + 1;
        }
      }
    }

    // Also search directly in translations for partial matches
    for (final hadith in _hadithsBoxInstance.values) {
      // Apply filters
      if (collectionId != null && hadith.collectionId != collectionId) continue;
      if (gradeFilter != null && hadith.grade != gradeFilter) continue;
      if (topicFilter != null && topicFilter.isNotEmpty) {
        if (!hadith.topics.any((t) => topicFilter.contains(t))) continue;
      }

      final translation = hadith.getTranslation(languageCode).toLowerCase();
      int score = 0;

      if (translation.contains(lowerQuery)) {
        score += 10; // Exact phrase match
      } else {
        for (final word in words) {
          if (translation.contains(word)) {
            score += 2;
          }
        }
      }

      // Check narrator chain
      for (final narrator in hadith.narrators) {
        if (narrator.toLowerCase().contains(lowerQuery)) {
          score += 5;
        }
      }

      // Check topics
      for (final topic in hadith.topics) {
        if (topic.toLowerCase().contains(lowerQuery)) {
          score += 3;
        }
      }

      if (score > 0) {
        results[hadith.id] = (results[hadith.id] ?? 0) + score;
      }
    }

    // Sort by score and return hadiths
    final sortedIds = results.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedIds.map((e) => _hadithsBoxInstance.get(e.key)!).whereType<Hadith>().toList();
  }

  // ============ NARRATORS ============

  Future<void> saveNarrators(List<Narrator> narrators) async {
    await _narratorsBoxInstance.clear();
    final map = {for (var n in narrators) n.id: n};
    await _narratorsBoxInstance.putAll(map);
  }

  List<Narrator> getAllNarrators() {
    return _narratorsBoxInstance.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Narrator? getNarrator(String id) {
    return _narratorsBoxInstance.get(id);
  }

  List<Narrator> searchNarrators(String query) {
    final lowerQuery = query.toLowerCase();
    return _narratorsBoxInstance.values
        .where((n) =>
            n.name.toLowerCase().contains(lowerQuery) ||
            n.nameArabic.contains(query) ||
            n.kunya.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // ============ TOPICS ============

  Future<void> saveTopics(List<HadithTopic> topics) async {
    await _topicsBoxInstance.clear();
    final map = {for (var t in topics) t.id: t};
    await _topicsBoxInstance.putAll(map);
  }

  List<HadithTopic> getAllTopics() {
    return _topicsBoxInstance.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<HadithTopic> getTopLevelTopics() {
    return _topicsBoxInstance.values
        .where((t) => t.level == 0)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<HadithTopic> getChildTopics(String parentId) {
    return _topicsBoxInstance.values
        .where((t) => t.parentId == parentId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  HadithTopic? getTopic(String id) {
    return _topicsBoxInstance.get(id);
  }

  // ============ BOOKMARKS ============

  Future<void> addBookmark(HadithBookmark bookmark) async {
    await _bookmarksBoxInstance.put(bookmark.id, bookmark);
  }

  Future<void> removeBookmark(String id) async {
    await _bookmarksBoxInstance.delete(id);
  }

  List<HadithBookmark> getAllBookmarks() {
    return _bookmarksBoxInstance.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<HadithBookmark> getBookmarksByCollection(String collectionId) {
    return _bookmarksBoxInstance.values
        .where((b) => b.collectionId == collectionId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  HadithBookmark? getBookmarkForHadith(String hadithId) {
    try {
      return _bookmarksBoxInstance.values.firstWhere((b) => b.hadithId == hadithId);
    } catch (_) {
      return null;
    }
  }

  // ============ UTILITY ============

  Future<void> clearAllData() async {
    await _collectionsBoxInstance.clear();
    await _booksBoxInstance.clear();
    await _chaptersBoxInstance.clear();
    await _hadithsBoxInstance.clear();
    await _narratorsBoxInstance.clear();
    await _topicsBoxInstance.clear();
    await _bookmarksBoxInstance.clear();
    await _searchIndexBoxInstance.clear();
  }

  Future<void> close() async {
    await _collectionsBoxInstance.close();
    await _booksBoxInstance.close();
    await _chaptersBoxInstance.close();
    await _hadithsBoxInstance.close();
    await _narratorsBoxInstance.close();
    await _topicsBoxInstance.close();
    await _bookmarksBoxInstance.close();
    await _searchIndexBoxInstance.close();
  }
}