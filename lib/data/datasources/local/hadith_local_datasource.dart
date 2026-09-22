/// Local data source for Hadith data (in-memory storage)

import '../../../shared/models/hadith_models.dart';

class HadithLocalDataSource {
  // In-memory caches
  final List<HadithCollection> _collections = [];
  final List<HadithBook> _books = [];
  final List<HadithChapter> _chapters = [];
  final List<Hadith> _hadiths = [];
  final List<Narrator> _narrators = [];
  final List<HadithTopic> _topics = [];
  final List<HadithBookmark> _bookmarks = [];

  Future<void> init() async {
    // Nothing to initialize for in-memory storage
  }

  // ============ COLLECTIONS ============

  Future<void> saveCollections(List<HadithCollection> collections) async {
    _collections
      ..clear()
      ..addAll(collections);
  }

  List<HadithCollection> getAllCollections() {
    return List.from(_collections)..sort((a, b) => a.name.compareTo(b.name));
  }

  HadithCollection? getCollection(String id) {
    try {
      return _collections.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============ BOOKS ============

  Future<void> saveBooks(List<HadithBook> books) async {
    for (final book in books) {
      _books.removeWhere((b) => b.id == book.id);
      _books.add(book);
    }
  }

  List<HadithBook> getAllBooks() {
    return List.from(_books)
      ..sort((a, b) => a.bookNumber.compareTo(b.bookNumber));
  }

  List<HadithBook> getBooksByCollection(String collectionId) {
    return _books.where((b) => b.collectionId == collectionId).toList()
      ..sort((a, b) => a.bookNumber.compareTo(b.bookNumber));
  }

  HadithBook? getBook(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============ CHAPTERS ============

  Future<void> saveChapters(List<HadithChapter> chapters) async {
    for (final chapter in chapters) {
      _chapters.removeWhere((c) => c.id == chapter.id);
      _chapters.add(chapter);
    }
  }

  List<HadithChapter> getChaptersByBook(String bookId) {
    return _chapters.where((c) => c.bookId == bookId).toList()
      ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
  }

  HadithChapter? getChapter(String id) {
    try {
      return _chapters.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============ HADITHS ============

  Future<void> saveHadiths(List<Hadith> hadiths) async {
    for (final hadith in hadiths) {
      _hadiths.removeWhere((h) => h.id == hadith.id);
      _hadiths.add(hadith);
    }
  }

  List<Hadith> getAllHadiths() {
    return List.from(_hadiths)
      ..sort((a, b) => a.hadithNumber.compareTo(b.hadithNumber));
  }

  List<Hadith> getHadithsByCollection(String collectionId) {
    return _hadiths.where((h) => h.collectionId == collectionId).toList()
      ..sort((a, b) => a.hadithNumber.compareTo(b.hadithNumber));
  }

  List<Hadith> getHadithsByBook(String collectionId, int bookNumber) {
    return _hadiths
        .where(
            (h) => h.collectionId == collectionId && h.bookNumber == bookNumber)
        .toList()
      ..sort((a, b) =>
          (a.bookHadithNumber ?? 0).compareTo(b.bookHadithNumber ?? 0));
  }

  List<Hadith> getHadithsByChapter(String chapterId) {
    return _hadiths.where((h) => h.chapterId == chapterId).toList()
      ..sort((a, b) =>
          (a.bookHadithNumber ?? 0).compareTo(b.bookHadithNumber ?? 0));
  }

  Hadith? getHadith(String id) {
    try {
      return _hadiths.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Hadith? getHadithByNumber(String collectionId, int hadithNumber) {
    try {
      return _hadiths.firstWhere(
        (h) => h.collectionId == collectionId && h.hadithNumber == hadithNumber,
      );
    } catch (_) {
      return null;
    }
  }

  List<Hadith> getFavoriteHadiths() {
    return _hadiths.where((h) => h.isFavorite).toList()
      ..sort((a, b) => (b.addedToFavorites ?? DateTime.now())
          .compareTo(a.addedToFavorites ?? DateTime.now()));
  }

  Future<void> toggleFavorite(String hadithId, bool isFavorite) async {
    final index = _hadiths.indexWhere((h) => h.id == hadithId);
    if (index >= 0) {
      _hadiths[index] = _hadiths[index].copyWith(
        isFavorite: isFavorite,
        addedToFavorites: isFavorite ? DateTime.now() : null,
      );
    }
  }

  // ============ SEARCH ============

  List<Hadith> getRelatedHadiths(String collectionId, int hadithNumber,
      {int limit = 10}) {
    final hadith = getHadithByNumber(collectionId, hadithNumber);
    if (hadith == null) return [];

    final scores = <String, int>{};

    for (final h in _hadiths) {
      if (h.id == hadith.id) continue;
      if (h.collectionId != collectionId) continue;

      int score = 0;

      for (final topic in hadith.topics) {
        if (h.topics.contains(topic)) score += 3;
      }

      for (final narrator in hadith.narrators) {
        if (h.narrators.contains(narrator)) score += 2;
      }

      if (h.bookNumber == hadith.bookNumber) score += 5;
      if (h.chapterId == hadith.chapterId) score += 10;

      if (score > 0) scores[h.id] = score;
    }

    final sortedIds = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedIds
        .take(limit)
        .map((e) => getHadith(e.key))
        .whereType<Hadith>()
        .toList();
  }

  Future<void> buildSearchIndex() async {
    // Index is not persisted; searches use in-memory list directly
  }

  List<Hadith> searchHadiths(
    String query, {
    String? collectionId,
    String languageCode = 'en',
    HadithGrade? gradeFilter,
    List<String>? topicFilter,
  }) {
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) return [];

    final scores = <String, int>{};
    final words = lowerQuery.split(RegExp(r'\s+'));

    for (final hadith in _hadiths) {
      if (collectionId != null && hadith.collectionId != collectionId) continue;
      if (gradeFilter != null && hadith.grade != gradeFilter) continue;
      if (topicFilter != null && topicFilter.isNotEmpty) {
        if (!hadith.topics.any((t) => topicFilter.contains(t))) continue;
      }

      final translation = hadith.getTranslation(languageCode).toLowerCase();
      int score = 0;

      if (translation.contains(lowerQuery)) {
        score += 10;
      } else {
        for (final word in words) {
          if (translation.contains(word)) score += 2;
        }
      }

      for (final narrator in hadith.narrators) {
        if (narrator.toLowerCase().contains(lowerQuery)) score += 5;
      }

      for (final topic in hadith.topics) {
        if (topic.toLowerCase().contains(lowerQuery)) score += 3;
      }

      if (score > 0) scores[hadith.id] = score;
    }

    final sortedIds = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedIds.map((e) => getHadith(e.key)).whereType<Hadith>().toList();
  }

  // ============ NARRATORS ============

  Future<void> saveNarrators(List<Narrator> narrators) async {
    _narrators
      ..clear()
      ..addAll(narrators);
  }

  List<Narrator> getAllNarrators() {
    return List.from(_narrators)..sort((a, b) => a.name.compareTo(b.name));
  }

  Narrator? getNarrator(String id) {
    try {
      return _narrators.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Narrator> searchNarrators(String query) {
    final lowerQuery = query.toLowerCase();
    return _narrators
        .where((n) =>
            n.name.toLowerCase().contains(lowerQuery) ||
            n.nameArabic.contains(query) ||
            n.kunya.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // ============ TOPICS ============

  Future<void> saveTopics(List<HadithTopic> topics) async {
    _topics
      ..clear()
      ..addAll(topics);
  }

  List<HadithTopic> getAllTopics() {
    return List.from(_topics)..sort((a, b) => a.name.compareTo(b.name));
  }

  List<HadithTopic> getTopLevelTopics() {
    return _topics.where((t) => t.level == 0).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<HadithTopic> getChildTopics(String parentId) {
    return _topics.where((t) => t.parentId == parentId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  HadithTopic? getTopic(String id) {
    try {
      return _topics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<HadithTopic> getRelatedTopics(String topicId) {
    final topic = getTopic(topicId);
    if (topic == null) return [];

    final relatedTopics = <HadithTopic>[];
    for (final t in _topics) {
      if (t.level == topic.level + 1 && t.parentId == topic.id) {
        relatedTopics.add(t);
      }
    }
    return relatedTopics;
  }

  Future<void> saveTopic(HadithTopic topic) async {
    final topics = await getAllTopics();
    topics.removeWhere((t) => t.id == topic.id);
    topics.add(topic);
    // No need to save to box for in-memory storage - the list is already updated
  }

  // ============ BOOKMARKS ============

  Future<void> addBookmark(HadithBookmark bookmark) async {
    _bookmarks.removeWhere((b) => b.id == bookmark.id);
    _bookmarks.add(bookmark);
  }

  Future<void> removeBookmark(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
  }

  List<HadithBookmark> getAllBookmarks() {
    return List.from(_bookmarks)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<HadithBookmark> getBookmarksByCollection(String collectionId) {
    return _bookmarks.where((b) => b.collectionId == collectionId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  HadithBookmark? getBookmarkForHadith(String hadithId) {
    try {
      return _bookmarks.firstWhere((b) => b.hadithId == hadithId);
    } catch (_) {
      return null;
    }
  }

  // ============ UTILITY ============

  Future<void> clearAllData() async {
    _collections.clear();
    _books.clear();
    _chapters.clear();
    _hadiths.clear();
    _narrators.clear();
    _topics.clear();
    _bookmarks.clear();
  }

  Future<void> close() async {
    // Nothing to close
  }
}
