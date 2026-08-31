/// Local data source for Quran data using Hive

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../shared/models/quran_models.dart';
import '../../../shared/models/settings_models.dart';

class QuranLocalDataSource {
  // Box names
  static const String _surahsBox = 'surahs';
  static const String _ayahsBox = 'ayahs';
  static const String _juzBox = 'juz';
  static const String _hizbBox = 'hizb';
  static const String _rubBox = 'rub';
  static const String _translationsBox = 'translations';
  static const String _recitersBox = 'reciters';
  static const String _bookmarksBox = 'quran_bookmarks';
  static const String _readingProgressBox = 'reading_progress';
  static const String _tafsirBox = 'tafsir';
  static const String _settingsBox = 'app_settings';

  // Boxes
  late Box<Surah> _surahsBoxInstance;
  late Box<Ayah> _ayahsBoxInstance;
  late Box<Juz> _juzBoxInstance;
  late Box<Hizb> _hizbBoxInstance;
  late Box<Rub> _rubBoxInstance;
  late Box<TranslationInfo> _translationsBoxInstance;
  late Box<ReciterInfo> _recitersBoxInstance;
  late Box<QuranBookmark> _bookmarksBoxInstance;
  late Box<ReadingProgress> _readingProgressBoxInstance;
  late Box<Tafsir> _tafsirBoxInstance;
  late Box<AppSettings> _settingsBoxInstance;

  /// Initialize all boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SurahAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(RevelationTypeAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(AyahAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SajdahTypeAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(JuzAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(HizbAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(RubAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(TranslationInfoAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(ReciterInfoAdapter());
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(RecitationStyleAdapter());
    if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(QuranBookmarkAdapter());
    if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(BookmarkColorAdapter());
    if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(ReadingProgressAdapter());
    if (!Hive.isAdapterRegistered(13)) Hive.registerAdapter(TafsirAdapter());
    if (!Hive.isAdapterRegistered(40)) Hive.registerAdapter(ThemeModeAdapter());
    if (!Hive.isAdapterRegistered(41)) Hive.registerAdapter(AppLanguageAdapter());
    if (!Hive.isAdapterRegistered(42)) Hive.registerAdapter(QuranFontFamilyAdapter());
    if (!Hive.isAdapterRegistered(43)) Hive.registerAdapter(AudioRepeatModeAdapter());
    if (!Hive.isAdapterRegistered(44)) Hive.registerAdapter(PlaybackSpeedAdapter());
    if (!Hive.isAdapterRegistered(45)) Hive.registerAdapter(QuranDisplaySettingsAdapter());
    if (!Hive.isAdapterRegistered(46)) Hive.registerAdapter(AudioSettingsAdapter());
    if (!Hive.isAdapterRegistered(47)) Hive.registerAdapter(HadithDisplaySettingsAdapter());
    if (!Hive.isAdapterRegistered(48)) Hive.registerAdapter(NotificationSettingsAdapter());
    if (!Hive.isAdapterRegistered(49)) Hive.registerAdapter(TimeOfDayAdapter());
    if (!Hive.isAdapterRegistered(50)) Hive.registerAdapter(PrivacySettingsAdapter());
    if (!Hive.isAdapterRegistered(51)) Hive.registerAdapter(AppSettingsAdapter());

