/// Riverpod providers for the Quran & Hadith App

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/quran_local_datasource.dart';
import '../../data/datasources/local/hadith_local_datasource.dart';
import '../../data/datasources/remote/quran_remote_datasource.dart';
import '../../data/datasources/remote/hadith_remote_datasource.dart';
import '../../data/repositories/quran_repository.dart';
import '../../data/repositories/hadith_repository.dart';
import '../../shared/models/settings_models.dart';
import '../../shared/models/quran_models.dart';
import '../../shared/models/hadith_models.dart';
import '../../core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'app_providers.g.dart';

/// Dio provider
@riverpod
Dio dio(DioRef ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));
}

/// Quran Local DataSource provider
@riverpod
QuranLocalDataSource quranLocalDataSource(QuranLocalDataSourceRef ref) {
  return QuranLocalDataSource();
}

/// Hadith Local DataSource provider
@riverpod
HadithLocalDataSource hadithLocalDataSource(HadithLocalDataSourceRef ref) {
  return HadithLocalDataSource();
}

/// Quran Remote DataSource provider
@riverpod
QuranRemoteDataSource quranRemoteDataSource(QuranRemoteDataSourceRef ref) {
  return QuranRemoteDataSource(dio: ref.watch(dioProvider));
}

/// Hadith Remote DataSource provider
@riverpod
HadithRemoteDataSource hadithRemoteDataSource(HadithRemoteDataSourceRef ref) {
  return HadithRemoteDataSource(dio: ref.watch(dioProvider));
}

/// Quran Repository provider
@riverpod
QuranRepository quranRepository(QuranRepositoryRef ref) {
  return QuranRepository(
    localDataSource: ref.watch(quranLocalDataSourceProvider),
    remoteDataSource: ref.watch(quranRemoteDataSourceProvider),
  );
}

/// Hadith Repository provider
@riverpod
HadithRepository hadithRepository(HadithRepositoryRef ref) {
  return HadithRepository(
    localDataSource: ref.watch(hadithLocalDataSourceProvider),
    remoteDataSource: ref.watch(hadithRemoteDataSourceProvider),
  );
}

/// Initialize repositories provider
@riverpod
Future<void> initializeRepositories(InitializeRepositoriesRef ref) async {
  await ref.watch(quranRepositoryProvider).init();
  await ref.watch(hadithRepositoryProvider).init();
}

/// Settings provider
@riverpod
class Settings extends _$Settings {
  @override
  Future<AppSettings> build() async {
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getSettings();
    return result.fold(
      (error) => const AppSettings(),
      (settings) => settings,
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = const AsyncLoading();
    final repository = ref.read(quranRepositoryProvider);
    final result = await repository.saveSettings(settings);
    state = await AsyncValue.guard(() async {
      result.fold(
        (error) => throw error,
        (_) => settings,
      );
    });
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(themeMode: themeMode));
  }

  Future<void> updateLanguage(AppLanguage language) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(language: language));
  }

  Future<void> updateTranslation(String translationId) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(selectedTranslationId: translationId));
  }

  Future<void> updateQuranDisplay(QuranDisplaySettings quranDisplay) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(quranDisplay: quranDisplay));
  }

  Future<void> updateAudioSettings(AudioSettings audio) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(audio: audio));
  }

  Future<void> updateHadithDisplay(HadithDisplaySettings hadithDisplay) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(hadithDisplay: hadithDisplay));
  }

  Future<void> updateNotifications(NotificationSettings notifications) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(notifications: notifications));
  }

  Future<void> updatePrivacy(PrivacySettings privacy) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(privacy: privacy));
  }
}

