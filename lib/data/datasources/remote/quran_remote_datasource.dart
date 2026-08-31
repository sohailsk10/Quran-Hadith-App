/// Remote data source for Quran data from API

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
            ));

  /// Fetch all Surahs
  Future<List<Surah>> fetchSurahs() async {
    try {
      final response = await _dio.get('/chapters');
      final data = response.data['chapters'] as List;
      return data.map((json) => _parseSurah(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch surahs: $e');
    }
  }

  /// Fetch a specific Surah with Ayahs
  Future<SurahDetail> fetchSurahDetail(int surahNumber, {String? translationId}) async {
    try {
      String endpoint = '/chapters/$surahNumber/verses';
      if (translationId != null) {
        endpoint += '?translations=$translationId';
      }
      final response = await _dio.get(endpoint);
      return _parseSurahDetail(response.data, surahNumber);
    } catch (e) {
      throw Exception('Failed to fetch surah detail: $e');
    }
  }

  /// Fetch Ayahs for a Surah
  Future<List<Ayah>> fetchAyahsBySurah(int surahNumber, {String? translationId}) async {
    try {
      String endpoint = '/chapters/$surahNumber/verses';
      if (translationId != null) {
        endpoint += '?translations=$translationId&fields=text_uthmani,text_imlaei_simple';
      }
      final response = await _dio.get(endpoint);
      final data = response.data['verses'] as List;
      return data.map((json) => _parseAyah(json, translationId)).toList();
    } catch (e) {
      throw Exception('Failed to fetch ayahs: $e');
    }
  }

  /// Fetch a specific Ayah
  Future<Ayah> fetchAyah(int surahNumber, int ayahNumber, {String? translationId}) async {
    try {
      String endpoint = '/verses/by_chapter/$surahNumber/$ayahNumber';
      if (translationId != null) {
        endpoint += '?translations=$translationId&fields=text_uthmani,text_imlaei_simple';
      }
      final response = await _dio.get(endpoint);
      return _parseAyah(response.data['verse'], translationId);
    } catch (e) {
      throw Exception('Failed to fetch ayah: $e');
    }
  }

  /// Fetch Juz (Para)
  Future<JuzDetail> fetchJuz(int juzNumber) async {
    try {
      final response = await _dio.get('/juzs/$juzNumber');
      return _parseJuz(response.data['juz']);
    } catch (e) {
      throw Exception('Failed to fetch juz: $e');
    }
  }

  /// Fetch all Juz
  Future<List<Juz>> fetchAllJuz() async {
    try {
      final response = await _dio.get('/juzs');
      final data = response.data['juzs'] as List;
      return data.map((json) => _parseJuz(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch juz list: $e');
    }
  }

  /// Fetch available translations
  Future<List<TranslationInfo>> fetchTranslations() async {
    try {
      final response = await _dio.get('/resources/translations');
      final data = response.data['translations'] as List;
      return data.map((json) => _parseTranslation(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch translations: $e');
    }
  }

  /// Fetch available reciters
  Future<List<ReciterInfo>> fetchReciters() async {
    try {
      final response = await _dio.get('/resources/recitations');
      final data = response.data['recitations'] as List;
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
      return response.data['verse']['audio_url'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Fetch Tafsir for an Ayah
  Future<List<Tafsir>> fetchTafsir(int surahNumber, int ayahNumber, {String language = 'en'}) async {
    try {
      final response = await _dio.get(
        '/verses/by_key/$surahNumber:$ayahNumber/tafsirs',
        queryParameters: {'language': language},
      );
      final data = response.data['tafsirs'] as List;
      return data.map((json) => _parseTafsir(json, surahNumber, ayahNumber)).toList();
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
      final data = response.data['search']['results'] as List;
      return data.map((json) => _parseSearchResult(json)).toList();
    } catch (e) {
      throw Exception('Failed to search: $e');
    }
  }

  /// Fetch Ayahs by Page
  Future<List<Ayah>> fetchAyahsByPage(int pageNumber, {String? translationId}) async {
    try {
      final response = await _dio.get(
        '/verses/by_page/$pageNumber',
        queryParameters: {
          'translations': translationId ?? 'en.sahih',
          'fields': 'text_uthmani,text_imlaei_simple',
        },
      );
      final data = response.data['verses'] as List;
      return data.map((json) => _parseAyah(json, translationId)).toList();
    } catch (e) {
      throw Exception('Failed to fetch ayahs by page: $e');
    }
  }

  /// Fetch Ayahs by Juz
  Future<List<Ayah>> fetchAyahsByJuz(int juzNumber, {String? translationId}) async {
    try {
      final response = await _dio.get(
        '/verses/by_juz/$juzNumber',
        queryParameters: {
          'translations': translationId ?? 'en.sahih',
          'fields': 'text_uthmani,text_imlaei_simple',
        },
      );
      final data = response.data['verses'] as List;
      return data.map((json) => _parseAyah(json, translationId)).toList();
    } catch (e) {
      throw Exception('Failed to fetch ayahs by juz: $e');
    }
  }

  // ============ PARSERS ============

  Surah _parseSurah(Map<String, dynamic> json) {
    return Surah(
      number: json['id'] as int,
      nameArabic: json['name_arabic'] as String,
      nameTransliteration: json['name_simple'] as String,
      nameTranslation: json['translated_name']['name'] as String,
      ayahCount: json['verses_count'] as int,
      revelationOrder: json['revelation_order'] as int,
      revelationType: json['revelation_place'] == 'meccan'
          ? RevelationType.meccan
          : RevelationType.medinan,
      juzNumber: (json['juzs'] as List).firstOrNull?['id'] as int? ?? 1,
      hizbNumber: 1,
      rubNumber: 1,
      bismillahArabic: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      bismillahTranslation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful',
      hasSajdah: json['sajdah'] != null,
      sajdahAyahNumbers: (json['sajdah'] as List?)?.map((e) => e['verse_number'] as int).toList() ?? [],
      pageStart: json['pages']?.firstOrNull?['page_number'] as int? ?? 1,
      pageEnd: json['pages']?.lastOrNull?['page_number'] as int? ?? 1,
      description: json['description'] as String? ?? '',
    );
  }

  SurahDetail _parseSurahDetail(Map<String, dynamic> json, int surahNumber) {
    final chapter = json['chapter'];
    final verses = json['verses'] as List;

    return SurahDetail(
      surah: _parseSurah(chapter),
      ayahs: verses.map((v) => _parseAyah(v, null)).toList(),
    );
  }

  Ayah _parseAyah(Map<String, dynamic> json, String? translationId) {
    final translations = <String, String>{};
    if (translationId != null && json['translations'] != null) {
      for (final t in json['translations']) {
        translations[t['resource_name'] as String] = t['text'] as String;
      }
    }

    final audioUrls = <String, String>{};
    if (json['recitations'] != null) {
      for (final r in json['recitations']) {
        audioUrls[r['reciter_id'] as String] = r['audio_url'] as String;
      }
    }

    return Ayah(
      number: json['verse_number'] as int,
      surahNumber: json['chapter_id'] as int,
      ayahInSurah: json['verse_number'] as int,
      textArabic: json['text_uthmani'] as String? ?? '',
      textUthmani: json['text_uthmani'] as String? ?? '',
      textSimple: json['text_imlaei_simple'] as String? ?? '',
      translations: translations,
      juzNumber: json['juz_number'] as int,
      hizbNumber: json['hizb_number'] as int,
      rubNumber: json['rub_number'] as int,
      pageNumber: json['page_number'] as int,
      isSajdah: json['sajdah'] != null,
      sajdahType: json['sajdah'] != null ? SajdahType.recommended : null,
      audioUrl: '',
      audioUrls: audioUrls,
      audioDuration: null,
      rukuNumber: json['ruku_number'] as int? ?? 1,
      manzilNumber: json['manzil_number'] as int? ?? 1,
    );
  }

  Juz _parseJuz(Map<String, dynamic> json) {
    return Juz(
      number: json['id'] as int,
      surahStart: json['verse_mapping']['start']['chapter_id'] as int,
      ayahStart: json['verse_mapping']['start']['verse_number'] as int,
      surahEnd: json['verse_mapping']['end']['chapter_id'] as int,
      ayahEnd: json['verse_mapping']['end']['verse_number'] as int,
      pageStart: json['pages']?.firstOrNull?['page_number'] as int? ?? 1,
      pageEnd: json['pages']?.lastOrNull?['page_number'] as int? ?? 1,
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
      id: json['id'] as String,
      name: json['name'] as String,
      language: json['language_code'] as String,
      languageName: json['language_name'] as String,
      author: json['author_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      isDownloaded: false,
    );
  }

  ReciterInfo _parseReciter(Map<String, dynamic> json) {
    return ReciterInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      nameArabic: json['arabic_name'] as String? ?? '',
      style: json['style'] == 'mujawwad' ? RecitationStyle.mujawwad : RecitationStyle.murattal,
      country: json['country'] as String? ?? '',
      isDownloaded: false,
    );
  }

  Tafsir _parseTafsir(Map<String, dynamic> json, int surahNumber, int ayahNumber) {
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