    // Open boxes
    _surahsBoxInstance = await Hive.openBox<Surah>(_surahsBox);
    _ayahsBoxInstance = await Hive.openBox<Ayah>(_ayahsBox);
    _juzBoxInstance = await Hive.openBox<Juz>(_juzBox);
    _hizbBoxInstance = await Hive.openBox<Hizb>(_hizbBox);
    _rubBoxInstance = await Hive.openBox<Rub>(_rubBox);
    _translationsBoxInstance = await Hive.openBox<TranslationInfo>(_translationsBox);
    _recitersBoxInstance = await Hive.openBox<ReciterInfo>(_recitersBox);
    _bookmarksBoxInstance = await Hive.openBox<QuranBookmark>(_bookmarksBox);
    _readingProgressBoxInstance = await Hive.openBox<ReadingProgress>(_readingProgressBox);
    _tafsirBoxInstance = await Hive.openBox<Tafsir>(_tafsirBox);
    _settingsBoxInstance = await Hive.openBox<AppSettings>(_settingsBox);
  }

  // ============ SURAHS ============

  Future<void> saveSurahs(List<Surah> surahs) async {
    await _surahsBoxInstance.clear();
    final map = {for (var surah in surahs) surah.number: surah};
    await _surahsBoxInstance.putAll(map);
  }

  List<Surah> getAllSurahs() {
    return _surahsBoxInstance.values.toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  Surah? getSurah(int number) {
    return _surahsBoxInstance.get(number);
  }

  List<Surah> getSurahsByJuz(int juzNumber) {
    return _surahsBoxInstance.values
        .where((s) => s.juzNumber == juzNumber)
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  // ============ AYAHS ============

  Future<void> saveAyahs(List<Ayah> ayahs) async {
    await _ayahsBoxInstance.clear();
    final map = {for (var ayah in ayahs) ayah.number: ayah};
    await _ayahsBoxInstance.putAll(map);
  }

  List<Ayah> getAllAyahs() {
    return _ayahsBoxInstance.values.toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  Ayah? getAyah(int globalNumber) {
    return _ayahsBoxInstance.get(globalNumber);
  }

  Ayah? getAyahBySurahAndAyah(int surahNumber, int ayahInSurah) {
    try {
      return _ayahsBoxInstance.values.firstWhere(
        (a) => a.surahNumber == surahNumber && a.ayahInSurah == ayahInSurah,
      );
    } catch (_) {
      return null;
    }
  }

  List<Ayah> getAyahsBySurah(int surahNumber) {
    return _ayahsBoxInstance.values
        .where((a) => a.surahNumber == surahNumber)
        .toList()
      ..sort((a, b) => a.ayahInSurah.compareTo(b.ayahInSurah));
  }

  List<Ayah> getAyahsByJuz(int juzNumber) {
    return _ayahsBoxInstance.values
        .where((a) => a.juzNumber == juzNumber)
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  List<Ayah> getAyahsByPage(int pageNumber) {
    return _ayahsBoxInstance.values
        .where((a) => a.pageNumber == pageNumber)
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  List<Ayah> searchAyahs(String query, {String? translationId}) {
    final lowerQuery = query.toLowerCase();
    return _ayahsBoxInstance.values.where((ayah) {
      if (translationId != null) {
        final translation = ayah.getTranslation(translationId).toLowerCase();
        return translation.contains(lowerQuery);
      }
      return ayah.textArabic.contains(query) ||
          ayah.textSimple.contains(query) ||
          ayah.translations.values.any((t) => t.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // ============ JUZ ============

  Future<void> saveJuzList(List<Juz> juzList) async {
    await _juzBoxInstance.clear();
    final map = {for (var juz in juzList) juz.number: juz};
    await _juzBoxInstance.putAll(map);
  }

  List<Juz> getAllJuz() {
    return _juzBoxInstance.values.toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  Juz? getJuz(int number) {
    return _juzBoxInstance.get(number);
  }

  // ============ HIZB ============

  Future<void> saveHizbList(List<Hizb> hizbList) async {
    await _hizbBoxInstance.clear();
    final map = {for (var hizb in hizbList) hizb.number: hizb};
    await _hizbBoxInstance.putAll(map);
  }

  List<Hizb> getAllHizb() {
    return _hizbBoxInstance.values.toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  // ============ RUB ============

  Future<void> saveRubList(List<Rub> rubList) async {
    await _rubBoxInstance.clear();
    final map = {for (var rub in rubList) rub.number: rub};
    await _rubBoxInstance.putAll(map);
  }

  List<Rub> getAllRub() {
    return _rubBoxInstance.values.toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  // ============ TRANSLATIONS ============

  Future<void> saveTranslations(List<TranslationInfo> translations) async {
    await _translationsBoxInstance.clear();
    final map = {for (var t in translations) t.id: t};
    await _translationsBoxInstance.putAll(map);
  }

  List<TranslationInfo> getAllTranslations() {
    return _translationsBoxInstance.values.toList();
  }

  TranslationInfo? getTranslation(String id) {
    return _translationsBoxInstance.get(id);
  }

  Future<void> updateTranslationDownloadStatus(String id, bool downloaded, {String? localPath}) async {
    final translation = _translationsBoxInstance.get(id);
    if (translation != null) {
      await _translationsBoxInstance.put(
        id,
        TranslationInfo(
          id: translation.id,
          name: translation.name,
          language: translation.language,
          languageName: translation.languageName,
          author: translation.author,
          description: translation.description,
          year: translation.year,
          isDownloaded: downloaded,
          localPath: localPath ?? translation.localPath,
        ),
      );
    }
  }

  // ============ RECITERS ============

  Future<void> saveReciters(List<ReciterInfo> reciters) async {
    await _recitersBoxInstance.clear();
    final map = {for (var r in reciters) r.id: r};
    await _recitersBoxInstance.putAll(map);
  }

  List<ReciterInfo> getAllReciters() {
    return _recitersBoxInstance.values.toList();
  }

  ReciterInfo? getReciter(String id) {
    return _recitersBoxInstance.get(id);
  }

  Future<void> updateReciterDownloadStatus(String id, bool downloaded, {String? localPath, int? totalSize}) async {
    final reciter = _recitersBoxInstance.get(id);
    if (reciter != null) {
      await _recitersBoxInstance.put(
        id,
        ReciterInfo(
          id: reciter.id,
          name: reciter.name,
          nameArabic: reciter.nameArabic,
          style: reciter.style,
          country: reciter.country,
          isDownloaded: downloaded,
          localPath: localPath ?? reciter.localPath,
          totalSize: totalSize ?? reciter.totalSize,
        ),
      );
    }
  }

  // ============ BOOKMARKS ============

  Future<void> addBookmark(QuranBookmark bookmark) async {
    await _bookmarksBoxInstance.put(bookmark.id, bookmark);
  }

  Future<void> removeBookmark(String id) async {
    await _bookmarksBoxInstance.delete(id);
  }

  List<QuranBookmark> getAllBookmarks() {
    return _bookmarksBoxInstance.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  QuranBookmark? getBookmarkForAyah(int surahNumber, int ayahNumber) {
    try {
      return _bookmarksBoxInstance.values.firstWhere(
        (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
      );
    } catch (_) {
      return null;
    }
  }

  // ============ READING PROGRESS ============

  Future<void> saveReadingProgress(ReadingProgress progress) async {
    final key = '${progress.surahNumber}:${progress.ayahNumber}';
    await _readingProgressBoxInstance.put(key, progress);
  }

  ReadingProgress? getReadingProgress(int surahNumber, int ayahNumber) {
    final key = '$surahNumber:$ayahNumber';
    return _readingProgressBoxInstance.get(key);
  }

  List<ReadingProgress> getAllReadingProgress() {
    return _readingProgressBoxInstance.values.toList()
      ..sort((a, b) => b.lastRead.compareTo(a.lastRead));
  }

  // ============ TAFSIR ============

  Future<void> saveTafsirList(List<Tafsir> tafsirList) async {
    await _tafsirBoxInstance.clear();
    final map = {for (var t in tafsirList) t.id: t};
    await _tafsirBoxInstance.putAll(map);
  }

  List<Tafsir> getTafsirForAyah(int surahNumber, int ayahNumber) {
    return _tafsirBoxInstance.values
        .where((t) => t.surahNumber == surahNumber && t.ayahNumber == ayahNumber)
        .toList();
  }

  // ============ SETTINGS ============

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBoxInstance.put('settings', settings);
  }

  AppSettings getSettings() {
    return _settingsBoxInstance.get('settings') ?? const AppSettings();
  }

  // ============ UTILITY ============

  Future<void> clearAllData() async {
    await _surahsBoxInstance.clear();
    await _ayahsBoxInstance.clear();
    await _juzBoxInstance.clear();
    await _hizbBoxInstance.clear();
    await _rubBoxInstance.clear();
    await _translationsBoxInstance.clear();
    await _recitersBoxInstance.clear();
    await _bookmarksBoxInstance.clear();
    await _readingProgressBoxInstance.clear();
    await _tafsirBoxInstance.clear();
  }

  Future<void> close() async {
    await _surahsBoxInstance.close();
    await _ayahsBoxInstance.close();
    await _juzBoxInstance.close();
    await _hizbBoxInstance.close();
    await _rubBoxInstance.close();
    await _translationsBoxInstance.close();
    await _recitersBoxInstance.close();
    await _bookmarksBoxInstance.close();
    await _readingProgressBoxInstance.close();
    await _tafsirBoxInstance.close();
    await _settingsBoxInstance.close();
  }
}