/// Quran Surahs provider
@riverpod
class Surahs extends _$Surahs {
  @override
  Future<List<Surah>> build() async {
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getAllSurahs();
    return result.fold(
      (error) => throw error,
      (surahs) => surahs,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(quranRepositoryProvider);
    final result = await repository.getAllSurahs(forceRefresh: true);
    state = AsyncValue.data(result.fold((error) => throw error, (surahs) => surahs));
  }
}

/// Selected Surah provider
@riverpod
class SelectedSurah extends _$SelectedSurah {
  @override
  Future<Surah?> build(int surahNumber) async {
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getSurah(surahNumber);
    return result.fold(
      (error) => throw error,
      (surah) => surah,
    );
  }
}

/// Surah Ayahs provider
@riverpod
class SurahAyahs extends _$SurahAyahs {
  @override
  Future<List<Ayah>> build(int surahNumber) async {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final translationId = settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getAyahsBySurah(surahNumber, translationId: translationId);
    return result.fold(
      (error) => throw error,
      (ayahs) => ayahs,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final settings = ref.read(settingsProvider).valueOrNull;
    final translationId = settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
    final repository = ref.read(quranRepositoryProvider);
    final surahNumber = state.valueOrNull?.first.surahNumber ?? 1;
    final result = await repository.getAyahsBySurah(surahNumber, translationId: translationId, forceRefresh: true);
    state = AsyncValue.data(result.fold((error) => throw error, (ayahs) => ayahs));
  }
}

/// Ayah provider
@riverpod
class Ayah extends _$Ayah {
  @override
  Future<Ayah?> build(int surahNumber, int ayahNumber) async {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final translationId = settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getAyah(surahNumber, ayahNumber, translationId: translationId);
    return result.fold(
      (error) => throw error,
      (ayah) => ayah,
    );
  }
}

/// Juz provider
@riverpod
class Juzs extends _$Juzs {
  @override
  Future<List<Juz>> build() async {
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getAllJuz();
    return result.fold(
      (error) => throw error,
      (juz) => juz,
    );
  }
}

/// Juz Ayahs provider
@riverpod
class JuzAyahs extends _$JuzAyahs {
  @override
  Future<List<Ayah>> build(int juzNumber) async {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final translationId = settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getAyahsByJuz(juzNumber, translationId: translationId);
    return result.fold(
      (error) => throw error,
      (ayahs) => ayahs,
    );
  }
}

/// Page Ayahs provider
@riverpod
class PageAyahs extends _$PageAyahs {
  @override
  Future<List<Ayah>> build(int pageNumber) async {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final translationId = settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getAyahsByPage(pageNumber, translationId: translationId);
    return result.fold(
      (error) => throw error,
      (ayahs) => ayahs,
    );
  }
}

/// Translations provider
@riverpod
class Translations extends _$Translations {
  @override
  Future<List<TranslationInfo>> build() async {
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getAllTranslations();
    return result.fold(
      (error) => throw error,
      (translations) => translations,
    );
  }
}

/// Reciters provider
@riverpod
class Reciters extends _$Reciters {
  @override
  Future<List<ReciterInfo>> build() async {
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getAllReciters();
    return result.fold(
      (error) => throw error,
      (reciters) => reciters,
    );
  }
}

/// Bookmarks provider
@riverpod
class QuranBookmarks extends _$QuranBookmarks {
  @override
  Future<List<QuranBookmark>> build() async {
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getAllBookmarks();
    return result.fold(
      (error) => throw error,
      (bookmarks) => bookmarks,
    );
  }

  Future<void> add(QuranBookmark bookmark) async {
    final repository = ref.read(quranRepositoryProvider);
    final result = await repository.addBookmark(bookmark);
    result.fold(
      (error) => throw error,
      (_) => refresh(),
    );
  }

