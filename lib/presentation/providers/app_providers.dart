/// Riverpod providers for the Quran & Hadith App

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Export HadithBookDetail from remote datasource for provider usage
export '../../data/datasources/remote/hadith_remote_datasource.dart'
    show HadithBookDetail;

/// Dio provider
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));
});

/// Quran Local DataSource provider
final quranLocalDataSourceProvider = Provider<QuranLocalDataSource>((ref) {
  return QuranLocalDataSource();
});

/// Hadith Local DataSource provider
final hadithLocalDataSourceProvider = Provider<HadithLocalDataSource>((ref) {
  return HadithLocalDataSource();
});

/// Quran Remote DataSource provider
final quranRemoteDataSourceProvider = Provider<QuranRemoteDataSource>((ref) {
  return QuranRemoteDataSource();
});

/// Hadith Remote DataSource provider
final hadithRemoteDataSourceProvider = Provider<HadithRemoteDataSource>((ref) {
  return HadithRemoteDataSource();
});

/// Quran Repository provider
final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository(
    localDataSource: ref.watch(quranLocalDataSourceProvider),
    remoteDataSource: ref.watch(quranRemoteDataSourceProvider),
  );
});

/// Hadith Repository provider
final hadithRepositoryProvider = Provider<HadithRepository>((ref) {
  return HadithRepository(
    localDataSource: ref.watch(hadithLocalDataSourceProvider),
    remoteDataSource: ref.watch(hadithRemoteDataSourceProvider),
  );
});

/// Initialize repositories provider
final initializeRepositoriesProvider = FutureProvider<void>((ref) async {
  await ref.watch(quranRepositoryProvider).init();
  await ref.watch(hadithRepositoryProvider).init();
});

/// Settings notifier
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repository = ref.watch(quranRepositoryProvider);
    return await repository.getSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = const AsyncLoading();
    final repository = ref.read(quranRepositoryProvider);
    await repository.saveSettings(settings);
    state = AsyncData(settings);
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
    await updateSettings(
        current.copyWith(selectedTranslationId: translationId));
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

  // Compatibility aliases
  Future<void> updateNotificationSettings(
      NotificationSettings notifications) async {
    await updateNotifications(notifications);
  }

  Future<void> updatePrivacySettings(PrivacySettings privacy) async {
    await updatePrivacy(privacy);
  }

  Future<void> updateAnimationsEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(animationsEnabled: enabled));
  }

  Future<void> updateFontScale(double scale) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(fontScale: scale));
  }

  Future<void> resetToDefaults() async {
    await updateSettings(const AppSettings());
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

/// Quran Surahs notifier
class SurahsNotifier extends AsyncNotifier<List<Surah>> {
  @override
  Future<List<Surah>> build() async {
    return await ref.watch(quranRepositoryProvider).getAllSurahs();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(quranRepositoryProvider).getAllSurahs(forceRefresh: true),
    );
  }
}

final surahsProvider = AsyncNotifierProvider<SurahsNotifier, List<Surah>>(
  SurahsNotifier.new,
);

/// Selected Surah provider (family)
final selectedSurahProvider =
    FutureProvider.family<Surah?, int>((ref, surahNumber) async {
  return await ref.watch(quranRepositoryProvider).getSurah(surahNumber);
});

/// Surah Ayahs notifier (family)
class SurahAyahsNotifier extends FamilyAsyncNotifier<List<Ayah>, int> {
  @override
  Future<List<Ayah>> build(int surahNumber) async {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final translationId =
        settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
    return await ref
        .watch(quranRepositoryProvider)
        .getAyahsBySurah(surahNumber, translationId: translationId);
  }

  Future<void> refresh(int surahNumber) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = ref.read(settingsProvider).valueOrNull;
      final translationId =
          settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
      return ref.read(quranRepositoryProvider).getAyahsBySurah(surahNumber,
          translationId: translationId, forceRefresh: true);
    });
  }
}

final surahAyahsProvider =
    AsyncNotifierProvider.family<SurahAyahsNotifier, List<Ayah>, int>(
  SurahAyahsNotifier.new,
);

/// Single Ayah provider (family with surah and ayah number)
final ayahProvider =
    FutureProvider.family<Ayah?, (int, int)>((ref, args) async {
  final (surahNumber, ayahNumber) = args;
  final settings = ref.watch(settingsProvider).valueOrNull;
  final translationId =
      settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
  return await ref
      .watch(quranRepositoryProvider)
      .getAyah(surahNumber, ayahNumber, translationId: translationId);
});

