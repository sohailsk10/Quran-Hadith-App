/// Quran Repository - Single source of truth for Quran data

import 'package:dartz/dartz.dart';
import '../datasources/local/quran_local_datasource.dart';
import '../datasources/remote/quran_remote_datasource.dart';
import '../../shared/models/quran_models.dart';
import '../../shared/models/settings_models.dart';
import '../../core/constants/app_constants.dart';

class QuranRepository {
  final QuranLocalDataSource _localDataSource;
  final QuranRemoteDataSource _remoteDataSource;

  QuranRepository({
    required QuranLocalDataSource localDataSource,
    required QuranRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  /// Initialize the repository
  Future<void> init() async {
    await _localDataSource.init();
  }

  // ============ SURAHS ============

  Future<Either<Exception, List<Surah>>> getAllSurahs({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localSurahs = _localDataSource.getAllSurahs();
        if (localSurahs.isNotEmpty) {
          return Right(localSurahs);
        }
      }

      final remoteSurahs = await _remoteDataSource.fetchSurahs();
      await _localDataSource.saveSurahs(remoteSurahs);
      return Right(remoteSurahs);
    } catch (e) {
      return Left(Exception('Failed to get surahs: $e'));
    }
  }

  Future<Either<Exception, Surah?>> getSurah(int number, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localSurah = _localDataSource.getSurah(number);
        if (localSurah != null) {
          return Right(localSurah);
        }
      }

      // Need to fetch all surahs to get one
      final result = await getAllSurahs(forceRefresh: true);
      return result.fold(
        (error) => Left(error),
        (surahs) => Right(surahs.firstWhere((s) => s.number == number, orElse: () => throw Exception('Surah not found'))),
      );
    } catch (e) {
      return Left(Exception('Failed to get surah: $e'));
    }
  }

  // ============ AYAHS ============

  Future<Either<Exception, List<Ayah>>> getAyahsBySurah(
    int surahNumber, {
    String? translationId,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final localAyahs = _localDataSource.getAyahsBySurah(surahNumber);
        if (localAyahs.isNotEmpty) {
          return Right(localAyahs);
        }
      }

      final translation = translationId ?? AppConstants.defaultTranslation;
      final remoteAyahs = await _remoteDataSource.fetchAyahsBySurah(surahNumber, translationId: translation);
      await _localDataSource.saveAyahs(remoteAyahs);
      return Right(remoteAyahs);
    } catch (e) {
      return Left(Exception('Failed to get ayahs: $e'));
    }
  }

  Future<Either<Exception, Ayah?>> getAyah(
    int surahNumber,
    int ayahNumber, {
    String? translationId,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final localAyah = _localDataSource.getAyahBySurahAndAyah(surahNumber, ayahNumber);
        if (localAyah != null) {
          return Right(localAyah);
        }
      }

      final translation = translationId ?? AppConstants.defaultTranslation;
      final remoteAyah = await _remoteDataSource.fetchAyah(surahNumber, ayahNumber, translationId: translation);
      return Right(remoteAyah);
    } catch (e) {
      return Left(Exception('Failed to get ayah: $e'));
    }
  }

  Future<Either<Exception, List<Ayah>>> getAyahsByJuz(
    int juzNumber, {
    String? translationId,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final localAyahs = _localDataSource.getAyahsByJuz(juzNumber);
        if (localAyahs.isNotEmpty) {
          return Right(localAyahs);
        }
      }

      final translation = translationId ?? AppConstants.defaultTranslation;
      final remoteAyahs = await _remoteDataSource.fetchAyahsByJuz(juzNumber, translationId: translation);
      await _localDataSource.saveAyahs(remoteAyahs);
      return Right(remoteAyahs);
    } catch (e) {
      return Left(Exception('Failed to get ayahs by juz: $e'));
    }
  }

  Future<Either<Exception, List<Ayah>>> getAyahsByPage(
    int pageNumber, {
    String? translationId,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final localAyahs = _localDataSource.getAyahsByPage(pageNumber);
        if (localAyahs.isNotEmpty) {
          return Right(localAyahs);
        }
      }

      final translation = translationId ?? AppConstants.defaultTranslation;
      final remoteAyahs = await _remoteDataSource.fetchAyahsByPage(pageNumber, translationId: translation);
      await _localDataSource.saveAyahs(remoteAyahs);
      return Right(remoteAyahs);
    } catch (e) {
      return Left(Exception('Failed to get ayahs by page: $e'));
    }
  }

  // ============ JUZ ============

  Future<Either<Exception, List<Juz>>> getAllJuz({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localJuz = _localDataSource.getAllJuz();
        if (localJuz.isNotEmpty) {
          return Right(localJuz);
        }
      }

      final remoteJuz = await _remoteDataSource.fetchAllJuz();
      await _localDataSource.saveJuzList(remoteJuz);
      return Right(remoteJuz);
    } catch (e) {
      return Left(Exception('Failed to get juz: $e'));
    }
  }

  // ============ TRANSLATIONS ============

  Future<Either<Exception, List<TranslationInfo>>> getAllTranslations({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localTranslations = _localDataSource.getAllTranslations();
        if (localTranslations.isNotEmpty) {
          return Right(localTranslations);
        }
      }

      final remoteTranslations = await _remoteDataSource.fetchTranslations();
      await _localDataSource.saveTranslations(remoteTranslations);
      return Right(remoteTranslations);
    } catch (e) {
      return Left(Exception('Failed to get translations: $e'));
    }
  }

  Future<Either<Exception, void>> updateTranslationDownloadStatus(String id, bool downloaded, {String? localPath}) async {
    try {
      await _localDataSource.updateTranslationDownloadStatus(id, downloaded, localPath: localPath);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to update translation status: $e'));
    }
  }

  // ============ RECITERS ============

  Future<Either<Exception, List<ReciterInfo>>> getAllReciters({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final localReciters = _localDataSource.getAllReciters();
        if (localReciters.isNotEmpty) {
          return Right(localReciters);
        }
      }

      final remoteReciters = await _remoteDataSource.fetchReciters();
      await _localDataSource.saveReciters(remoteReciters);
      return Right(remoteReciters);
    } catch (e) {
      return Left(Exception('Failed to get reciters: $e'));
    }
  }

  Future<Either<Exception, void>> updateReciterDownloadStatus(String id, bool downloaded, {String? localPath, int? totalSize}) async {
    try {
      await _localDataSource.updateReciterDownloadStatus(id, downloaded, localPath: localPath, totalSize: totalSize);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to update reciter status: $e'));
    }
  }

  // ============ AUDIO ============

  Future<Either<Exception, String?>> getAudioUrl(int verseKey, String reciterId) async {
    try {
      // Check local first (would need audio file tracking)
      // For now, fetch from remote
      final url = await _remoteDataSource.fetchAudioUrl(verseKey, reciterId);
      return Right(url);
    } catch (e) {
      return Left(Exception('Failed to get audio URL: $e'));
    }
  }

  // ============ TAFSIR ============

  Future<Either<Exception, List<Tafsir>>> getTafsirForAyah(
    int surahNumber,
    int ayahNumber, {
    String language = 'en',
  }) async {
    try {
      final localTafsir = _localDataSource.getTafsirForAyah(surahNumber, ayahNumber);
      if (localTafsir.isNotEmpty) {
        return Right(localTafsir);
      }

      final remoteTafsir = await _remoteDataSource.fetchTafsir(surahNumber, ayahNumber, language: language);
      if (remoteTafsir.isNotEmpty) {
        await _localDataSource.saveTafsirList(remoteTafsir);
      }
      return Right(remoteTafsir);
    } catch (e) {
      return Left(Exception('Failed to get tafsir: $e'));
    }
  }

  // ============ SEARCH ============

  Future<Either<Exception, List<QuranSearchResult>>> search({
    required String query,
    String? translationId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Try local search first
      final localResults = _localDataSource.searchAyahs(query, translationId: translationId);
      if (localResults.isNotEmpty) {
        final surahs = _localDataSource.getAllSurahs();
        final results = localResults.map((ayah) {
          final surah = surahs.firstWhere((s) => s.number == ayah.surahNumber);
          return QuranSearchResult(
            ayah: ayah,
            surah: surah,
            matchedText: '',
            translationId: translationId ?? AppConstants.defaultTranslation,
          );
        }).toList();
        return Right(results);
      }

      // Fallback to remote
      final remoteResults = await _remoteDataSource.search(
        query: query,
        translationId: translationId,
        page: page,
        perPage: perPage,
      );
      return Right(remoteResults);
    } catch (e) {
      return Left(Exception('Failed to search: $e'));
    }
  }

  // ============ BOOKMARKS ============

  Future<Either<Exception, void>> addBookmark(QuranBookmark bookmark) async {
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

  Future<Either<Exception, List<QuranBookmark>>> getAllBookmarks() async {
    try {
      final bookmarks = _localDataSource.getAllBookmarks();
      return Right(bookmarks);
    } catch (e) {
      return Left(Exception('Failed to get bookmarks: $e'));
    }
  }

  Future<Either<Exception, QuranBookmark?>> getBookmarkForAyah(int surahNumber, int ayahNumber) async {
    try {
      final bookmark = _localDataSource.getBookmarkForAyah(surahNumber, ayahNumber);
      return Right(bookmark);
    } catch (e) {
      return Left(Exception('Failed to get bookmark: $e'));
    }
  }

  // ============ READING PROGRESS ============

  Future<Either<Exception, void>> saveReadingProgress(ReadingProgress progress) async {
    try {
      await _localDataSource.saveReadingProgress(progress);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to save reading progress: $e'));
    }
  }

  Future<Either<Exception, ReadingProgress?>> getReadingProgress(int surahNumber, int ayahNumber) async {
    try {
      final progress = _localDataSource.getReadingProgress(surahNumber, ayahNumber);
      return Right(progress);
    } catch (e) {
      return Left(Exception('Failed to get reading progress: $e'));
    }
  }

  Future<Either<Exception, List<ReadingProgress>>> getAllReadingProgress() async {
    try {
      final progress = _localDataSource.getAllReadingProgress();
      return Right(progress);
    } catch (e) {
      return Left(Exception('Failed to get reading progress: $e'));
    }
  }

  // ============ SETTINGS ============

  Future<Either<Exception, void>> saveSettings(AppSettings settings) async {
    try {
      await _localDataSource.saveSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to save settings: $e'));
    }
  }

  Future<Either<Exception, AppSettings>> getSettings() async {
    try {
      final settings = _localDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(Exception('Failed to get settings: $e'));
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