  Future<void> remove(String id) async {
    final repository = ref.read(quranRepositoryProvider);
    final result = await repository.removeBookmark(id);
    result.fold(
      (error) => throw error,
      (_) => refresh(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(quranRepositoryProvider);
    final result = await repository.getAllBookmarks();
    state = AsyncValue.data(result.fold((error) => throw error, (bookmarks) => bookmarks));
  }
}

/// Reading Progress provider
@riverpod
class ReadingProgress extends _$ReadingProgress {
  @override
  Future<List<ReadingProgress>> build() async {
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getAllReadingProgress();
    return result.fold(
      (error) => throw error,
      (progress) => progress,
    );
  }

  Future<void> save(ReadingProgress progress) async {
    final repository = ref.read(quranRepositoryProvider);
    final result = await repository.saveReadingProgress(progress);
    result.fold(
      (error) => throw error,
      (_) => refresh(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(quranRepositoryProvider);
    final result = await repository.getAllReadingProgress();
    state = AsyncValue.data(result.fold((error) => throw error, (progress) => progress));
  }
}

/// Tafsir provider
@riverpod
class Tafsir extends _$Tafsir {
  @override
  Future<List<Tafsir>> build(int surahNumber, int ayahNumber) async {
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.getTafsirForAyah(surahNumber, ayahNumber);
    return result.fold(
      (error) => throw error,
      (tafsir) => tafsir,
    );
  }
}

/// Quran Search provider
@riverpod
class QuranSearch extends _$QuranSearch {
  @override
  Future<List<QuranSearchResult>> build(String query) async {
    if (query.trim().isEmpty) return [];

    final settings = ref.watch(settingsProvider).valueOrNull;
    final translationId = settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
    final repository = ref.watch(quranRepositoryProvider);
    final result = await repository.search(query: query, translationId: translationId);
    return result.fold(
      (error) => throw error,
      (results) => results,
    );
  }
}

/// Hadith Collections provider
@riverpod
class HadithCollections extends _$HadithCollections {
  @override
  Future<List<HadithCollection>> build() async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getAllCollections();
    return result.fold(
      (error) => throw error,
      (collections) => collections,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(hadithRepositoryProvider);
    final result = await repository.getAllCollections(forceRefresh: true);
    state = AsyncValue.data(result.fold((error) => throw error, (collections) => collections));
  }
}

/// Collection Detail provider
@riverpod
class HadithCollectionDetail extends _$HadithCollectionDetail {
  @override
  Future<HadithCollectionDetail> build(String collectionId) async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getCollectionDetail(collectionId);
    return result.fold(
      (error) => throw error,
      (detail) => detail,
    );
  }
}

/// Books provider
@riverpod
class HadithBooks extends _$HadithBooks {
  @override
  Future<List<HadithBook>> build(String collectionId) async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getBooksByCollection(collectionId);
    return result.fold(
      (error) => throw error,
      (books) => books,
    );
  }
}

/// Chapters provider
@riverpod
class HadithChapters extends _$HadithChapters {
  @override
  Future<List<HadithChapter>> build(String bookId) async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getChaptersByBook(bookId);
    return result.fold(
      (error) => throw error,
      (chapters) => chapters,
    );
  }
}

/// Hadiths by Book provider
@riverpod
class HadithsByBook extends _$HadithsByBook {
  @override
  Future<HadithBookDetail> build({
    required String collectionId,
    required int bookNumber,
    int page = 1,
  }) async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getHadithsByBook(collectionId, bookNumber, page: page);
    return result.fold(
      (error) => throw error,
      (detail) => detail,
    );
  }
}

/// Hadiths by Chapter provider
@riverpod
class HadithsByChapter extends _$HadithsByChapter {
  @override
  Future<List<Hadith>> build(String chapterId) async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getHadithsByChapter(chapterId);
    return result.fold(
      (error) => throw error,
      (hadiths) => hadiths,
    );
  }
}

/// Single Hadith provider
@riverpod
class HadithDetail extends _$HadithDetail {
  @override
  Future<Hadith?> build(String collectionId, int hadithNumber) async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getHadith(collectionId, hadithNumber);
    return result.fold(
      (error) => throw error,
      (hadith) => hadith,
    );
  }
}