/// Juz provider
final juzProvider = FutureProvider<List<Juz>>((ref) async {
  return await ref.watch(quranRepositoryProvider).getAllJuz();
});

/// Juz Ayahs provider (family)
final juzAyahsProvider =
    FutureProvider.family<List<Ayah>, int>((ref, juzNumber) async {
  final settings = ref.watch(settingsProvider).valueOrNull;
  final translationId =
      settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
  return await ref
      .watch(quranRepositoryProvider)
      .getAyahsByJuz(juzNumber, translationId: translationId);
});

/// Page Ayahs provider (family)
final pageAyahsProvider =
    FutureProvider.family<List<Ayah>, int>((ref, pageNumber) async {
  final settings = ref.watch(settingsProvider).valueOrNull;
  final translationId =
      settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
  return await ref
      .watch(quranRepositoryProvider)
      .getAyahsByPage(pageNumber, translationId: translationId);
});

/// Translations provider
final translationsProvider = FutureProvider<List<TranslationInfo>>((ref) async {
  return await ref.watch(quranRepositoryProvider).getAllTranslations();
});

/// Reciters provider
final recitersProvider = FutureProvider<List<ReciterInfo>>((ref) async {
  return await ref.watch(quranRepositoryProvider).getAllReciters();
});

/// Quran Bookmarks notifier
class QuranBookmarksNotifier extends AsyncNotifier<List<QuranBookmark>> {
  @override
  Future<List<QuranBookmark>> build() async {
    return await ref.watch(quranRepositoryProvider).getAllBookmarks();
  }

  Future<void> add(QuranBookmark bookmark) async {
    await ref.read(quranRepositoryProvider).addBookmark(bookmark);
    await refresh();
  }

  Future<void> remove(String id) async {
    await ref.read(quranRepositoryProvider).removeBookmark(id);
    await refresh();
  }

  Future<void> removeBookmark(String id) async {
    await remove(id);
  }

  Future<void> clearAll() async {
    state = const AsyncLoading();
    // Clear from local storage by getting all and removing individually
    final bookmarks = await ref.read(quranRepositoryProvider).getAllBookmarks();
    for (final bookmark in bookmarks) {
      await ref.read(quranRepositoryProvider).removeBookmark(bookmark.id);
    }
    state = const AsyncData([]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(quranRepositoryProvider).getAllBookmarks(),
    );
  }
}

final quranBookmarksProvider =
    AsyncNotifierProvider<QuranBookmarksNotifier, List<QuranBookmark>>(
  QuranBookmarksNotifier.new,
);

/// Reading Progress notifier
class ReadingProgressNotifier extends AsyncNotifier<List<ReadingProgress>> {
  @override
  Future<List<ReadingProgress>> build() async {
    return await ref.watch(quranRepositoryProvider).getAllReadingProgress();
  }

  Future<void> save(ReadingProgress progress) async {
    await ref.read(quranRepositoryProvider).saveReadingProgress(progress);
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(quranRepositoryProvider).getAllReadingProgress(),
    );
  }
}

final readingProgressProvider =
    AsyncNotifierProvider<ReadingProgressNotifier, List<ReadingProgress>>(
  ReadingProgressNotifier.new,
);

/// Tafsir provider (family)
final tafsirProvider =
    FutureProvider.family<List<Tafsir>, (int, int)>((ref, args) async {
  final (surahNumber, ayahNumber) = args;
  return await ref
      .watch(quranRepositoryProvider)
      .getTafsirForAyah(surahNumber, ayahNumber);
});

/// Quran Search provider (family)
final quranSearchProvider =
    FutureProvider.family<List<QuranSearchResult>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final settings = ref.watch(settingsProvider).valueOrNull;
  final translationId =
      settings?.selectedTranslationId ?? AppConstants.defaultTranslation;
  return await ref
      .watch(quranRepositoryProvider)
      .search(query: query, translationId: translationId);
});

/// Hadith Collections notifier
class HadithCollectionsNotifier extends AsyncNotifier<List<HadithCollection>> {
  @override
  Future<List<HadithCollection>> build() async {
    return await ref.watch(hadithRepositoryProvider).getAllCollections();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(hadithRepositoryProvider)
          .getAllCollections(forceRefresh: true),
    );
  }
}

final hadithCollectionsProvider =
    AsyncNotifierProvider<HadithCollectionsNotifier, List<HadithCollection>>(
  HadithCollectionsNotifier.new,
);

