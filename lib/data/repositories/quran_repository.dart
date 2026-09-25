/// Quran Repository - Single source of truth for Quran data

import '../datasources/local/quran_local_datasource.dart';
import '../datasources/remote/quran_remote_datasource.dart';
import '../../shared/models/quran_models.dart';
import '../../shared/models/settings_models.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/reciter_country_mapper.dart';

class QuranRepository {
  final QuranLocalDataSource _localDataSource;
  final QuranRemoteDataSource _remoteDataSource;

  QuranRepository({
    required QuranLocalDataSource localDataSource,
    required QuranRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  Future<void> init() async {
    await _localDataSource.init();
  }

  // ============ SURAHS ============

  Future<List<Surah>> getAllSurahs({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final localSurahs = _localDataSource.getAllSurahs();
      if (localSurahs.isNotEmpty) return localSurahs;
    }

    final remoteSurahs = await _remoteDataSource.fetchSurahs();
    await _localDataSource.saveSurahs(remoteSurahs);
    return remoteSurahs;
  }

  Future<Surah?> getSurah(int number, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final localSurah = _localDataSource.getSurah(number);
      if (localSurah != null) return localSurah;
    }

    final surahs = await getAllSurahs(forceRefresh: true);
    try {
      return surahs.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }

  // ============ AYAHS ============

  Future<List<Ayah>> getAyahsBySurah(
    int surahNumber, {
    String? translationId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final localAyahs = _localDataSource.getAyahsBySurah(surahNumber);
      if (localAyahs.isNotEmpty) return localAyahs;
    }

    final translation = translationId ?? AppConstants.defaultTranslation;
    final remoteAyahs = await _remoteDataSource.fetchAyahsBySurah(surahNumber,
        translationId: translation);
    await _localDataSource.saveAyahs(remoteAyahs);
    return remoteAyahs;
  }

  Future<Ayah?> getAyah(
    int surahNumber,
    int ayahNumber, {
    String? translationId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final localAyah =
          _localDataSource.getAyahBySurahAndAyah(surahNumber, ayahNumber);
      if (localAyah != null) return localAyah;
    }

    final translation = translationId ?? AppConstants.defaultTranslation;
    return await _remoteDataSource.fetchAyah(surahNumber, ayahNumber,
        translationId: translation);
  }

  Future<List<Ayah>> getAyahsByJuz(
    int juzNumber, {
    String? translationId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final localAyahs = _localDataSource.getAyahsByJuz(juzNumber);
      if (localAyahs.isNotEmpty) return localAyahs;
    }

    final translation = translationId ?? AppConstants.defaultTranslation;
    final remoteAyahs = await _remoteDataSource.fetchAyahsByJuz(juzNumber,
        translationId: translation);
    await _localDataSource.saveAyahs(remoteAyahs);
    return remoteAyahs;
  }

  Future<List<Ayah>> getAyahsByPage(
    int pageNumber, {
    String? translationId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final localAyahs = _localDataSource.getAyahsByPage(pageNumber);
      if (localAyahs.isNotEmpty) return localAyahs;
    }

    final translation = translationId ?? AppConstants.defaultTranslation;
    final remoteAyahs = await _remoteDataSource.fetchAyahsByPage(pageNumber,
        translationId: translation);
    await _localDataSource.saveAyahs(remoteAyahs);
    return remoteAyahs;
  }

  // ============ JUZ ============

  Future<List<Juz>> getAllJuz({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final localJuz = _localDataSource.getAllJuz();
      if (localJuz.isNotEmpty) return localJuz;
    }

    final remoteJuz = await _remoteDataSource.fetchAllJuz();
    await _localDataSource.saveJuzList(remoteJuz);
    return remoteJuz;
  }

  // ============ TRANSLATIONS ============

  Future<List<TranslationInfo>> getAllTranslations(
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final local = _localDataSource.getAllTranslations();
      if (local.isNotEmpty) return local;
    }

    final remote = await _remoteDataSource.fetchTranslations();
    await _localDataSource.saveTranslations(remote);
    return remote;
  }

  // ============ RECITERS ============

  Future<List<ReciterInfo>> getAllReciters({bool forceRefresh = false}) async {
    final standard = ReciterCountryMapper.getStandardReciters();
    if (!forceRefresh) {
      final local = _localDataSource.getAllReciters();
      if (local.isNotEmpty) {
        final missing =
            standard.where((s) => !local.any((r) => r.id == s.id)).toList();
        if (missing.isEmpty) return local;
        final merged = [...local, ...missing];
        await _localDataSource.saveReciters(merged);
        return merged;
      }
    }

    try {
      final remote = await _remoteDataSource.fetchReciters();
      final combined = [...remote];
      for (final s in standard) {
        if (!combined.any((r) => r.id == s.id || r.name == s.name)) {
          combined.add(s);
        }
      }
      await _localDataSource.saveReciters(combined);
      return combined;
    } catch (_) {
      await _localDataSource.saveReciters(standard);
      return standard;
    }
  }

  // ============ AUDIO ============

  Future<String?> getAudioUrl(int verseKey, String reciterId) async {
    return await _remoteDataSource.fetchAudioUrl(verseKey, reciterId);
  }

  // ============ TAFSIR ============

  Future<List<Tafsir>> getTafsirForAyah(
    int surahNumber,
    int ayahNumber, {
    String language = 'en',
  }) async {
    final localTafsir =
        _localDataSource.getTafsirForAyah(surahNumber, ayahNumber);
    if (localTafsir.isNotEmpty) return localTafsir;

    final remote = await _remoteDataSource.fetchTafsir(surahNumber, ayahNumber,
        language: language);
    if (remote.isNotEmpty) {
      await _localDataSource.saveTafsirList(remote);
    }
    return remote;
  }

  // ============ SEARCH ============

  Future<List<QuranSearchResult>> search({
    required String query,
    String? translationId,
    int page = 1,
    int perPage = 20,
  }) async {
    final localResults =
        _localDataSource.searchAyahs(query, translationId: translationId);
    if (localResults.isNotEmpty) {
      final surahs = _localDataSource.getAllSurahs();
      return localResults.map((ayah) {
        final surah = surahs.firstWhere(
          (s) => s.number == ayah.surahNumber,
          orElse: () => Surah(
            number: ayah.surahNumber,
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
        );
        return QuranSearchResult(
          ayah: ayah,
          surah: surah,
          matchedText: '',
          translationId: translationId ?? AppConstants.defaultTranslation,
        );
      }).toList();
    }

    return await _remoteDataSource.search(
      query: query,
      translationId: translationId,
      page: page,
      perPage: perPage,
    );
  }

  // ============ BOOKMARKS ============

  Future<void> addBookmark(QuranBookmark bookmark) async {
    await _localDataSource.addBookmark(bookmark);
  }

  Future<void> removeBookmark(String id) async {
    await _localDataSource.removeBookmark(id);
  }

  Future<List<QuranBookmark>> getAllBookmarks() async {
    return _localDataSource.getAllBookmarks();
  }

  Future<QuranBookmark?> getBookmarkForAyah(
      int surahNumber, int ayahNumber) async {
    return _localDataSource.getBookmarkForAyah(surahNumber, ayahNumber);
  }

  // ============ READING PROGRESS ============

  Future<void> saveReadingProgress(ReadingProgress progress) async {
    await _localDataSource.saveReadingProgress(progress);
  }

  Future<ReadingProgress?> getReadingProgress(
      int surahNumber, int ayahNumber) async {
    return _localDataSource.getReadingProgress(surahNumber, ayahNumber);
  }

  Future<List<ReadingProgress>> getAllReadingProgress() async {
    return _localDataSource.getAllReadingProgress();
  }

  // ============ SETTINGS ============

  Future<void> saveSettings(AppSettings settings) async {
    await _localDataSource.saveSettings(settings);
  }

  Future<AppSettings> getSettings() async {
    return await _localDataSource.getSettings();
  }

  // ============ UTILITY ============

  Future<void> clearAllData() async {
    await _localDataSource.clearAllData();
  }

  Future<void> close() async {
    await _localDataSource.close();
  }
}