/// Favorite Hadiths provider
@riverpod
class FavoriteHadiths extends _$FavoriteHadiths {
  @override
  Future<List<Hadith>> build() async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getFavoriteHadiths();
    return result.fold(
      (error) => throw error,
      (hadiths) => hadiths,
    );
  }

  Future<void> toggle(String hadithId, bool isFavorite) async {
    final repository = ref.read(hadithRepositoryProvider);
    final result = await repository.toggleFavorite(hadithId, isFavorite);
    result.fold(
      (error) => throw error,
      (_) => refresh(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(hadithRepositoryProvider);
    final result = await repository.getFavoriteHadiths();
    state = AsyncValue.data(result.fold((error) => throw error, (hadiths) => hadiths));
  }
}

/// Hadith Search provider
@riverpod
class HadithSearch extends _$HadithSearch {
  @override
  Future<List<Hadith>> build(String query) async {
    if (query.trim().isEmpty) return [];

    final settings = ref.watch(settingsProvider).valueOrNull;
    final languageCode = settings?.language.code ?? 'en';
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.search(query: query, languageCode: languageCode);
    return result.fold(
      (error) => throw error,
      (hadiths) => hadiths,
    );
  }
}

/// Narrators provider
@riverpod
class Narrators extends _$Narrators {
  @override
  Future<List<Narrator>> build() async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getAllNarrators();
    return result.fold(
      (error) => throw error,
      (narrators) => narrators,
    );
  }
}

/// Topics provider
@riverpod
class HadithTopics extends _$HadithTopics {
  @override
  Future<List<HadithTopic>> build() async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getAllTopics();
    return result.fold(
      (error) => throw error,
      (topics) => topics,
    );
  }
}

/// Top Level Topics provider
@riverpod
class TopLevelHadithTopics extends _$TopLevelHadithTopics {
  @override
  Future<List<HadithTopic>> build() async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getTopLevelTopics();
    return result.fold(
      (error) => throw error,
      (topics) => topics,
    );
  }
}

/// Child Topics provider
@riverpod
class ChildHadithTopics extends _$ChildHadithTopics {
  @override
  Future<List<HadithTopic>> build(String parentId) async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getChildTopics(parentId);
    return result.fold(
      (error) => throw error,
      (topics) => topics,
    );
  }
}

/// Hadith Bookmarks provider
@riverpod
class HadithBookmarks extends _$HadithBookmarks {
  @override
  Future<List<HadithBookmark>> build() async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getAllBookmarks();
    return result.fold(
      (error) => throw error,
      (bookmarks) => bookmarks,
    );
  }

  Future<void> add(HadithBookmark bookmark) async {
    final repository = ref.read(hadithRepositoryProvider);
    final result = await repository.addBookmark(bookmark);
    result.fold(
      (error) => throw error,
      (_) => refresh(),
    );
  }

  Future<void> remove(String id) async {
    final repository = ref.read(hadithRepositoryProvider);
    final result = await repository.removeBookmark(id);
    result.fold(
      (error) => throw error,
      (_) => refresh(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(hadithRepositoryProvider);
    final result = await repository.getAllBookmarks();
    state = AsyncValue.data(result.fold((error) => throw error, (bookmarks) => bookmarks));
  }
}

/// Hadiths by Topic provider
@riverpod
class HadithsByTopic extends _$HadithsByTopic {
  @override
  Future<List<Hadith>> build(String topicId) async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getHadithsByTopic(topicId);
    return result.fold(
      (error) => throw error,
      (hadiths) => hadiths,
    );
  }
}

/// Narrators for a specific hadith
@riverpod
class HadithNarrators extends _$HadithNarrators {
  @override
  Future<List<Narrator>> build(List<String> narratorIds) async {
    if (narratorIds.isEmpty) return [];

    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getNarratorsByIds(narratorIds);
    return result.fold(
      (error) => throw error,
      (narrators) => narrators,
    );
  }
}