/// Collection Detail provider (family)
final hadithCollectionDetailProvider =
    FutureProvider.family<HadithCollectionDetail, String>(
        (ref, collectionId) async {
  return await ref
      .watch(hadithRepositoryProvider)
      .getCollectionDetail(collectionId);
});

/// Books provider (family)
final hadithBooksProvider =
    FutureProvider.family<List<HadithBook>, String>((ref, collectionId) async {
  return await ref
      .watch(hadithRepositoryProvider)
      .getBooksByCollection(collectionId);
});

/// Chapters provider (family)
final hadithChaptersProvider =
    FutureProvider.family<List<HadithChapter>, String>((ref, bookId) async {
  return await ref.watch(hadithRepositoryProvider).getChaptersByBook(bookId);
});

/// Hadiths by Book provider
typedef HadithsByBookArgs = ({String collectionId, int bookNumber, int page});

final hadithsByBookProvider =
    FutureProvider.family<HadithBookDetail, HadithsByBookArgs>(
        (ref, args) async {
  return await ref.watch(hadithRepositoryProvider).getHadithsByBook(
        args.collectionId,
        args.bookNumber,
        page: args.page,
      );
});

/// Hadiths by Chapter provider (family)
final hadithsByChapterProvider =
    FutureProvider.family<List<Hadith>, String>((ref, chapterId) async {
  return await ref
      .watch(hadithRepositoryProvider)
      .getHadithsByChapter(chapterId);
});

/// Single Hadith provider (family)
final hadithDetailProvider =
    FutureProvider.family<Hadith?, (String, int)>((ref, args) async {
  final (collectionId, hadithNumber) = args;
  return await ref
      .watch(hadithRepositoryProvider)
      .getHadith(collectionId, hadithNumber);
});

/// Favorite Hadiths notifier
class FavoriteHadithsNotifier extends AsyncNotifier<List<Hadith>> {
  @override
  Future<List<Hadith>> build() async {
    return await ref.watch(hadithRepositoryProvider).getFavoriteHadiths();
  }

  Future<void> toggle(String hadithId, bool isFavorite) async {
    await ref
        .read(hadithRepositoryProvider)
        .toggleFavorite(hadithId, isFavorite);
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(hadithRepositoryProvider).getFavoriteHadiths(),
    );
  }
}

final favoriteHadithsProvider =
    AsyncNotifierProvider<FavoriteHadithsNotifier, List<Hadith>>(
  FavoriteHadithsNotifier.new,
);

/// Hadith Search provider (family)
final hadithSearchProvider =
    FutureProvider.family<List<Hadith>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final settings = ref.watch(settingsProvider).valueOrNull;
  final languageCode = settings?.language.code ?? 'en';
  return await ref
      .watch(hadithRepositoryProvider)
      .search(query: query, languageCode: languageCode);
});

/// Narrators provider
final narratorsProvider = FutureProvider<List<Narrator>>((ref) async {
  return await ref.watch(hadithRepositoryProvider).getAllNarrators();
});

/// Topics provider
final hadithTopicsProvider = FutureProvider<List<HadithTopic>>((ref) async {
  return await ref.watch(hadithRepositoryProvider).getAllTopics();
});

/// Top Level Topics provider
final topLevelHadithTopicsProvider =
    FutureProvider<List<HadithTopic>>((ref) async {
  return await ref.watch(hadithRepositoryProvider).getTopLevelTopics();
});

/// Hadith Topic provider (family)
final hadithTopicProvider =
    FutureProvider.family<HadithTopic, String>((ref, topicId) async {
  return await ref.watch(hadithRepositoryProvider).getHadithTopic(topicId);
});

/// Related Topics provider (family)
final relatedTopicsProvider =
    FutureProvider.family<List<HadithTopic>, String>((ref, topicId) async {
  return await ref.watch(hadithRepositoryProvider).getRelatedTopics(topicId);
});

/// Child Topics provider (family)
final childHadithTopicsProvider =
    FutureProvider.family<List<HadithTopic>, String>((ref, parentId) async {
  return await ref.watch(hadithRepositoryProvider).getChildTopics(parentId);
});

/// Hadith Bookmarks notifier
class HadithBookmarksNotifier extends AsyncNotifier<List<HadithBookmark>> {
  @override
  Future<List<HadithBookmark>> build() async {
    return await ref.watch(hadithRepositoryProvider).getAllBookmarks();
  }

  Future<void> add(HadithBookmark bookmark) async {
    await ref.read(hadithRepositoryProvider).addBookmark(bookmark);
    await refresh();
  }

