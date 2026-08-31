/// Remote data source for Hadith data from API

import 'package:dio/dio.dart';
import '../../../shared/models/hadith_models.dart';
import '../../../core/constants/app_constants.dart';

class HadithRemoteDataSource {
  final Dio _dio;

  HadithRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.hadithApiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ));

  /// Fetch all available collections
  Future<List<HadithCollection>> fetchCollections() async {
    try {
      final response = await _dio.get('/books');
      final data = response.data as List;
      return data.map((json) => _parseCollection(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch collections: $e');
    }
  }

  /// Fetch a specific collection with its books
  Future<HadithCollectionDetail> fetchCollectionDetail(String collectionId) async {
    try {
      final response = await _dio.get('/books/$collectionId');
      return _parseCollectionDetail(response.data);
    } catch (e) {
      throw Exception('Failed to fetch collection detail: $e');
    }
  }

  /// Fetch all books in a collection
  Future<List<HadithBook>> fetchBooks(String collectionId) async {
    try {
      final response = await _dio.get('/books/$collectionId/chapters');
      final data = response.data as List;
      return data.map((json) => _parseBook(json, collectionId)).toList();
    } catch (e) {
      throw Exception('Failed to fetch books: $e');
    }
  }

  /// Fetch chapters in a book
  Future<List<HadithChapter>> fetchChapters(String collectionId, int bookNumber) async {
    try {
      final response = await _dio.get('/books/$collectionId/chapters/$bookNumber');
      final data = response.data as List;
      return data.map((json) => _parseChapter(json, collectionId, bookNumber)).toList();
    } catch (e) {
      throw Exception('Failed to fetch chapters: $e');
    }
  }

  /// Fetch hadiths in a book
  Future<HadithBookDetail> fetchHadithsByBook(String collectionId, int bookNumber, {
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/books/$collectionId/$bookNumber',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseHadithBookDetail(response.data, collectionId, bookNumber);
    } catch (e) {
      throw Exception('Failed to fetch hadiths: $e');
    }
  }

  /// Fetch hadiths in a chapter
  Future<List<Hadith>> fetchHadithsByChapter(String collectionId, int bookNumber, int chapterNumber) async {
    try {
      final response = await _dio.get('/books/$collectionId/$bookNumber/$chapterNumber');
      final data = response.data['hadiths'] as List;
      return data.map((json) => _parseHadith(json, collectionId, bookNumber)).toList();
    } catch (e) {
      throw Exception('Failed to fetch hadiths by chapter: $e');
    }
  }

  /// Fetch a specific hadith
  Future<Hadith> fetchHadith(String collectionId, int hadithNumber) async {
    try {
      final response = await _dio.get('/books/$collectionId/$hadithNumber');
      return _parseHadith(response.data['hadith'], collectionId, 0);
    } catch (e) {
      throw Exception('Failed to fetch hadith: $e');
    }
  }

  /// Search hadiths
  Future<HadithSearchResponse> search({
    required String query,
    String? collectionId,
    String language = 'en',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'book': collectionId,
          'language': language,
          'page': page,
          'per_page': perPage,
        },
      );
      return _parseSearchResponse(response.data);
    } catch (e) {
      throw Exception('Failed to search hadiths: $e');
    }
  }

  /// Fetch random hadith
  Future<Hadith> fetchRandomHadith({String? collectionId}) async {
    try {
      String endpoint = '/random';
      if (collectionId != null) {
        endpoint += '?book=$collectionId';
      }
      final response = await _dio.get(endpoint);
      return _parseHadith(response.data['hadith'], collectionId ?? 'bukhari', 0);
    } catch (e) {
      throw Exception('Failed to fetch random hadith: $e');
    }
  }

  /// Fetch narrators
  Future<List<Narrator>> fetchNarrators({int page = 1, int perPage = 50}) async {
    try {
      final response = await _dio.get(
        '/narrators',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final data = response.data['narrators'] as List;
      return data.map((json) => _parseNarrator(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch narrators: $e');
    }
  }

  /// Fetch topics/categories
  Future<List<HadithTopic>> fetchTopics() async {
    try {
      final response = await _dio.get('/topics');
      final data = response.data['topics'] as List;
      return data.map((json) => _parseTopic(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch topics: $e');
    }
  }

  /// Fetch hadiths by topic
  Future<List<Hadith>> fetchHadithsByTopic(String topicId, {int page = 1, int perPage = 50}) async {
    try {
      final response = await _dio.get(
        '/topics/$topicId',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final data = response.data['hadiths'] as List;
      return data.map((json) => _parseHadith(json, 'mixed', 0)).toList();
    } catch (e) {
      throw Exception('Failed to fetch hadiths by topic: $e');
    }
  }

  /// Fetch related hadiths
  Future<List<Hadith>> fetchRelatedHadiths(String collectionId, int hadithNumber, {int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/books/$collectionId/$hadithNumber/related',
        queryParameters: {'limit': limit},
      );
      final data = response.data['hadiths'] as List;
      return data.map((json) => _parseHadith(json, collectionId, 0)).toList();
    } catch (e) {
      throw Exception('Failed to fetch related hadiths: $e');
    }
  }

  // ============ PARSERS ============

  HadithCollection _parseCollection(Map<String, dynamic> json) {
    return HadithCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      nameArabic: json['arabic_name'] as String? ?? '',
      author: json['author'] as String? ?? '',
      authorArabic: json['author_arabic'] as String? ?? '',
      authorBirthYear: json['author_birth_year'] as int? ?? 0,
      authorDeathYear: json['author_death_year'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      descriptionArabic: json['description_arabic'] as String? ?? '',
      totalHadiths: json['hadith_count'] as int? ?? 0,
      totalBooks: json['book_count'] as int? ?? 0,
      authenticity: _parseAuthenticity(json['authenticity'] as String? ?? 'mixed'),
      isDownloaded: false,
      availableLanguages: (json['languages'] as List?)?.map((e) => e as String).toList() ?? ['en', 'ar'],
      coverImageUrl: json['cover_image'] as String? ?? '',
    );
  }

  HadithCollectionDetail _parseCollectionDetail(Map<String, dynamic> json) {
    final collection = _parseCollection(json);
    final books = (json['chapters'] as List?)
        ?.map((b) => _parseBook(b, collection.id))
        .toList() ?? [];

    return HadithCollectionDetail(
      collection: collection,
      books: books,
    );
  }

  HadithBook _parseBook(Map<String, dynamic> json, String collectionId) {
    return HadithBook(
      id: '${collectionId}_${json['chapter_number']}',
      collectionId: collectionId,
      bookNumber: json['chapter_number'] as int,
      name: json['name'] as String,
      nameArabic: json['arabic_name'] as String? ?? '',
      description: json['description'] as String?,
      descriptionArabic: json['description_arabic'] as String?,
      hadithStartNumber: json['hadith_start'] as int? ?? 1,
      hadithEndNumber: json['hadith_end'] as int? ?? 0,
      totalHadiths: json['hadith_count'] as int? ?? 0,
      chapters: (json['sub_chapters'] as List?)?.map((c) => c['name'] as String).toList() ?? [],
    );
  }

  HadithChapter _parseChapter(Map<String, dynamic> json, String collectionId, int bookNumber) {
    final bookId = '${collectionId}_$bookNumber';
    return HadithChapter(
      id: '${bookId}_${json['section_number']}',
      bookId: bookId,
      chapterNumber: json['section_number'] as int,
      name: json['name'] as String,
      nameArabic: json['arabic_name'] as String? ?? '',
      hadithStartNumber: json['hadith_start'] as int? ?? 1,
      hadithEndNumber: json['hadith_end'] as int? ?? 0,
      totalHadiths: json['hadith_count'] as int? ?? 0,
    );
  }

  HadithBookDetail _parseHadithBookDetail(Map<String, dynamic> json, String collectionId, int bookNumber) {
    final hadithsData = json['hadiths'] as List;
    final hadiths = hadithsData.map((h) => _parseHadith(h, collectionId, bookNumber)).toList();

    return HadithBookDetail(
      book: HadithBook(
        id: '${collectionId}_$bookNumber',
        collectionId: collectionId,
        bookNumber: bookNumber,
        name: json['chapter']['name'] as String,
        nameArabic: json['chapter']['arabic_name'] as String? ?? '',
        hadithStartNumber: 1,
        hadithEndNumber: hadiths.length,
        totalHadiths: hadiths.length,
        chapters: [],
      ),
      hadiths: hadiths,
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['last_page'] as int? ?? 1,
      hasMore: json['current_page'] < json['last_page'],
    );
  }

  Hadith _parseHadith(Map<String, dynamic> json, String collectionId, int bookNumber) {
    final translations = <String, String>{};
    if (json['translations'] != null) {
      for (final entry in (json['translations'] as Map).entries) {
        translations[entry.key as String] = entry.value as String;
      }
    }

    final audioUrls = <String, String>{};
    if (json['audio'] != null) {
      for (final entry in (json['audio'] as Map).entries) {
        audioUrls[entry.key as String] = entry.value as String;
      }
    }

    return Hadith(
      id: '${collectionId}_${json['hadith_number']}',
      collectionId: collectionId,
      bookNumber: bookNumber,
      hadithNumber: json['hadith_number'] as int,
      bookHadithNumber: json['book_hadith_number'] as int?,
      chapterId: json['section_id'] as String?,
      textArabic: json['arabic'] as String? ?? '',
      translations: translations,
      narrators: (json['narrators'] as List?)?.map((n) => n as String).toList() ?? [],
      narratorChainArabic: json['narrator_chain_arabic'] as String? ?? '',
      grade: _parseGrade(json['grade'] as String?),
      gradeDetails: json['grade_details'] as String? ?? '',
      topics: (json['topics'] as List?)?.map((t) => t as String).toList() ?? [],
      keywords: (json['keywords'] as List?)?.map((k) => k as String).toList() ?? [],
      reference: json['reference'] as String? ?? '${collectionId.toUpperCase()} ${json['hadith_number']}',
      referenceUrl: json['reference_url'] as String?,
      audioUrls: audioUrls,
      audioDuration: null,
      isFavorite: false,
      addedToFavorites: null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  CollectionAuthenticity _parseAuthenticity(String authenticity) {
    switch (authenticity.toLowerCase()) {
      case 'sahih':
        return CollectionAuthenticity.sahih;
      case 'hasan':
        return CollectionAuthenticity.hasan;
      case 'weak':
        return CollectionAuthenticity.weak;
      default:
        return CollectionAuthenticity.mixed;
    }
  }

  HadithGrade _parseGrade(String? grade) {
    if (grade == null) return HadithGrade.unknown;
    switch (grade.toLowerCase()) {
      case 'sahih':
        return HadithGrade.sahih;
      case 'hasan':
        return HadithGrade.hasan;
      case 'daif':
      case 'weak':
        return HadithGrade.daif;
      case 'mawdu':
      case 'fabricated':
        return HadithGrade.mawdu;
      case 'munkar':
        return HadithGrade.munkar;
      case 'mudtarib':
        return HadithGrade.mudtarib;
      case 'muallal':
        return HadithGrade.muallal;
      default:
        return HadithGrade.unknown;
    }
  }

  Narrator _parseNarrator(Map<String, dynamic> json) {
    return Narrator(
      id: json['id'] as String,
      name: json['name'] as String,
      nameArabic: json['arabic_name'] as String? ?? '',
      kunya: json['kunya'] as String? ?? '',
      birthYear: json['birth_year'] as int?,
      deathYear: json['death_year'] as int?,
      biography: json['biography'] as String? ?? '',
      biographyArabic: json['biography_arabic'] as String? ?? '',
      reliability: _parseReliability(json['reliability'] as String? ?? 'majhul'),
      teachers: (json['teachers'] as List?)?.map((t) => t as String).toList() ?? [],
      students: (json['students'] as List?)?.map((s) => s as String).toList() ?? [],
      collections: (json['collections'] as List?)?.map((c) => c as String).toList() ?? [],
    );
  }

  NarratorReliability _parseReliability(String reliability) {
    switch (reliability.toLowerCase()) {
      case 'thiqa':
        return NarratorReliability.thiqa;
      case 'saduq':
        return NarratorReliability.saduq;
      case 'hasan':
        return NarratorReliability.hasan;
      case 'daif':
        return NarratorReliability.daif;
      case 'matruk':
        return NarratorReliability.matruk;
      case 'majhul':
        return NarratorReliability.majhul;
      case 'kadhdhab':
        return NarratorReliability.kadhdhab;
      case 'unknown':
        return NarratorReliability.unknown;
      default:
        return NarratorReliability.unknown;
    }
  }

  HadithTopic _parseTopic(Map<String, dynamic> json) {
    return HadithTopic(
      id: json['id'] as String,
      name: json['name'] as String,
      nameArabic: json['arabic_name'] as String? ?? '',
      parentId: json['parent_id'] as String?,
      level: json['level'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      descriptionArabic: json['description_arabic'] as String? ?? '',
      hadithCount: json['hadith_count'] as int? ?? 0,
      iconName: json['icon'] as String? ?? 'book',
    );
  }

  HadithSearchResponse _parseSearchResponse(Map<String, dynamic> json) {
    final hadithsData = json['hadiths'] as List;
    final hadiths = hadithsData.map((h) => _parseHadith(h, h['book'] as String? ?? 'bukhari', 0)).toList();

    return HadithSearchResponse(
      hadiths: hadiths,
      totalResults: json['total'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['last_page'] as int? ?? 1,
      query: json['query'] as String? ?? '',
    );
  }
}

/// Collection with books
class HadithCollectionDetail {
  final HadithCollection collection;
  final List<HadithBook> books;

  HadithCollectionDetail({required this.collection, required this.books});
}

/// Book with hadiths and pagination
class HadithBookDetail {
  final HadithBook book;
  final List<Hadith> hadiths;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  HadithBookDetail({
    required this.book,
    required this.hadiths,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });
}

/// Search response with pagination
class HadithSearchResponse {
  final List<Hadith> hadiths;
  final int totalResults;
  final int currentPage;
  final int totalPages;
  final String query;

  HadithSearchResponse({
    required this.hadiths,
    required this.totalResults,
    required this.currentPage,
    required this.totalPages,
    required this.query,
  });

  bool get hasMore => currentPage < totalPages;
}