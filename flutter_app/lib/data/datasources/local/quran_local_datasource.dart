/// Local data source for Quran data using SharedPreferences (in-memory fallback)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/quran_models.dart';
import '../../../shared/models/settings_models.dart';

class QuranLocalDataSource {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // In-memory caches
  final List<Surah> _surahs = [];
  final List<Ayah> _ayahs = [];
  final List<Juz> _juzList = [];
  final List<TranslationInfo> _translations = [];
  final List<ReciterInfo> _reciters = [];
  final List<QuranBookmark> _bookmarks = [];
  final List<ReadingProgress> _readingProgress = [];
  final List<Tafsir> _tafsirList = [];

  Future<void> init() async {
    await _ensurePrefs();
  }

  // ============ SURAHS ============

  Future<void> saveSurahs(List<Surah> surahs) async {
    _surahs
      ..clear()
      ..addAll(surahs);
  }

  List<Surah> getAllSurahs() {
    return List.from(_surahs)..sort((a, b) => a.number.compareTo(b.number));
  }

  Surah? getSurah(int number) {
    try {
      return _surahs.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }

  List<Surah> getSurahsByJuz(int juzNumber) {
    return _surahs.where((s) => s.juzNumber == juzNumber).toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  // ============ AYAHS ============

  Future<void> saveAyahs(List<Ayah> ayahs) async {
    _ayahs
      ..clear()
      ..addAll(ayahs);
  }

  List<Ayah> getAllAyahs() {
    return List.from(_ayahs)..sort((a, b) => a.number.compareTo(b.number));
  }

  Ayah? getAyah(int globalNumber) {
    try {
      return _ayahs.firstWhere((a) => a.number == globalNumber);
    } catch (_) {
      return null;
    }
  }

  Ayah? getAyahBySurahAndAyah(int surahNumber, int ayahInSurah) {
    try {
      return _ayahs.firstWhere(
        (a) => a.surahNumber == surahNumber && a.ayahInSurah == ayahInSurah,
      );
    } catch (_) {
      return null;
    }
  }

  List<Ayah> getAyahsBySurah(int surahNumber) {
    return _ayahs.where((a) => a.surahNumber == surahNumber).toList()
      ..sort((a, b) => a.ayahInSurah.compareTo(b.ayahInSurah));
  }

  List<Ayah> getAyahsByJuz(int juzNumber) {
    return _ayahs.where((a) => a.juzNumber == juzNumber).toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  List<Ayah> getAyahsByPage(int pageNumber) {
    return _ayahs.where((a) => a.pageNumber == pageNumber).toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  List<Ayah> searchAyahs(String query, {String? translationId}) {
    final lowerQuery = query.toLowerCase();
    return _ayahs.where((ayah) {
      if (translationId != null) {
        final translation = ayah.getTranslation(translationId).toLowerCase();
        return translation.contains(lowerQuery);
      }
      return ayah.textArabic.contains(query) ||
          ayah.textSimple.contains(query) ||
          ayah.translations.values
              .any((t) => t.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // ============ JUZ ============

  Future<void> saveJuzList(List<Juz> juzList) async {
    _juzList
      ..clear()
      ..addAll(juzList);
  }

  List<Juz> getAllJuz() {
    return List.from(_juzList)..sort((a, b) => a.number.compareTo(b.number));
  }

  Juz? getJuz(int number) {
    try {
      return _juzList.firstWhere((j) => j.number == number);
    } catch (_) {
      return null;
    }
  }

  // ============ TRANSLATIONS ============

  Future<void> saveTranslations(List<TranslationInfo> translations) async {
    _translations
      ..clear()
      ..addAll(translations);
  }

  List<TranslationInfo> getAllTranslations() => List.from(_translations);

  TranslationInfo? getTranslation(String id) {
    try {
      return _translations.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateTranslationDownloadStatus(
    String id,
    bool downloaded, {
    String? localPath,
  }) async {
    final index = _translations.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final old = _translations[index];
      _translations[index] = TranslationInfo(
        id: old.id,
        name: old.name,
        language: old.language,
        languageName: old.languageName,
        author: old.author,
        description: old.description,
        year: old.year,
        isDownloaded: downloaded,
        localPath: localPath ?? old.localPath,
      );
    }
  }

  // ============ RECITERS ============

  Future<void> saveReciters(List<ReciterInfo> reciters) async {
    _reciters
      ..clear()
      ..addAll(reciters);
  }

  List<ReciterInfo> getAllReciters() => List.from(_reciters);

  ReciterInfo? getReciter(String id) {
    try {
      return _reciters.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateReciterDownloadStatus(
    String id,
    bool downloaded, {
    String? localPath,
    int? totalSize,
  }) async {
    final index = _reciters.indexWhere((r) => r.id == id);
    if (index >= 0) {
      final old = _reciters[index];
      _reciters[index] = ReciterInfo(
        id: old.id,
        name: old.name,
        nameArabic: old.nameArabic,
        style: old.style,
        country: old.country,
        isDownloaded: downloaded,
        localPath: localPath ?? old.localPath,
        totalSize: totalSize ?? old.totalSize,
      );
    }
  }

  // ============ BOOKMARKS ============

  Future<void> addBookmark(QuranBookmark bookmark) async {
    _bookmarks.removeWhere((b) => b.id == bookmark.id);
    _bookmarks.add(bookmark);
  }

  Future<void> removeBookmark(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
  }

  List<QuranBookmark> getAllBookmarks() {
    return List.from(_bookmarks)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  QuranBookmark? getBookmarkForAyah(int surahNumber, int ayahNumber) {
    try {
      return _bookmarks.firstWhere(
        (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
      );
    } catch (_) {
      return null;
    }
  }

  // ============ READING PROGRESS ============

  Future<void> saveReadingProgress(ReadingProgress progress) async {
    _readingProgress.removeWhere(
      (p) =>
          p.surahNumber == progress.surahNumber &&
          p.ayahNumber == progress.ayahNumber,
    );
    _readingProgress.add(progress);
  }

  ReadingProgress? getReadingProgress(int surahNumber, int ayahNumber) {
    try {
      return _readingProgress.firstWhere(
        (p) => p.surahNumber == surahNumber && p.ayahNumber == ayahNumber,
      );
    } catch (_) {
      return null;
    }
  }

  List<ReadingProgress> getAllReadingProgress() {
    return List.from(_readingProgress)
      ..sort((a, b) => b.lastRead.compareTo(a.lastRead));
  }

  // ============ TAFSIR ============

  Future<void> saveTafsirList(List<Tafsir> tafsirList) async {
    _tafsirList.addAll(tafsirList);
  }

  List<Tafsir> getTafsirForAyah(int surahNumber, int ayahNumber) {
    return _tafsirList
        .where(
            (t) => t.surahNumber == surahNumber && t.ayahNumber == ayahNumber)
        .toList();
  }

  // ============ SETTINGS ============

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await _ensurePrefs();
    await prefs.setString('theme_mode', settings.themeMode.name);
    await prefs.setString('language', settings.language.name);
    await prefs.setString('translation_id', settings.selectedTranslationId);
  }

  Future<AppSettings> getSettings() async {
    final prefs = await _ensurePrefs();
    final themeName = prefs.getString('theme_mode');
    final langName = prefs.getString('language');
    final translationId = prefs.getString('translation_id') ?? 'en.sahih';

    ThemeMode themeMode = ThemeMode.system;
    if (themeName == 'light') themeMode = ThemeMode.light;
    if (themeName == 'dark') themeMode = ThemeMode.dark;

    AppLanguage language = AppLanguage.english;
    if (langName != null) {
      try {
        language = AppLanguage.values.firstWhere((l) => l.name == langName);
      } catch (_) {}
    }

    return AppSettings(
      themeMode: themeMode,
      language: language,
      selectedTranslationId: translationId,
    );
  }

  // ============ UTILITY ============

  Future<void> clearAllData() async {
    _surahs.clear();
    _ayahs.clear();
    _juzList.clear();
    _translations.clear();
    _reciters.clear();
    _bookmarks.clear();
    _readingProgress.clear();
    _tafsirList.clear();
  }

  Future<void> close() async {
    // Nothing to close for in-memory storage
  }
}