  Future<void> addBookmark(HadithBookmark bookmark) async {
    await add(bookmark);
  }

  Future<void> remove(String id) async {
    await ref.read(hadithRepositoryProvider).removeBookmark(id);
    await refresh();
  }

  Future<void> removeBookmark(String id) async {
    await remove(id);
  }

  Future<void> clearAll() async {
    state = const AsyncLoading();
    final bookmarks =
        await ref.read(hadithRepositoryProvider).getAllBookmarks();
    for (final bookmark in bookmarks) {
      await ref.read(hadithRepositoryProvider).removeBookmark(bookmark.id);
    }
    state = const AsyncData([]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(hadithRepositoryProvider).getAllBookmarks(),
    );
  }
}

final hadithBookmarksProvider =
    AsyncNotifierProvider<HadithBookmarksNotifier, List<HadithBookmark>>(
  HadithBookmarksNotifier.new,
);

/// Hadiths by Topic provider (family)
final hadithsByTopicProvider =
    FutureProvider.family<List<Hadith>, String>((ref, topicId) async {
  return await ref.watch(hadithRepositoryProvider).getHadithsByTopic(topicId);
});

/// Narrators for specific hadith IDs (family)
final hadithNarratorsProvider =
    FutureProvider.family<List<Narrator>, List<String>>(
        (ref, narratorIds) async {
  if (narratorIds.isEmpty) return [];
  return await ref
      .watch(hadithRepositoryProvider)
      .getNarratorsByIds(narratorIds);
});

/// Related hadiths provider
typedef RelatedHadithsArgs = ({
  String collectionId,
  int hadithNumber,
  int limit
});

final relatedHadithsProvider =
    FutureProvider.family<List<Hadith>, RelatedHadithsArgs>((ref, args) async {
  return await ref.watch(hadithRepositoryProvider).getRelatedHadiths(
        collectionId: args.collectionId,
        hadithNumber: args.hadithNumber,
        limit: args.limit,
      );
});

/// Random Hadith notifier
class RandomHadithNotifier extends AsyncNotifier<Hadith?> {
  @override
  Future<Hadith?> build() async {
    return await ref.watch(hadithRepositoryProvider).getRandomHadith();
  }

  Future<void> refresh({String? collectionId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(hadithRepositoryProvider)
          .getRandomHadith(collectionId: collectionId),
    );
  }
}

final randomHadithProvider =
    AsyncNotifierProvider<RandomHadithNotifier, Hadith?>(
  RandomHadithNotifier.new,
);

/// Audio Player State data class
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

/// Audio Player State notifier
class AudioPlayerStateNotifier extends Notifier<AudioPlayerStateData> {
  @override
  AudioPlayerStateData build() => const AudioPlayerStateData();

  void setPlaying(bool playing) => state = state.copyWith(isPlaying: playing);
  void setCurrentAyah(Ayah? ayah) => state = state.copyWith(currentAyah: ayah);
  void setPlaylist(List<Ayah> playlist) =>
      state = state.copyWith(playlist: playlist, currentIndex: 0);
  void setCurrentIndex(int index) =>
      state = state.copyWith(currentIndex: index);
  void setRepeatMode(AudioRepeatMode mode) =>
      state = state.copyWith(repeatMode: mode);
  void setPlaybackSpeed(PlaybackSpeed speed) =>
      state = state.copyWith(playbackSpeed: speed);

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

/// Juzs provider
final juzsProvider = FutureProvider<List<Juz>>((ref) async {
  return await ref.watch(quranRepositoryProvider).getAllJuz();
});

final audioPlayerStateProvider =
    NotifierProvider<AudioPlayerStateNotifier, AudioPlayerStateData>(
  AudioPlayerStateNotifier.new,
);

/// Download Progress data class
@immutable
class DownloadProgress {
  final String id;
  final String title;
  final double progress;
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

/// Download State notifier
class DownloadStateNotifier extends Notifier<Map<String, DownloadProgress>> {
  @override
  Map<String, DownloadProgress> build() => {};

  void updateProgress(String id, DownloadProgress progress) {
    state = {...state, id: progress};
  }

  void remove(String id) {
    final newState = Map<String, DownloadProgress>.from(state);
    newState.remove(id);
    state = newState;
  }

  void clear() => state = {};
}

final downloadStateProvider =
    NotifierProvider<DownloadStateNotifier, Map<String, DownloadProgress>>(
  DownloadStateNotifier.new,
);
