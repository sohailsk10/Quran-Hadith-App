/// Remote data source for Quran data from API

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../shared/models/quran_models.dart';
import '../../../core/constants/app_constants.dart';

class QuranRemoteDataSource {
  final Dio _dio;

  QuranRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.quranApiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              responseType: ResponseType.json,
            )) {
    if (_dio.options.baseUrl.isEmpty) {
      _dio.options.baseUrl = AppConstants.quranApiBaseUrl;
    }
  }

  Map<String, dynamic> _decodeResponse(dynamic data) {
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    return data as Map<String, dynamic>;
  }

  /// Fetch all Surahs
  Future<List<Surah>> fetchSurahs() async {
    try {
      final response = await _dio.get('/chapters');
      final body = _decodeResponse(response.data);
      final data = body['chapters'] as List;
      return data.map((json) => _parseSurah(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch surahs: $e');
    }
  }

  /// Fetch a specific Surah with Ayahs
  Future<SurahDetail> fetchSurahDetail(int surahNumber,
      {String? translationId}) async {
    try {
      final chapterResponse = await _dio.get('/chapters/$surahNumber');
      final chapterBody = _decodeResponse(chapterResponse.data);
      final surah = _parseSurah(chapterBody['chapter']);
      final ayahs = await fetchAyahsBySurah(surahNumber,
          translationId: translationId);
      return SurahDetail(surah: surah, ayahs: ayahs);
    } catch (e) {
      throw Exception('Failed to fetch surah detail: $e');
    }
  }

  /// Fetch Ayahs for a Surah
  Future<List<Ayah>> fetchAyahsBySurah(int surahNumber,
      {String? translationId}) async {
    try {
      final tId = _mapTranslationId(translationId);
      final response = await _dio.get(
        '/verses/by_chapter/$surahNumber',
        queryParameters: {
          'translations': tId,
          'fields': 'text_uthmani,text_imlaei_simple',
          'per_page': 300,
        },
      );
      final body = _decodeResponse(response.data);
      final data = body['verses'] as List;
      return data.map((json) => _parseAyah(json, translationId)).toList();
    } catch (e) {
      throw Exception('Failed to fetch ayahs: $e');
    }
  }

  /// Fetch a specific Ayah
  Future<Ayah> fetchAyah(int surahNumber, int ayahNumber,
      {String? translationId}) async {
    try {
      final tId = _mapTranslationId(translationId);
      final response = await _dio.get(
        '/verses/by_key/$surahNumber:$ayahNumber',
        queryParameters: {
          'translations': tId,
          'fields': 'text_uthmani,text_imlaei_simple',
        },
      );
      final body = _decodeResponse(response.data);
      return _parseAyah(body['verse'], translationId);
    } catch (e) {
      throw Exception('Failed to fetch ayah: $e');
    }
  }

  /// Fetch Juz (Para)
  Future<JuzDetail> fetchJuz(int juzNumber) async {
    try {
      final response = await _dio.get('/juzs/$juzNumber');
      final body = _decodeResponse(response.data);
      return _parseJuzDetail(body['juz']);
    } catch (e) {
      throw Exception('Failed to fetch juz: $e');
    }
  }

  /// Fetch all Juz
  Future<List<Juz>> fetchAllJuz() async {
    try {
      final response = await _dio.get('/juzs');
      final body = _decodeResponse(response.data);
      final data = body['juzs'] as List;
      final parsed = data.map((json) => _parseJuz(json as Map<String, dynamic>)).toList();
      final seen = <int>{};
      return parsed.where((j) => seen.add(j.number)).toList();
    } catch (e) {
      throw Exception('Failed to fetch juz list: $e');
    }
  }

  /// Fetch available translations
  Future<List<TranslationInfo>> fetchTranslations() async {
    try {
      final response = await _dio.get('/resources/translations');
      final body = _decodeResponse(response.data);
      final data = body['translations'] as List;
      return data.map((json) => _parseTranslation(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch translations: $e');
    }
  }

  /// Fetch available reciters
  Future<List<ReciterInfo>> fetchReciters() async {
    try {
      final response = await _dio.get('/resources/recitations');
      final body = _decodeResponse(response.data);
      final data = body['recitations'] as List;
      return data.map((json) => _parseReciter(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch reciters: $e');
    }
  }

  /// Fetch audio URL for an Ayah
  Future<String?> fetchAudioUrl(int verseKey, String reciterId) async {
    try {
      final response = await _dio.get(
        '/verses/by_key/$verseKey',
        queryParameters: {'recitation': reciterId, 'fields': 'audio_url'},
      );
      final body = _decodeResponse(response.data);
      return body['verse']['audio_url'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Fetch Tafsir for an Ayah
  Future<List<Tafsir>> fetchTafsir(int surahNumber, int ayahNumber,
      {String language = 'en'}) async {
    try {
      final response = await _dio.get(
        '/verses/by_key/$surahNumber:$ayahNumber/tafsirs',
        queryParameters: {'language': language},
      );
      final body = _decodeResponse(response.data);
      final data = body['tafsirs'] as List;
      return data
          .map((json) => _parseTafsir(json, surahNumber, ayahNumber))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tafsir: $e');
    }
  }

  /// Search Quran
  Future<List<QuranSearchResult>> search({
    required String query,
    String? translationId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'translations': translationId ?? 'en.sahih',
          'page': page,
          'per_page': perPage,
        },
      );
      final body = _decodeResponse(response.data);
      final data = body['search']['results'] as List;
      return data.map((json) => _parseSearchResult(json)).toList();
    } catch (e) {
      throw Exception('Failed to search: $e');
    }
  }

  /// Fetch Ayahs by Page
  Future<List<Ayah>> fetchAyahsByPage(int pageNumber,
      {String? translationId}) async {
    try {
      final tId = _mapTranslationId(translationId);
      final response = await _dio.get(
        '/verses/by_page/$pageNumber',
        queryParameters: {
          'translations': tId,
          'fields': 'text_uthmani,text_imlaei_simple',
          'per_page': 300,
        },
      );
      final body = _decodeResponse(response.data);
      final data = body['verses'] as List;
      return data.map((json) => _parseAyah(json, translationId)).toList();
    } catch (e) {
      throw Exception('Failed to fetch ayahs by page: $e');
    }
  }

  /// Fetch Ayahs by Juz
  Future<List<Ayah>> fetchAyahsByJuz(int juzNumber,
      {String? translationId}) async {
    try {
      final tId = _mapTranslationId(translationId);
      final response = await _dio.get(
        '/verses/by_juz/$juzNumber',
        queryParameters: {
          'translations': tId,
          'fields': 'text_uthmani,text_imlaei_simple',
          'per_page': 300,
        },
      );
      final body = _decodeResponse(response.data);
      final data = body['verses'] as List;
      return data.map((json) => _parseAyah(json, translationId)).toList();
    } catch (e) {
      throw Exception('Failed to fetch ayahs by juz: $e');
    }
  }

  int _mapTranslationId(String? translationId) {
    if (translationId == null) return 20;
    final parsed = int.tryParse(translationId);
    if (parsed != null) return parsed;
    return _translationSlugsToId[translationId] ?? 20;
  }

  static const Map<String, int> _translationSlugsToId = {
    'en.sahih': 20,
    'en.pickthall': 19,
    'en.yusufali': 22,
    'en.shakir': 20,
    'en.muhsin': 203,
    'ur.junagarhi': 54,
    'ur.maududi': 95,
    'tr.ozeley': 77,
    'tr.diyanet': 124,
    'id.kemenag': 33,
    'ms.basmeih': 39,
    'bn.bengali': 213,
    'fa.ayati': 29,
    'fr.hamidullah': 31,
    'de.bubenheim': 27,
    'ru.kuliev': 45,
    'zh.chinese': 109,
    'es.garcia': 199,
    'it.piccardo': 153,
    'nl.keyzer': 234,
    'pt.elhayek': 43,
    'sw.barwani': 235,
    'ta.tamil': 133,
    'ml.malayalam': 37,
  };

  // ============ PARSERS ============

  Surah _parseSurah(Map<String, dynamic> json) {
    final pages = json['pages'] as List?;
    return Surah(
      number: json['id'] as int,
      nameArabic: json['name_arabic'] as String,
      nameTransliteration: json['name_simple'] as String,
      nameTranslation: json['translated_name']['name'] as String,
      ayahCount: json['verses_count'] as int,
      revelationOrder: json['revelation_order'] as int,
      revelationType: json['revelation_place'] == 'makkah'
          ? RevelationType.meccan
          : RevelationType.medinan,
      juzNumber: 1,
      hizbNumber: 1,
      rubNumber: 1,
      bismillahArabic: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      bismillahTranslation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful',
      hasSajdah: false,
      sajdahAyahNumbers: [],
      pageStart: (pages != null && pages.isNotEmpty) ? (pages.first as int) : 1,
      pageEnd: (pages != null && pages.length > 1) ? (pages.last as int) : 1,
      description: '',
    );
  }

  Ayah _parseAyah(Map<String, dynamic> json, String? translationId) {
    final translations = <String, String>{};
    if (json['translations'] != null) {
      for (final t in json['translations'] as List) {
        if (t is Map<String, dynamic>) {
          final text = (t['text'] as String? ?? '')
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .trim();
          final resourceName = t['resource_name'] as String?;
          final resourceId = t['resource_id']?.toString();
          if (resourceName != null) translations[resourceName] = text;
          if (resourceId != null) translations[resourceId] = text;
          if (translationId != null) translations[translationId] = text;
          translations['default'] = text;
        }
      }
    }

    final audioUrls = <String, String>{};
    if (json['recitations'] != null) {
      for (final r in json['recitations'] as List) {
        if (r is Map<String, dynamic>) {
          final reciterId = r['reciter_id']?.toString();
          final audioUrl = r['audio_url'] as String?;
          if (reciterId != null && audioUrl != null) {
            audioUrls[reciterId] = audioUrl;
          }
        }
      }
    }

    final verseNumber = json['verse_number'] as int? ?? 1;
    final verseKey = json['verse_key'] as String? ?? '';
    final surahNum = json['chapter_id'] as int? ??
        (verseKey.isNotEmpty
            ? int.tryParse(verseKey.split(':').first) ?? 1
            : 1);

    return Ayah(
      number: json['id'] as int? ?? verseNumber,
      surahNumber: surahNum,
      ayahInSurah: verseNumber,
      textArabic: json['text_uthmani'] as String? ?? '',
      textUthmani: json['text_uthmani'] as String? ?? '',
      textSimple: json['text_imlaei_simple'] as String? ?? '',
      translations: translations,
      juzNumber: json['juz_number'] as int? ?? 1,
      hizbNumber: json['hizb_number'] as int? ?? 1,
      rubNumber: json['rub_el_hizb_number'] as int? ??
          json['rub_number'] as int? ??
          1,
      pageNumber: json['page_number'] as int? ?? 1,
      isSajdah: json['sajdah'] != null && json['sajdah'] != false,
      sajdahType: (json['sajdah'] != null && json['sajdah'] != false)
          ? SajdahType.recommended
          : null,
      audioUrl: '',
      audioUrls: audioUrls,
      audioDuration: null,
      rukuNumber: json['ruku_number'] as int? ?? 1,
      manzilNumber: json['manzil_number'] as int? ?? 1,
    );
  }

  Juz _parseJuz(Map<String, dynamic> json) {
    final verseMapping = json['verse_mapping'] as Map<String, dynamic>;
    final surahKeys = verseMapping.keys.map((k) => int.parse(k)).toList()..sort();
    final firstSurah = surahKeys.isNotEmpty ? surahKeys.first : 1;
    final lastSurah = surahKeys.isNotEmpty ? surahKeys.last : 1;

    int ayahStart = 1;
    int ayahEnd = 1;
    if (surahKeys.isNotEmpty) {
      final firstRange = verseMapping[surahKeys.first.toString()] as String;
      final lastRange = verseMapping[surahKeys.last.toString()] as String;
      ayahStart = int.parse(firstRange.split('-').first);
      ayahEnd = int.parse(lastRange.split('-').last);
    }

    return Juz(
      number: json['juz_number'] as int,
      surahStart: firstSurah,
      ayahStart: ayahStart,
      surahEnd: lastSurah,
      ayahEnd: ayahEnd,
      pageStart: 1,
      pageEnd: 1,
      ayahCount: json['verses_count'] as int,
    );
  }

  JuzDetail _parseJuzDetail(Map<String, dynamic> json) {
    final juz = _parseJuz(json);
    return JuzDetail(
      juz: juz,
      ayahs: [], // Would need separate fetch
    );
  }

  TranslationInfo _parseTranslation(Map<String, dynamic> json) {
    return TranslationInfo(
      id: json['id'].toString(),
      name: json['name'] as String,
      language: json['language_name'] as String? ?? 'english',
      languageName: json['language_name'] as String? ?? 'english',
      author: json['author_name'] as String? ?? '',
      description: '',
      year: 0,
      isDownloaded: false,
    );
  }

  ReciterInfo _parseReciter(Map<String, dynamic> json) {
    final style = (json['style'] as String?)?.toLowerCase();
    return ReciterInfo(
      id: json['id'].toString(),
      name: json['reciter_name'] as String? ?? json['name'] as String? ?? '',
      nameArabic: '',
      style: style == 'mujawwad'
          ? RecitationStyle.mujawwad
          : RecitationStyle.murattal,
      country: '',
      isDownloaded: false,
    );
  }

  Tafsir _parseTafsir(
      Map<String, dynamic> json, int surahNumber, int ayahNumber) {
    return Tafsir(
      id: json['id'] as String,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      source: json['resource_id'] as String,
      sourceName: json['resource_name'] as String,
      text: json['text'] as String,
      language: json['language_code'] as String? ?? 'en',
    );
  }

  QuranSearchResult _parseSearchResult(Map<String, dynamic> json) {
    final verse = json['verse'];
    return QuranSearchResult(
      ayah: _parseAyah(verse, null),
      surah: Surah(
        number: verse['chapter_id'] as int,
        nameArabic: '',
        nameTransliteration: '',
        nameTranslation: '',
        ayahCount: 0,
        revelationOrder: 0,
        revelationType: RevelationType.meccan,
        juzNumber: 0,
        hizbNumber: 0,
        rubNumber: 0,
        bismillahArabic: '',
        bismillahTranslation: '',
        hasSajdah: false,
        sajdahAyahNumbers: [],
        pageStart: 0,
        pageEnd: 0,
        description: '',
      ),
      matchedText: json['highlight'] as String? ?? '',
      translationId: json['translation_id'] as String? ?? 'en.sahih',
    );
  }
}

/// Surah with Ayahs
class SurahDetail {
  final Surah surah;
  final List<Ayah> ayahs;

  SurahDetail({required this.surah, required this.ayahs});
}

/// Juz with Ayahs
class JuzDetail {
  final Juz juz;
  final List<Ayah> ayahs;

  JuzDetail({required this.juz, required this.ayahs});
}