/// Related hadiths provider
@riverpod
class RelatedHadiths extends _$RelatedHadiths {
  @override
  Future<List<Hadith>> build({
    required String collectionId,
    required int hadithNumber,
    int limit = 10,
  }) async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getRelatedHadiths(
      collectionId: collectionId,
      hadithNumber: hadithNumber,
      limit: limit,
    );
    return result.fold(
      (error) => throw error,
      (hadiths) => hadiths,
    );
  }
}

/// Random Hadith provider
@riverpod
class RandomHadith extends _$RandomHadith {
  @override
  Future<Hadith?> build({String? collectionId}) async {
    final repository = ref.watch(hadithRepositoryProvider);
    final result = await repository.getRandomHadith(collectionId: collectionId);
    return result.fold(
      (error) => throw error,
      (hadith) => hadith,
    );
  }

  Future<void> refresh({String? collectionId}) async {
    state = const AsyncLoading();
    final repository = ref.read(hadithRepositoryProvider);
    final result = await repository.getRandomHadith(collectionId: collectionId);
    state = AsyncValue.data(result.fold((error) => throw error, (hadith) => hadith));
  }
}

/// Audio Player State provider
@riverpod
class AudioPlayerState extends _$AudioPlayerState {
  @override
  AudioPlayerStateData build() {
    return const AudioPlayerStateData();
  }

  void setPlaying(bool playing) {
    state = state.copyWith(isPlaying: playing);
  }

  void setCurrentAyah(Ayah? ayah) {
    state = state.copyWith(currentAyah: ayah);
  }

  void setPlaylist(List<Ayah> playlist) {
    state = state.copyWith(playlist: playlist, currentIndex: 0);
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setRepeatMode(AudioRepeatMode mode) {
    state = state.copyWith(repeatMode: mode);
  }

  void setPlaybackSpeed(PlaybackSpeed speed) {
    state = state.copyWith(playbackSpeed: speed);
  }

  void next() {
    if (state.currentIndex < state.playlist.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    } else if (state.repeatMode == AudioRepeatMode.all) {
      state = state.copyWith(currentIndex: 0);
    }
  }

  void previous() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }
}

@immutable
class AudioPlayerStateData {
  final bool isPlaying;
  final Ayah? currentAyah;
  final List<Ayah> playlist;
  final int currentIndex;
  final AudioRepeatMode repeatMode;
  final PlaybackSpeed playbackSpeed;

  const AudioPlayerStateData({
    this.isPlaying = false,
    this.currentAyah,
    this.playlist = const [],
    this.currentIndex = 0,
    this.repeatMode = AudioRepeatMode.none,
    this.playbackSpeed = PlaybackSpeed.x1_0,
  });

  AudioPlayerStateData copyWith({
    bool? isPlaying,
    Ayah? currentAyah,
    List<Ayah>? playlist,
    int? currentIndex,
    AudioRepeatMode? repeatMode,
    PlaybackSpeed? playbackSpeed,
  }) {
    return AudioPlayerStateData(
      isPlaying: isPlaying ?? this.isPlaying,
      currentAyah: currentAyah ?? this.currentAyah,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

/// Download State provider
@riverpod
class DownloadState extends _$DownloadState {
  @override
  Map<String, DownloadProgress> build() {
    return {};
  }

  void updateProgress(String id, DownloadProgress progress) {
    state = {...state, id: progress};
  }

  void remove(String id) {
    final newState = Map<String, DownloadProgress>.from(state);
    newState.remove(id);
    state = newState;
  }

  void clear() {
    state = {};
  }
}

@immutable
class DownloadProgress {
  final String id;
  final String title;
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
  final DownloadStatus status;

  const DownloadProgress({
    required this.id,
    required this.title,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.status = DownloadStatus.downloading,
  });

  DownloadProgress copyWith({
    String? id,
    String? title,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    DownloadStatus? status,
  }) {
    return DownloadProgress(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      status: status ?? this.status,
    );
  }
}

enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}