/// Remote data source for Hadith data from API with resilient CDN and offline fallbacks

import 'dart:math';
import 'package:dio/dio.dart';
import '../../../shared/models/hadith_models.dart';

class HadithRemoteDataSource {
  final Dio _dio;

  HadithRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Accept': 'application/json',
              },
            ));

  // ============ COLLECTIONS ============

  /// Fetch all available collections
  Future<List<HadithCollection>> fetchCollections() async {
    return _defaultCollections;
  }

  /// Fetch a specific collection with its books
  Future<HadithCollectionDetail> fetchCollectionDetail(
      String collectionId) async {
    final collection = _defaultCollections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => _defaultCollections.first,
    );
    final books = await fetchBooks(collectionId);
    return HadithCollectionDetail(collection: collection, books: books);
  }

  /// Fetch all books in a collection
  Future<List<HadithBook>> fetchBooks(String collectionId) async {
    return _getBooksForCollection(collectionId);
  }

  /// Fetch chapters in a book
  Future<List<HadithChapter>> fetchChapters(
      String collectionId, int bookNumber) async {
    return _getChaptersForBook(collectionId, bookNumber);
  }

  /// Fetch hadiths in a book with CDN support and fallback
  Future<HadithBookDetail> fetchHadithsByBook(
    String collectionId,
    int bookNumber, {
    int page = 1,
    int perPage = 50,
  }) async {
    final books = _getBooksForCollection(collectionId);
    final book = books.firstWhere(
      (b) => b.bookNumber == bookNumber,
      orElse: () => HadithBook(
        id: '${collectionId}_$bookNumber',
        collectionId: collectionId,
        bookNumber: bookNumber,
        name: 'Book $bookNumber',
        nameArabic: '',
        hadithStartNumber: 1,
        hadithEndNumber: 10,
        totalHadiths: 10,
        chapters: [],
      ),
    );

    // Try fetching from CDN
    try {
      final slug = _cdnSlug(collectionId);
      final engUrl =
          'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/eng-$slug/sections/$bookNumber.json';
      final araUrl =
          'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-$slug/sections/$bookNumber.json';
      final urdUrl =
          'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/urd-$slug/sections/$bookNumber.json';

      final responses = await Future.wait([
        _dio
            .get(engUrl)
            .catchError((_) => Response(requestOptions: RequestOptions(), statusCode: 500)),
        _dio
            .get(araUrl)
            .catchError((_) => Response(requestOptions: RequestOptions(), statusCode: 500)),
        _dio
            .get(urdUrl)
            .catchError((_) => Response(requestOptions: RequestOptions(), statusCode: 500)),
      ]);

      final engResponse = responses[0];
      final araResponse = responses[1];
      final urdResponse = responses[2];

      if (engResponse.statusCode == 200 && engResponse.data != null) {
        final data = engResponse.data as Map<String, dynamic>;
        final hadithsRaw = data['hadiths'] as List?;
        if (hadithsRaw != null && hadithsRaw.isNotEmpty) {
          final arabicMap = <int, String>{};
          if (araResponse.statusCode == 200 && araResponse.data != null) {
            final araList =
                (araResponse.data as Map<String, dynamic>)['hadiths'] as List?;
            if (araList != null) {
              for (final item in araList) {
                final num =
                    item['hadithnumber'] as int? ?? item['arabicnumber'] as int?;
                final text = item['text'] as String?;
                if (num != null && text != null) arabicMap[num] = text;
              }
            }
          }

          final urduMap = <int, String>{};
          if (urdResponse.statusCode == 200 && urdResponse.data != null) {
            final urdList =
                (urdResponse.data as Map<String, dynamic>)['hadiths'] as List?;
            if (urdList != null) {
              for (final item in urdList) {
                final num =
                    item['hadithnumber'] as int? ?? item['arabicnumber'] as int?;
                final text = item['text'] as String?;
                if (num != null && text != null) urduMap[num] = text;
              }
            }
          }

          final parsedHadiths = hadithsRaw.map((h) {
            final hNum = h['hadithnumber'] as int? ?? 1;
            final engText = (h['text'] as String? ?? '').trim();
            final araText = arabicMap[hNum] ?? '';
            final urdText = (urduMap[hNum] ?? '').trim();
            final grades = (h['grades'] as List?) ?? [];
            String gradeText = 'Sahih';
            HadithGrade grade = HadithGrade.sahih;
            if (grades.isNotEmpty) {
              final g = grades.first;
              if (g is Map && g['grade'] != null) {
                gradeText = g['grade'].toString();
                grade = _parseGrade(gradeText);
              }
            }

            final translations = <String, String>{};
            if (engText.isNotEmpty) translations['en'] = engText;
            if (urdText.isNotEmpty) translations['ur'] = urdText;

            return Hadith(
              id: '${collectionId}_$hNum',
              collectionId: collectionId,
              bookNumber: bookNumber,
              hadithNumber: hNum,
              bookHadithNumber: h['reference']?['hadith'] as int? ?? hNum,
              chapterId: '${collectionId}_${bookNumber}_1',
              textArabic: araText,
              translations: translations,
              narrators: [],
              narratorChainArabic: '',
              grade: grade,
              gradeDetails: gradeText,
              topics: [book.name],
              keywords: [],
              reference: '${book.name} #$hNum',
              referenceUrl: null,
              audioUrls: {},
              metadata: {
                'bookName': book.name,
                'chapterName': book.name,
              },
            );
          }).toList();

          return HadithBookDetail(
            book: book,
            hadiths: parsedHadiths,
            currentPage: 1,
            totalPages: 1,
            hasMore: false,
          );
        }
      }
    } catch (_) {
      // Fall back to built-in hadiths on network failure
    }

    return _buildFallbackBookDetail(book);
  }

  /// Fetch hadiths in a chapter
  Future<List<Hadith>> fetchHadithsByChapter(
      String collectionId, int bookNumber, int chapterNumber) async {
    final detail = await fetchHadithsByBook(collectionId, bookNumber);
    return detail.hadiths;
  }

  /// Fetch a specific hadith
  Future<Hadith> fetchHadith(String collectionId, int hadithNumber) async {
    try {
      final slug = _cdnSlug(collectionId);
      final engUrl =
          'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/eng-$slug/$hadithNumber.json';
      final araUrl =
          'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-$slug/$hadithNumber.json';
      final urdUrl =
          'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/urd-$slug/$hadithNumber.json';

      final responses = await Future.wait([
        _dio
            .get(engUrl)
            .catchError((_) => Response(requestOptions: RequestOptions(), statusCode: 500)),
        _dio
            .get(araUrl)
            .catchError((_) => Response(requestOptions: RequestOptions(), statusCode: 500)),
        _dio
            .get(urdUrl)
            .catchError((_) => Response(requestOptions: RequestOptions(), statusCode: 500)),
      ]);

      final engRes = responses[0];
      final araRes = responses[1];
      final urdRes = responses[2];

      if (engRes.statusCode == 200 && engRes.data != null) {
        final list = engRes.data['hadiths'] as List?;
        if (list != null && list.isNotEmpty) {
          final h = list.first;
          final engText = (h['text'] as String? ?? '').trim();
          final bookNum = h['reference']?['book'] as int? ?? 1;

          String araText = '';
          if (araRes.statusCode == 200 && araRes.data != null) {
            final aList = araRes.data['hadiths'] as List?;
            if (aList != null && aList.isNotEmpty) {
              araText = (aList.first['text'] as String? ?? '').trim();
            }
          }

          String urdText = '';
          if (urdRes.statusCode == 200 && urdRes.data != null) {
            final uList = urdRes.data['hadiths'] as List?;
            if (uList != null && uList.isNotEmpty) {
              urdText = (uList.first['text'] as String? ?? '').trim();
            }
          }

          final translations = <String, String>{};
          if (engText.isNotEmpty) translations['en'] = engText;
          if (urdText.isNotEmpty) translations['ur'] = urdText;

          return Hadith(
            id: '${collectionId}_$hadithNumber',
            collectionId: collectionId,
            bookNumber: bookNum,
            hadithNumber: hadithNumber,
            bookHadithNumber: h['reference']?['hadith'] as int? ?? hadithNumber,
            chapterId: null,
            textArabic: araText,
            translations: translations,
            narrators: [],
            narratorChainArabic: '',
            grade: HadithGrade.sahih,
            gradeDetails: 'Sahih',
            topics: [],
            keywords: [],
            reference: '$collectionId #$hadithNumber',
            audioUrls: {},
            metadata: {},
          );
        }
      }
    } catch (_) {}

    return _sampleHadiths.firstWhere(
      (h) => h.collectionId == collectionId && h.hadithNumber == hadithNumber,
      orElse: () => _sampleHadiths.first,
    );
  }

  /// Search hadiths
  Future<HadithSearchResponse> search({
    required String query,
    String? collectionId,
    String language = 'en',
    int page = 1,
    int perPage = 20,
  }) async {
    final lower = query.toLowerCase();
    final results = _sampleHadiths.where((h) {
      if (collectionId != null && h.collectionId != collectionId) return false;
      final t = h.getTranslation(language).toLowerCase();
      final a = h.textArabic;
      return t.contains(lower) || a.contains(query);
    }).toList();

    return HadithSearchResponse(
      hadiths: results,
      totalResults: results.length,
      currentPage: 1,
      totalPages: 1,
      query: query,
    );
  }

  /// Fetch random hadith
  Future<Hadith> fetchRandomHadith({String? collectionId}) async {
    final pool = collectionId != null
        ? _sampleHadiths.where((h) => h.collectionId == collectionId).toList()
        : _sampleHadiths;
    if (pool.isEmpty) return _sampleHadiths.first;
    return pool[Random().nextInt(pool.length)];
  }

  /// Fetch narrators
  Future<List<Narrator>> fetchNarrators(
      {int page = 1, int perPage = 50}) async {
    return _defaultNarrators;
  }

  /// Fetch topics/categories
  Future<List<HadithTopic>> fetchTopics() async {
    return _defaultTopics;
  }

  /// Fetch a specific topic
  Future<HadithTopic> fetchTopic(String topicId) async {
    return _defaultTopics.firstWhere(
      (t) => t.id == topicId,
      orElse: () => _defaultTopics.first,
    );
  }

  /// Fetch hadiths by topic
  Future<List<Hadith>> fetchHadithsByTopic(String topicId,
      {int page = 1, int perPage = 50}) async {
    return _sampleHadiths.where((h) => h.topics.contains(topicId)).toList();
  }

  /// Fetch related hadiths
  Future<List<Hadith>> fetchRelatedHadiths(
      String collectionId, int hadithNumber,
      {int limit = 10}) async {
    return _sampleHadiths
        .where((h) => h.collectionId == collectionId && h.hadithNumber != hadithNumber)
        .take(limit)
        .toList();
  }

  /// Fetch related topics
  Future<List<HadithTopic>> fetchRelatedTopics(String topicId) async {
    return _defaultTopics.where((t) => t.id != topicId).take(4).toList();
  }

  // ============ HELPERS & DATA ============

  String _cdnSlug(String collectionId) {
    switch (collectionId.toLowerCase()) {
      case 'abu-dawud':
      case 'abudawud':
        return 'abudawud';
      case 'ibn-majah':
      case 'ibnmajah':
        return 'ibnmajah';
      case 'bukhari':
        return 'bukhari';
      case 'muslim':
        return 'muslim';
      case 'nasai':
        return 'nasai';
      case 'tirmidhi':
        return 'tirmidhi';
      case 'malik':
        return 'malik';
      case 'ahmad':
        return 'ahmad';
      case 'darimi':
        return 'darimi';
      default:
        return collectionId;
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
      default:
        return HadithGrade.unknown;
    }
  }

  HadithBookDetail _buildFallbackBookDetail(HadithBook book) {
    final hadiths = _sampleHadiths
        .where((h) =>
            h.collectionId == book.collectionId && h.bookNumber == book.bookNumber)
        .toList();

    return HadithBookDetail(
      book: book,
      hadiths: hadiths.isNotEmpty
          ? hadiths
          : [
              Hadith(
                id: '${book.collectionId}_${book.bookNumber}_1',
                collectionId: book.collectionId,
                bookNumber: book.bookNumber,
                hadithNumber: book.hadithStartNumber,
                bookHadithNumber: 1,
                chapterId: '${book.collectionId}_${book.bookNumber}_1',
                textArabic:
                    'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
                translations: {
                  'en':
                      'The reward of deeds depends upon the intentions and every person will get the reward according to what he has intended.',
                  'ur':
                      'اعمال کا دارومدار نیتوں پر ہے اور ہر انسان کے لیے وہی ہے جس کی اس نے نیت کی۔',
                },
                narrators: ['Umar ibn al-Khattab'],
                narratorChainArabic: 'عمر بن الخطاب رضي الله عنه',
                grade: HadithGrade.sahih,
                gradeDetails: 'Sahih (Agreed Upon)',
                topics: [book.name, 'faith'],
                keywords: ['intentions', 'deeds', 'actions'],
                reference: '${book.name} #${book.hadithStartNumber}',
                audioUrls: {},
                metadata: {
                  'bookName': book.name,
                  'chapterName': book.name,
                },
              ),
            ],
      currentPage: 1,
      totalPages: 1,
      hasMore: false,
    );
  }

  static List<HadithBook> _getBooksForCollection(String collectionId) {
    final bookTitles = [
      ('Revelation', 'بدء الوحي', 1, 7),
      ('Belief', 'الإيمان', 8, 58),
      ('Knowledge', 'العلم', 59, 134),
      ('Ablution (Wudu\')', 'الوضوء', 135, 247),
      ('Bathing (Ghusl)', 'الغسل', 248, 293),
      ('Menses', 'الحيض', 294, 333),
      ('Rubbing hands and feet with dust (Tayammum)', 'التيمم', 334, 348),
      ('Prayers (Salat)', 'الصلاة', 349, 520),
      ('Times of the Prayers', 'مواقيت الصلاة', 521, 602),
      ('Call to Prayers (Adhan)', 'الأذان', 603, 875),
      ('Friday Prayer', 'الجمعة', 876, 941),
      ('Fear Prayer', 'صلاة الخوف', 942, 947),
      ('The Two Festivals (Eids)', 'العيدين', 948, 989),
      ('Witr Prayer', 'الوتر', 990, 1004),
      ('Invoking Allah for Rain (Istisqa)', 'الاستسقاء', 1005, 1039),
      ('Eclipses', 'الكسوف', 1040, 1066),
      ('Prostration During Recitation of Quran', 'سجود القرآن', 1067, 1079),
      ('Shortening the Prayers', 'تقصير الصلاة', 1080, 1119),
      ('Prayer at Night (Tahajjud)', 'التهجد', 1120, 1187),
      ('Virtues of Prayer at Masjid Makkah & Madinah', 'فضل الصلاة في مسجد مكة والمدينة', 1188, 1197),
      ('Funerals (Al-Jana\'iz)', 'الجنائز', 1198, 1394),
      ('Obligatory Charity (Zakat)', 'الزكاة', 1395, 1512),
      ('Fasting (Sawm)', 'الصوم', 1513, 1630),
      ('Night Prayer in Ramadan (Tarawih)', 'صلاة التراويح', 1631, 1641),
      ('Pilgrimage (Hajj)', 'الحج', 1642, 1772),
      ('Virtues of Good Manners', 'الأخلاق والآداب', 1773, 1900),
      ('Supplications (Dua)', 'الدعاء والذكر', 1901, 2050),
    ];

    return List.generate(bookTitles.length, (i) {
      final b = bookTitles[i];
      final bookNum = i + 1;
      return HadithBook(
        id: '${collectionId}_$bookNum',
        collectionId: collectionId,
        bookNumber: bookNum,
        name: b.$1,
        nameArabic: b.$2,
        hadithStartNumber: b.$3,
        hadithEndNumber: b.$4,
        totalHadiths: b.$4 - b.$3 + 1,
        chapters: ['Chapter 1', 'Chapter 2'],
      );
    });
  }

  static List<HadithChapter> _getChaptersForBook(
      String collectionId, int bookNumber) {
    final bookId = '${collectionId}_$bookNumber';
    return [
      HadithChapter(
        id: '${bookId}_1',
        bookId: bookId,
        chapterNumber: 1,
        name: 'Introduction',
        nameArabic: 'باب في ذلك',
        hadithStartNumber: 1,
        hadithEndNumber: 5,
        totalHadiths: 5,
      ),
      HadithChapter(
        id: '${bookId}_2',
        bookId: bookId,
        chapterNumber: 2,
        name: 'The Excellence and Virtue',
        nameArabic: 'باب الفضل والأجر',
        hadithStartNumber: 6,
        hadithEndNumber: 15,
        totalHadiths: 10,
      ),
    ];
  }

  // ============ CANONICAL DATA ============

  static final List<HadithCollection> _defaultCollections = [
    const HadithCollection(
      id: 'bukhari',
      name: 'Sahih al-Bukhari',
      nameArabic: 'صحيح البخاري',
      author: 'Imam Muhammad al-Bukhari',
      authorArabic: 'الإمام محمد بن إسماعيل البخاري',
      authorBirthYear: 194,
      authorDeathYear: 256,
      description:
          'The most authentic book of Hadith, compiled by Imam al-Bukhari over 16 years.',
      descriptionArabic: 'أصح كتاب بعد القرآن الكريم، جمعه الإمام البخاري رحمه الله.',
      totalHadiths: 7563,
      totalBooks: 97,
      totalChapters: 3882,
      authenticity: CollectionAuthenticity.sahih,
      availableLanguages: ['en', 'ar', 'ur', 'id'],
      coverImageUrl: 'assets/images/hadith_bukhari.png',
    ),
    const HadithCollection(
      id: 'muslim',
      name: 'Sahih Muslim',
      nameArabic: 'صحيح مسلم',
      author: 'Imam Muslim ibn al-Hajjaj',
      authorArabic: 'الإمام مسلم بن الحجاج النيسابوري',
      authorBirthYear: 204,
      authorDeathYear: 261,
      description:
          'The second most authentic collection, praised for its strict criteria and organized arrangement.',
      descriptionArabic: 'ثاني أصح دواوين السنة النبوية بعد صحيح البخاري.',
      totalHadiths: 7500,
      totalBooks: 56,
      totalChapters: 1200,
      authenticity: CollectionAuthenticity.sahih,
      availableLanguages: ['en', 'ar', 'ur', 'id'],
      coverImageUrl: 'assets/images/hadith_muslim.png',
    ),
    const HadithCollection(
      id: 'nasai',
      name: 'Sunan an-Nasa\'i',
      nameArabic: 'سنن النسائي',
      author: 'Imam Ahmad an-Nasa\'i',
      authorArabic: 'الإمام أحمد بن شعيب النسائي',
      authorBirthYear: 214,
      authorDeathYear: 303,
      description:
          'One of the Kutub al-Sittah, containing the least weak narrations among the Sunan.',
      descriptionArabic: 'من أصح كتب السنن وأقلها أحاديث ضعيفة.',
      totalHadiths: 5758,
      totalBooks: 52,
      totalChapters: 1500,
      authenticity: CollectionAuthenticity.mixed,
      availableLanguages: ['en', 'ar', 'ur'],
      coverImageUrl: 'assets/images/hadith_nasai.png',
    ),
    const HadithCollection(
      id: 'abu-dawud',
      name: 'Sunan Abi Dawud',
      nameArabic: 'سنن أبي داود',
      author: 'Imam Abu Dawud Sulayman',
      authorArabic: 'الإمام أبو داود السجستاني',
      authorBirthYear: 202,
      authorDeathYear: 275,
      description:
          'Focuses primarily on legal hadiths (Ahkam) and rulings of Islamic jurisprudence.',
      descriptionArabic: 'كتاب السنن المخصص لأحاديث الأحكام الفقهية.',
      totalHadiths: 5274,
      totalBooks: 43,
      totalChapters: 1800,
      authenticity: CollectionAuthenticity.mixed,
      availableLanguages: ['en', 'ar', 'ur'],
      coverImageUrl: 'assets/images/hadith_abudawud.png',
    ),
    const HadithCollection(
      id: 'tirmidhi',
      name: 'Jami\' at-Tirmidhi',
      nameArabic: 'جامع الترمذي',
      author: 'Imam Muhammad at-Tirmidhi',
      authorArabic: 'الإمام أبو عيسى الترمذي',
      authorBirthYear: 209,
      authorDeathYear: 279,
      description:
          'Distinguished by explicit grading of hadith authenticity and legal opinions of scholars.',
      descriptionArabic: 'يتميز ببيان درجات الحديث ومذاهب الفقهاء.',
      totalHadiths: 3956,
      totalBooks: 49,
      totalChapters: 1600,
      authenticity: CollectionAuthenticity.mixed,
      availableLanguages: ['en', 'ar', 'ur'],
      coverImageUrl: 'assets/images/hadith_tirmidhi.png',
    ),
    const HadithCollection(
      id: 'ibn-majah',
      name: 'Sunan Ibn Majah',
      nameArabic: 'سنن ابن ماجه',
      author: 'Imam Ibn Majah',
      authorArabic: 'الإمام محمد بن يزيد بن ماجه',
      authorBirthYear: 209,
      authorDeathYear: 273,
      description:
          'The sixth book of the Kutub al-Sittah, known for clear structure and comprehensive chapters.',
      descriptionArabic: 'سادس الكتب الستة المعتمدة لدى أهل الحديث.',
      totalHadiths: 4341,
      totalBooks: 37,
      totalChapters: 1500,
      authenticity: CollectionAuthenticity.mixed,
      availableLanguages: ['en', 'ar', 'ur'],
      coverImageUrl: 'assets/images/hadith_ibnmajah.png',
    ),
    const HadithCollection(
      id: 'malik',
      name: 'Muwatta Malik',
      nameArabic: 'موطأ مالك',
      author: 'Imam Malik ibn Anas',
      authorArabic: 'الإمام مالك بن أنس رحمه الله',
      authorBirthYear: 93,
      authorDeathYear: 179,
      description:
          'One of the earliest authoritative works on Hadith and Islamic law from Medina.',
      descriptionArabic: 'أقدم مصنف معتمد في الحديث الشريف والفقه الإسلامي.',
      totalHadiths: 1858,
      totalBooks: 61,
      totalChapters: 800,
      authenticity: CollectionAuthenticity.sahih,
      availableLanguages: ['en', 'ar', 'ur'],
      coverImageUrl: 'assets/images/hadith_malik.png',
    ),
    const HadithCollection(
      id: 'ahmad',
      name: 'Musnad Ahmad',
      nameArabic: 'مسند أحمد',
      author: 'Imam Ahmad ibn Hanbal',
      authorArabic: 'الإمام أحمد بن حنبل الشيباني',
      authorBirthYear: 164,
      authorDeathYear: 241,
      description:
          'The largest encyclopedic hadith collection, arranged by Companion narrators.',
      descriptionArabic: 'أكبر ديوان من دواوين السنة النبوية الشريفة مسنداً.',
      totalHadiths: 27647,
      totalBooks: 100,
      totalChapters: 3000,
      authenticity: CollectionAuthenticity.mixed,
      availableLanguages: ['en', 'ar'],
      coverImageUrl: 'assets/images/hadith_ahmad.png',
    ),
    const HadithCollection(
      id: 'darimi',
      name: 'Sunan ad-Darimi',
      nameArabic: 'سنن الدارمي',
      author: 'Imam Abdullah ad-Darimi',
      authorArabic: 'الإمام عبد الله بن عبد الرحمن الدارمي',
      authorBirthYear: 181,
      authorDeathYear: 255,
      description:
          'Distinguished by high-level transmissions and famous introduction on knowledge.',
      descriptionArabic: 'يمتاز بعلو أسانيده ومقدمته النفيسة في العلم.',
      totalHadiths: 3500,
      totalBooks: 24,
      totalChapters: 1200,
      authenticity: CollectionAuthenticity.mixed,
      availableLanguages: ['en', 'ar'],
      coverImageUrl: 'assets/images/hadith_darimi.png',
    ),
  ];

  static final List<HadithTopic> _defaultTopics = [
    const HadithTopic(
      id: 'faith',
      name: 'Faith & Belief (Iman)',
      nameArabic: 'الإيمان والعقيدة',
      level: 0,
      description: 'Hadiths on belief in Allah, the angels, books, and destiny.',
      descriptionArabic: 'أحاديث أركان الإيمان والتوحيد.',
      hadithCount: 1520,
      iconName: 'favorite',
    ),
    const HadithTopic(
      id: 'prayer',
      name: 'Prayer & Purification (Salah & Taharah)',
      nameArabic: 'الصلاة والطهارة',
      level: 0,
      description: 'Hadiths detailing the five daily prayers, wudu, and ghusl.',
      descriptionArabic: 'أحاديث الصلاة والوضوء والطهارة.',
      hadithCount: 2340,
      iconName: 'access_time',
    ),
    const HadithTopic(
      id: 'zakat',
      name: 'Zakat & Charity',
      nameArabic: 'الزكاة والصدقة',
      level: 0,
      description: 'Hadiths on mandatory zakat, voluntary sadaqah, and generosity.',
      descriptionArabic: 'أحاديث الإنفاق والزكاة والصدقة.',
      hadithCount: 840,
      iconName: 'volunteer_activism',
    ),
    const HadithTopic(
      id: 'fasting',
      name: 'Fasting & Ramadan (Sawm)',
      nameArabic: 'الصوم وشهر رمضان',
      level: 0,
      description: 'Virtues and rulings of fasting in Ramadan and voluntary fasts.',
      descriptionArabic: 'أحاديث صيام رمضان وصيام التطوع.',
      hadithCount: 680,
      iconName: 'nightlight_round',
    ),
    const HadithTopic(
      id: 'hajj',
      name: 'Hajj & Umrah Pilgrimage',
      nameArabic: 'الحج والعمرة',
      level: 0,
      description: 'Rites and virtues of performing pilgrimage to Makkah.',
      descriptionArabic: 'مناسك الحج والعمرة وفضائلها.',
      hadithCount: 920,
      iconName: 'mosque',
    ),
    const HadithTopic(
      id: 'manners',
      name: 'Good Manners & Character (Akhlaq)',
      nameArabic: 'الأخلاق والآداب',
      level: 0,
      description: 'Noble character, kindness, truthfulness, and relations with others.',
      descriptionArabic: 'أحاديث حسن الخلق والبر والصلة.',
      hadithCount: 1850,
      iconName: 'sentiment_very_satisfied',
    ),
    const HadithTopic(
      id: 'knowledge',
      name: 'Knowledge & Seeking Wisdom',
      nameArabic: 'العلم وفضله',
      level: 0,
      description: 'Virtues of seeking knowledge and teaching others.',
      descriptionArabic: 'فضل طلب العلم وتعليمه للناس.',
      hadithCount: 730,
      iconName: 'menu_book',
    ),
    const HadithTopic(
      id: 'dua',
      name: 'Supplication & Remembrance (Dua & Dhikr)',
      nameArabic: 'الدعاء والذكر',
      level: 0,
      description: 'Daily remembrance of Allah, morning and evening supplications.',
      descriptionArabic: 'أدعية اليوم والليلة وأذكار الصباح والمساء.',
      hadithCount: 1120,
      iconName: 'front_hand',
    ),
  ];

  static final List<Narrator> _defaultNarrators = [
    const Narrator(
      id: 'abu-hurairah',
      name: 'Abu Hurairah',
      nameArabic: 'أبو هريرة عبد الرحمن بن صخر الدوسي',
      kunya: 'Abu Hurairah',
      birthYear: 19,
      deathYear: 59,
      biography: 'The companion who narrated the most hadiths from the Prophet (ﷺ).',
      biographyArabic: 'صاحب رسول الله صلى الله عليه وسلم وأكثر الصحابة رواية للحديث.',
      reliability: NarratorReliability.thiqa,
      teachers: ['Prophet Muhammad (ﷺ)'],
      students: ['Said ibn al-Musayyib', 'Ibn Sirin', 'Hammam ibn Munabbih'],
      collections: ['bukhari', 'muslim', 'nasai', 'abu-dawud', 'tirmidhi', 'ibn-majah'],
    ),
    const Narrator(
      id: 'aisha',
      name: 'Aisha bint Abi Bakr',
      nameArabic: 'أم المؤمنين عائشة بنت أبي بكر الصديق',
      kunya: 'Umm Abdillah',
      birthYear: 9,
      deathYear: 58,
      biography: 'Mother of the Believers and foremost female scholar of Islam.',
      biographyArabic: 'أم المؤمنين وأفقه نساء الأمة ورواة الحديث النبوي.',
      reliability: NarratorReliability.thiqa,
      teachers: ['Prophet Muhammad (ﷺ)'],
      students: ['Urwah ibn al-Zubayr', 'Al-Qasim ibn Muhammad', 'Aswad ibn Yazid'],
      collections: ['bukhari', 'muslim', 'nasai', 'abu-dawud', 'tirmidhi', 'ibn-majah'],
    ),
    const Narrator(
      id: 'ibn-umar',
      name: 'Abdullah ibn Umar',
      nameArabic: 'عبد الله بن عمر بن الخطاب',
      kunya: 'Abu Abd al-Rahman',
      birthYear: 10,
      deathYear: 73,
      biography: 'Renowned for strict adherence to the Prophet\'s Sunnah in all matters.',
      biographyArabic: 'الصحابي الجليل المعروف بشدة اتباعه للسنة النبوية.',
      reliability: NarratorReliability.thiqa,
      teachers: ['Prophet Muhammad (ﷺ)', 'Umar ibn al-Khattab'],
      students: ['Nafi mawla Ibn Umar', 'Salim ibn Abdillah', 'Mujahid'],
      collections: ['bukhari', 'muslim', 'nasai', 'abu-dawud', 'tirmidhi', 'ibn-majah'],
    ),
    const Narrator(
      id: 'anas-ibn-malik',
      name: 'Anas ibn Malik',
      nameArabic: 'أنس بن مالك الأنصاري',
      kunya: 'Abu Hamzah',
      birthYear: 10,
      deathYear: 93,
      biography: 'Served the Prophet (ﷺ) for ten years in Medina.',
      biographyArabic: 'خادم رسول الله صلى الله عليه وسلم لعشر سنين.',
      reliability: NarratorReliability.thiqa,
      teachers: ['Prophet Muhammad (ﷺ)'],
      students: ['Thabit al-Bunani', 'Qatadah', 'Al-Zuhri'],
      collections: ['bukhari', 'muslim', 'nasai', 'abu-dawud', 'tirmidhi', 'ibn-majah'],
    ),
  ];

  static final List<Hadith> _sampleHadiths = [
    const Hadith(
      id: 'bukhari_1',
      collectionId: 'bukhari',
      bookNumber: 1,
      hadithNumber: 1,
      bookHadithNumber: 1,
      chapterId: 'bukhari_1_1',
      textArabic:
          'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى دُنْيَا يُصِيبُهَا أَوْ إِلَى امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ.',
      translations: {
        'en':
            'Narrated \'Umar bin Al-Khattab: I heard Allah\'s Messenger (ﷺ) saying, "The reward of deeds depends upon the intentions and every person will get the reward according to what he has intended. So whoever emigrated for worldly benefits or for a woman to marry, his emigration was for what he emigrated for."',
        'ur':
            'اعمال کا دارومدار نیتوں پر ہے اور ہر انسان کے لیے وہی ہے جس کی اس نے نیت کی۔ پس جس کی ہجرت دنیا حاصل کرنے کے لیے ہو یا کسی عورت سے شادی کی غرض سے ہو، تو اس کی ہجرت اسی کے لیے ہے جس کی طرف اس نے ہجرت کی۔',
      },
      narrators: ['Umar ibn al-Khattab', 'Alqamah ibn Waqqas', 'Muhammad ibn Ibrahim', 'Yahya ibn Said'],
      narratorChainArabic: 'عن عمر بن الخطاب رضي الله عنه',
      grade: HadithGrade.sahih,
      gradeDetails: 'Sahih (Muttafaq \'alayh)',
      topics: ['faith', 'Revelation'],
      keywords: ['intention', 'niyyah', 'deeds', 'hijrah', 'reward'],
      reference: 'Sahih al-Bukhari 1',
      audioUrls: {},
      metadata: {'bookName': 'Revelation', 'chapterName': 'How Divine Inspiration Began'},
    ),
    const Hadith(
      id: 'bukhari_2',
      collectionId: 'bukhari',
      bookNumber: 2,
      hadithNumber: 13,
      bookHadithNumber: 6,
      chapterId: 'bukhari_2_1',
      textArabic:
          'لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ.',
      translations: {
        'en':
            'Narrated Anas: The Prophet (ﷺ) said, "None of you will believe until he loves for his brother what he loves for himself."',
        'ur':
            'تم میں سے کوئی شخص اس وقت تک کامل مومن نہیں ہو سکتا جب تک کہ وہ اپنے بھائی کے لیے وہی پسند نہ کرے جو اپنے لیے پسند کرتا ہے۔',
      },
      narrators: ['Anas ibn Malik', 'Qatadah', 'Shu\'bah'],
      narratorChainArabic: 'عن أنس بن مالك رضي الله عنه',
      grade: HadithGrade.sahih,
      gradeDetails: 'Sahih (Muttafaq \'alayh)',
      topics: ['faith', 'manners', 'Belief'],
      keywords: ['brotherhood', 'love', 'faith', 'iman'],
      reference: 'Sahih al-Bukhari 13',
      audioUrls: {},
      metadata: {'bookName': 'Belief', 'chapterName': 'To Love for one\'s brother what one loves for oneself'},
    ),
    const Hadith(
      id: 'bukhari_3',
      collectionId: 'bukhari',
      bookNumber: 3,
      hadithNumber: 67,
      bookHadithNumber: 9,
      chapterId: 'bukhari_3_1',
      textArabic:
          'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ.',
      translations: {
        'en':
            'Narrated Abu Hurairah: The Messenger of Allah (ﷺ) said, "Whoever travels on a path in search of knowledge, Allah will make easy for him the path to Paradise."',
        'ur':
            'جو شخص علم کی تلاش میں کسی راستے پر چلتا ہے، اللہ تعالیٰ اس کے لیے اس کی بدولت جنت کا راستہ آسان فرما دیتا ہے۔',
      },
      narrators: ['Abu Hurairah', 'Al-A\'mash', 'Abu Salih'],
      narratorChainArabic: 'عن أبي هريرة رضي الله عنه',
      grade: HadithGrade.sahih,
      gradeDetails: 'Sahih',
      topics: ['knowledge', 'Knowledge'],
      keywords: ['knowledge', 'paradise', 'learning', 'ilm'],
      reference: 'Sahih al-Bukhari 67',
      audioUrls: {},
      metadata: {'bookName': 'Knowledge', 'chapterName': 'The Virtue of Knowledge'},
    ),
    const Hadith(
      id: 'muslim_1',
      collectionId: 'muslim',
      bookNumber: 1,
      hadithNumber: 8,
      bookHadithNumber: 1,
      chapterId: 'muslim_1_1',
      textArabic:
          'بُنِيَ الإِسْلاَمُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلاَةِ، وَإِيتَاءِ الزَّكَاةِ، وَحَجِّ الْبَيْتِ، وَصَوْمِ رَمَضَانَ.',
      translations: {
        'en':
            'Narrated Ibn \'Umar: The Messenger of Allah (ﷺ) said, "Islam is built on five (pillars): Testifying that there is no god but Allah and that Muhammad is the Messenger of Allah, performing prayer, paying zakat, making pilgrimage to the House, and fasting Ramadan."',
        'ur':
            'اسلام کی بنیاد پانچ چیزوں پر ہے: اس بات کی گواہی دینا کہ اللہ کے سوا کوئی معبود نہیں اور محمد صلی اللہ علیہ وسلم اللہ کے رسول ہیں، نماز قائم کرنا، زکوٰۃ دینا، بیت اللہ کا حج کرنا اور رمضان کے روزے رکھنا۔',
      },
      narrators: ['Abdullah ibn Umar', 'Tawus', 'Ibn Jurayj'],
      narratorChainArabic: 'عن عبد الله بن عمر رضي الله عنهما',
      grade: HadithGrade.sahih,
      gradeDetails: 'Sahih Muslim',
      topics: ['faith', 'prayer', 'zakat', 'fasting', 'hajj'],
      keywords: ['pillars of islam', 'five pillars', 'shahadah', 'salah', 'zakat'],
      reference: 'Sahih Muslim 8',
      audioUrls: {},
      metadata: {'bookName': 'Faith', 'chapterName': 'The Pillars of Islam'},
    ),
  ];
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
