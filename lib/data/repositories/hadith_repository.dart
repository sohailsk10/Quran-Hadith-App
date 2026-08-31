/// Hadith Repository - Single source of truth for Hadith data

import 'package:dartz/dartz.dart';
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

  /// Initialize the repository
  Future<void> init() async {
    await _localDataSource.init();
  }

  // ============ COLLECTIONS ============

  Future<Either<Exception, List<HadithCollection>>> getAllCollections({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localCollections = _localDataSource.getAllCollections();
        if (localCollections.isNotEmpty) {
          return Right(localCollections);
        }
      }

      final remoteCollections = await _remoteDataSource.fetchCollections();
      await _localDataSource.saveCollections(remoteCollections);
      return Right(remoteCollections);
    } catch (e) {
      return Left(Exception('Failed to get collections: $e'));
    }
  }

  Future<Either<Exception, HadithCollection?>> getCollection(String id, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localCollection = _localDataSource.getCollection(id);
        if (localCollection != null) {
          return Right(localCollection);
        }
      }

      final result = await getAllCollections(forceRefresh: true);
      return result.fold(
        (error) => Left(error),
        (collections) => Right(collections.firstWhere((c) => c.id == id, orElse: () => throw Exception('Collection not found'))),
      );
    } catch (e) {
      return Left(Exception('Failed to get collection: $e'));
    }
  }

  Future<Either<Exception, HadithCollectionDetail>> getCollectionDetail(String collectionId, {bool forceRefresh = false}) async {
    try {
      final localCollections = _localDataSource.getAllCollections();
      final localCollection = localCollections.firstWhere((c) => c.id == collectionId, orElse: () => throw Exception('Not found'));

      final localBooks = _localDataSource.getBooksByCollection(collectionId);

      if (!forceRefresh && localBooks.isNotEmpty) {
        return Right(HadithCollectionDetail(collection: localCollection, books: localBooks));
      }

      final remoteDetail = await _remoteDataSource.fetchCollectionDetail(collectionId);
      await _localDataSource.saveBooks(remoteDetail.books);
      return Right(remoteDetail);
    } catch (e) {
      return Left(Exception('Failed to get collection detail: $e'));
    }
  }

  // ============ BOOKS ============

  Future<Either<Exception, List<HadithBook>>> getBooksByCollection(String collectionId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localBooks = _localDataSource.getBooksByCollection(collectionId);
        if (localBooks.isNotEmpty) {
          return Right(localBooks);
        }
      }

      final remoteBooks = await _remoteDataSource.fetchBooks(collectionId);
      await _localDataSource.saveBooks(remoteBooks);
      return Right(remoteBooks);
    } catch (e) {
      return Left(Exception('Failed to get books: $e'));
    }
  }

  Future<Either<Exception, HadithBook?>> getBook(String id) async {
    try {
      final book = _localDataSource.getBook(id);
      return Right(book);
    } catch (e) {
      return Left(Exception('Failed to get book: $e'));
    }
  }

  // ============ CHAPTERS ============

  Future<Either<Exception, List<HadithChapter>>> getChaptersByBook(String bookId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localChapters = _localDataSource.getChaptersByBook(bookId);
        if (localChapters.isNotEmpty) {
          return Right(localChapters);
        }
      }

      // Parse collectionId and bookNumber from bookId
      final parts = bookId.split('_');
      if (parts.length >= 2) {
        final collectionId = parts[0];
        final bookNumber = int.tryParse(parts[1]) ?? 1;
        final remoteChapters = await _remoteDataSource.fetchChapters(collectionId, bookNumber);
        await _localDataSource.saveChapters(remoteChapters);
        return Right(remoteChapters);
      }
      return Right([]);
    } catch (e) {
      return Left(Exception('Failed to get chapters: $e'));
    }
  }

  // ============ HADITHS ============

  Future<Either<Exception, HadithBookDetail>> getHadithsByBook(
    String collectionId,
    int bookNumber, {
    int page = 1,
    int perPage = 50,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && page == 1) {
        final localHadiths = _localDataSource.getHadithsByBook(collectionId, bookNumber);
        if (localHadiths.isNotEmpty) {
          final bookResult = await getBook('${collectionId}_$bookNumber');
          final book = bookResult.getOrElse(() => throw Exception('Book not found'));
          return Right(HadithBookDetail(
            book: book!,
            hadiths: localHadiths,
            currentPage: 1,
            totalPages: 1,
            hasMore: false,
          ));
        }
      }

      final remoteDetail = await _remoteDataSource.fetchHadithsByBook(collectionId, bookNumber, page: page, perPage: perPage);
      await _localDataSource.saveHadiths(remoteDetail.hadiths);
      return Right(remoteDetail);
    } catch (e) {
      return Left(Exception('Failed to get hadiths by book: $e'));
    }
  }

  Future<Either<Exception, List<Hadith>>> getHadithsByChapter(String chapterId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localHadiths = _localDataSource.getHadithsByChapter(chapterId);
        if (localHadiths.isNotEmpty) {
          return Right(localHadiths);
        }
      }

      final chapter = _localDataSource.getChapter(chapterId);
      if (chapter != null) {
        final parts = chapter.bookId.split('_');
        if (parts.length >= 2) {
          final collectionId = parts[0];
          final bookNumber = int.tryParse(parts[1]) ?? 1;
          final remoteHadiths = await _remoteDataSource.fetchHadithsByChapter(collectionId, bookNumber, chapter.chapterNumber);
          await _localDataSource.saveHadiths(remoteHadiths);
          return Right(remoteHadiths);
        }
      }
      return Right([]);
    } catch (e) {
      return Left(Exception('Failed to get hadiths by chapter: $e'));
    }
  }

  Future<Either<Exception, Hadith?>> getHadith(String collectionId, int hadithNumber, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localHadith = _localDataSource.getHadithByNumber(collectionId, hadithNumber);
        if (localHadith != null) {
          return Right(localHadith);
        }
      }

      final remoteHadith = await _remoteDataSource.fetchHadith(collectionId, hadithNumber);
      await _localDataSource.saveHadiths([remoteHadith]);
      return Right(remoteHadith);
    } catch (e) {
      return Left(Exception('Failed to get hadith: $e'));
    }
  }

  Future<Either<Exception, List<Hadith>>> getFavoriteHadiths() async {
    try {
      final favorites = _localDataSource.getFavoriteHadiths();
      return Right(favorites);
    } catch (e) {
      return Left(Exception('Failed to get favorites: $e'));
    }
  }

  Future<Either<Exception, void>> toggleFavorite(String hadithId, bool isFavorite) async {
    try {
      await _localDataSource.toggleFavorite(hadithId, isFavorite);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to toggle favorite: $e'));
    }
  }

  // ============ SEARCH ============

  Future<Either<Exception, List<Hadith>>> search({
    required String query,
    String? collectionId,
    String languageCode = 'en',
    HadithGrade? gradeFilter,
    List<String>? topicFilter,
  }) async {
    try {
      // Try local search first
      final localResults = _localDataSource.searchHadiths(
        query,
        collectionId: collectionId,
        languageCode: languageCode,
        gradeFilter: gradeFilter,
        topicFilter: topicFilter,
      );

      if (localResults.isNotEmpty) {
        return Right(localResults);
      }

      // Fallback to remote
      final remoteResponse = await _remoteDataSource.search(
        query: query,
        collectionId: collectionId,
        language: languageCode,
        page: 1,
        perPage: 50,
      );

      await _localDataSource.saveHadiths(remoteResponse.hadiths);
      return Right(remoteResponse.hadiths);
    } catch (e) {
      return Left(Exception('Failed to search: $e'));
    }
  }

  Future<Either<Exception, void>> buildSearchIndex() async {
    try {
      await _localDataSource.buildSearchIndex();
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to build search index: $e'));
    }
  }

  // ============ NARRATORS ============

  Future<Either<Exception, List<Narrator>>> getAllNarrators({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localNarrators = _localDataSource.getAllNarrators();
        if (localNarrators.isNotEmpty) {
          return Right(localNarrators);
        }
      }

      final remoteNarrators = await _remoteDataSource.fetchNarrators();
      await _localDataSource.saveNarrators(remoteNarrators);
      return Right(remoteNarrators);
    } catch (e) {
      return Left(Exception('Failed to get narrators: $e'));
    }
  }

  Future<Either<Exception, List<Narrator>>> searchNarrators(String query) async {
    try {
      final results = _localDataSource.searchNarrators(query);
      return Right(results);
    } catch (e) {
      return Left(Exception('Failed to search narrators: $e'));
    }
  }

  Future<Either<Exception, List<Narrator>>> getNarratorsByIds(List<String> narratorIds) async {
    try {
      final narrators = <Narrator>[];
      for (final id in narratorIds) {
        final narrator = _localDataSource.getNarrator(id);
        if (narrator != null) {
          narrators.add(narrator);
        }
      }
      return Right(narrators);
    } catch (e) {
      return Left(Exception('Failed to get narrators by IDs: $e'));
    }
  }

  Future<Either<Exception, List<Hadith>>> getRelatedHadiths({
    required String collectionId,
    required int hadithNumber,
    int limit = 10,
  }) async {
    try {
      final localHadiths = _localDataSource.getRelatedHadiths(collectionId, hadithNumber, limit: limit);
      if (localHadiths.isNotEmpty) {
        return Right(localHadiths);
      }

      final remoteHadiths = await _remoteDataSource.fetchRelatedHadiths(collectionId, hadithNumber, limit: limit);
      await _localDataSource.saveHadiths(remoteHadiths);
      return Right(remoteHadiths);
    } catch (e) {
      return Left(Exception('Failed to get related hadiths: $e'));
    }
  }

  // ============ TOPICS ============

  Future<Either<Exception, List<HadithTopic>>> getAllTopics({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localTopics = _localDataSource.getAllTopics();
        if (localTopics.isNotEmpty) {
          return Right(localTopics);
        }
      }

      final remoteTopics = await _remoteDataSource.fetchTopics();
      await _localDataSource.saveTopics(remoteTopics);
      return Right(remoteTopics);
    } catch (e) {
      return Left(Exception('Failed to get topics: $e'));
    }
  }

  Future<Either<Exception, List<HadithTopic>>> getTopLevelTopics() async {
    try {
      final topics = _localDataSource.getTopLevelTopics();
      return Right(topics);
    } catch (e) {
      return Left(Exception('Failed to get top level topics: $e'));
    }
  }

  Future<Either<Exception, List<HadithTopic>>> getChildTopics(String parentId) async {
    try {
      final topics = _localDataSource.getChildTopics(parentId);
      return Right(topics);
    } catch (e) {
      return Left(Exception('Failed to get child topics: $e'));
    }
  }

  Future<Either<Exception, List<Hadith>>> getHadithsByTopic(String topicId, {int page = 1, int perPage = 50}) async {
    try {
      final remoteHadiths = await _remoteDataSource.fetchHadithsByTopic(topicId, page: page, perPage: perPage);
      await _localDataSource.saveHadiths(remoteHadiths);
      return Right(remoteHadiths);
    } catch (e) {
      return Left(Exception('Failed to get hadiths by topic: $e'));
    }
  }

  // ============ RANDOM ============

  Future<Either<Exception, Hadith>> getRandomHadith({String? collectionId}) async {
    try {
      final hadith = await _remoteDataSource.fetchRandomHadith(collectionId: collectionId);
      await _localDataSource.saveHadiths([hadith]);
      return Right(hadith);
    } catch (e) {
      return Left(Exception('Failed to get random hadith: $e'));
    }
  }

  // ============ BOOKMARKS ============

  Future<Either<Exception, void>> addBookmark(HadithBookmark bookmark) async {
    try {
      await _localDataSource.addBookmark(bookmark);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to add bookmark: $e'));
    }
  }

  Future<Either<Exception, void>> removeBookmark(String id) async {
    try {
      await _localDataSource.removeBookmark(id);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to remove bookmark: $e'));
    }
  }

  Future<Either<Exception, List<HadithBookmark>>> getAllBookmarks() async {
    try {
      final bookmarks = _localDataSource.getAllBookmarks();
      return Right(bookmarks);
    } catch (e) {
      return Left(Exception('Failed to get bookmarks: $e'));
    }
  }

  Future<Either<Exception, List<HadithBookmark>>> getBookmarksByCollection(String collectionId) async {
    try {
      final bookmarks = _localDataSource.getBookmarksByCollection(collectionId);
      return Right(bookmarks);
    } catch (e) {
      return Left(Exception('Failed to get bookmarks by collection: $e'));
    }
  }

  Future<Either<Exception, HadithBookmark?>> getBookmarkForHadith(String hadithId) async {
    try {
      final bookmark = _localDataSource.getBookmarkForHadith(hadithId);
      return Right(bookmark);
    } catch (e) {
      return Left(Exception('Failed to get bookmark: $e'));
    }
  }

  // ============ UTILITY ============

  Future<void> clearAllData() async {
    await _localDataSource.clearAllData();
  }

  Future<void> close() async {
    await _localDataSource.close();
  }
}