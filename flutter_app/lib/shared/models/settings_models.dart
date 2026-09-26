/// Settings and user preference models

import 'package:flutter/material.dart';
import '../../shared/models/hadith_models.dart';

/// App language
enum AppLanguage {
  english,
  arabic,
  urdu,
  turkish,
  indonesian,
  malay,
  bengali,
  persian,
  french,
  german,
  russian,
  chinese,
  spanish,
  italian,
  dutch,
  portuguese,
  swahili,
  tamil,
  malayalam,
}

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.urdu:
        return 'ur';
      case AppLanguage.turkish:
        return 'tr';
      case AppLanguage.indonesian:
        return 'id';
      case AppLanguage.malay:
        return 'ms';
      case AppLanguage.bengali:
        return 'bn';
      case AppLanguage.persian:
        return 'fa';
      case AppLanguage.french:
        return 'fr';
      case AppLanguage.german:
        return 'de';
      case AppLanguage.russian:
        return 'ru';
      case AppLanguage.chinese:
        return 'zh';
      case AppLanguage.spanish:
        return 'es';
      case AppLanguage.italian:
        return 'it';
      case AppLanguage.dutch:
        return 'nl';
      case AppLanguage.portuguese:
        return 'pt';
      case AppLanguage.swahili:
        return 'sw';
      case AppLanguage.tamil:
        return 'ta';
      case AppLanguage.malayalam:
        return 'ml';
    }
  }

  String get nativeName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.arabic:
        return 'العربية';
      case AppLanguage.urdu:
        return 'اردو';
      case AppLanguage.turkish:
        return 'Türkçe';
      case AppLanguage.indonesian:
        return 'Bahasa Indonesia';
      case AppLanguage.malay:
        return 'Bahasa Melayu';
      case AppLanguage.bengali:
        return 'বাংলা';
      case AppLanguage.persian:
        return 'فارسی';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.german:
        return 'Deutsch';
      case AppLanguage.russian:
        return 'Русский';
      case AppLanguage.chinese:
        return '中文';
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.italian:
        return 'Italiano';
      case AppLanguage.dutch:
        return 'Nederlands';
      case AppLanguage.portuguese:
        return 'Português';
      case AppLanguage.swahili:
        return 'Kiswahili';
      case AppLanguage.tamil:
        return 'தமிழ்';
      case AppLanguage.malayalam:
        return 'മലയാളം';
    }
  }

  String get englishName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.arabic:
        return 'Arabic';
      case AppLanguage.urdu:
        return 'Urdu';
      case AppLanguage.turkish:
        return 'Turkish';
      case AppLanguage.indonesian:
        return 'Indonesian';
      case AppLanguage.malay:
        return 'Malay';
      case AppLanguage.bengali:
        return 'Bengali';
      case AppLanguage.persian:
        return 'Persian';
      case AppLanguage.french:
        return 'French';
      case AppLanguage.german:
        return 'German';
      case AppLanguage.russian:
        return 'Russian';
      case AppLanguage.chinese:
        return 'Chinese';
      case AppLanguage.spanish:
        return 'Spanish';
      case AppLanguage.italian:
        return 'Italian';
      case AppLanguage.dutch:
        return 'Dutch';
      case AppLanguage.portuguese:
        return 'Portuguese';
      case AppLanguage.swahili:
        return 'Swahili';
      case AppLanguage.tamil:
        return 'Tamil';
      case AppLanguage.malayalam:
        return 'Malayalam';
    }
  }

  bool get isRTL =>
      this == AppLanguage.arabic ||
      this == AppLanguage.urdu ||
      this == AppLanguage.persian;
}

/// Quran font family options
enum QuranFontFamily {
  uthmani,
  indopak,
  simple,
  amiri,
  notoNastaliq,
  scheherazade,
  latex,
}

/// Audio repeat mode
enum AudioRepeatMode {
  none,
  ayah,
  surah,
  all,
}

/// Audio playback speed
enum PlaybackSpeed {
  x0_5,
  x0_75,
  x1_0,
  x1_25,
  x1_5,
  x1_75,
  x2_0,
}

extension PlaybackSpeedExtension on PlaybackSpeed {
  double get value {
    switch (this) {
      case PlaybackSpeed.x0_5:
        return 0.5;
      case PlaybackSpeed.x0_75:
        return 0.75;
      case PlaybackSpeed.x1_0:
        return 1.0;
      case PlaybackSpeed.x1_25:
        return 1.25;
      case PlaybackSpeed.x1_5:
        return 1.5;
      case PlaybackSpeed.x1_75:
        return 1.75;
      case PlaybackSpeed.x2_0:
        return 2.0;
    }
  }

  String get label {
    switch (this) {
      case PlaybackSpeed.x0_5:
        return '0.5x';
      case PlaybackSpeed.x0_75:
        return '0.75x';
      case PlaybackSpeed.x1_0:
        return '1.0x';
      case PlaybackSpeed.x1_25:
        return '1.25x';
      case PlaybackSpeed.x1_5:
        return '1.5x';
      case PlaybackSpeed.x1_75:
        return '1.75x';
      case PlaybackSpeed.x2_0:
        return '2.0x';
    }
  }
}

/// Quran display options
class QuranDisplaySettings {
  final double fontSize;
  final double translationFontSize;
  final QuranFontFamily fontFamily;
  final bool showArabic;
  final bool showTranslation;
  final bool showTransliteration;
  final bool showAyahNumbers;
  final bool showJuzMarkers;
  final bool showHizbMarkers;
  final bool showSajdahMarkers;
  final bool showRukuMarkers;
  final bool showPageNumbers;
  final bool highlightCurrentAyah;
  final bool autoScrollToAyah;
  final double lineSpacing;
  final double wordSpacing;
  final bool nightMode;
  final bool showBismillah;
  final bool verseByVerse;
  final bool highlightTajweed;
  final String fontFamilyArabic;
  final double fontSizeArabic;
  final double fontSizeTranslation;

  const QuranDisplaySettings({
    this.fontSize = 18.0,
    this.translationFontSize = 14.0,
    this.fontFamily = QuranFontFamily.uthmani,
    this.showArabic = true,
    this.showTranslation = true,
    this.showTransliteration = false,
    this.showAyahNumbers = true,
    this.showJuzMarkers = true,
    this.showHizbMarkers = false,
    this.showSajdahMarkers = true,
    this.showRukuMarkers = false,
    this.showPageNumbers = true,
    this.highlightCurrentAyah = true,
    this.autoScrollToAyah = true,
    this.lineSpacing = 1.5,
    this.wordSpacing = 0.0,
    this.nightMode = false,
    this.showBismillah = true,
    this.verseByVerse = false,
    this.highlightTajweed = false,
    this.fontFamilyArabic = 'Uthmani',
    this.fontSizeArabic = 18.0,
    this.fontSizeTranslation = 14.0,
  });

  // Compatibility aliases
  bool get showVerseNumbers => showAyahNumbers;
  String get fontFamilyArabicCompat => fontFamilyArabic;
  double get fontSizeArabicCompat => fontSizeArabic;
  double get fontSizeTranslationCompat => fontSizeTranslation;

  QuranDisplaySettings copyWith({
    double? fontSize,
    double? translationFontSize,
    QuranFontFamily? fontFamily,
    bool? showArabic,
    bool? showTranslation,
    bool? showTransliteration,
    bool? showAyahNumbers,
    bool? showVerseNumbers,
    bool? showJuzMarkers,
    bool? showHizbMarkers,
    bool? showSajdahMarkers,
    bool? showRukuMarkers,
    bool? showPageNumbers,
    bool? highlightCurrentAyah,
    bool? autoScrollToAyah,
    double? lineSpacing,
    double? wordSpacing,
    bool? nightMode,
    bool? showBismillah,
    bool? verseByVerse,
    bool? highlightTajweed,
    String? fontFamilyArabic,
    double? fontSizeArabic,
    double? fontSizeTranslation,
  }) {
    return QuranDisplaySettings(
      fontSize: fontSize ?? this.fontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      showArabic: showArabic ?? this.showArabic,
      showTranslation: showTranslation ?? this.showTranslation,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showAyahNumbers:
          showAyahNumbers ?? showVerseNumbers ?? this.showAyahNumbers,
      showJuzMarkers: showJuzMarkers ?? this.showJuzMarkers,
      showHizbMarkers: showHizbMarkers ?? this.showHizbMarkers,
      showSajdahMarkers: showSajdahMarkers ?? this.showSajdahMarkers,
      showRukuMarkers: showRukuMarkers ?? this.showRukuMarkers,
      showPageNumbers: showPageNumbers ?? this.showPageNumbers,
      highlightCurrentAyah: highlightCurrentAyah ?? this.highlightCurrentAyah,
      autoScrollToAyah: autoScrollToAyah ?? this.autoScrollToAyah,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      nightMode: nightMode ?? this.nightMode,
      showBismillah: showBismillah ?? this.showBismillah,
      verseByVerse: verseByVerse ?? this.verseByVerse,
      highlightTajweed: highlightTajweed ?? this.highlightTajweed,
      fontFamilyArabic: fontFamilyArabic ?? this.fontFamilyArabic,
      fontSizeArabic: fontSizeArabic ?? this.fontSizeArabic,
      fontSizeTranslation: fontSizeTranslation ?? this.translationFontSize,
    );
  }
}

/// Audio settings
class AudioSettings {
  final String selectedReciterId;
  final AudioRepeatMode repeatMode;
  final PlaybackSpeed playbackSpeed;
  final bool autoPlayNext;
  final bool backgroundPlayback;
  final bool downloadOnWifiOnly;
  final bool showNotification;
  final bool lockScreenControls;
  final double volume;
  final int skipSilenceThreshold; // milliseconds
  final bool gaplessPlayback;
  final bool rememberPosition;

  const AudioSettings({
    this.selectedReciterId = 'ar.alafasy',
    this.repeatMode = AudioRepeatMode.none,
    this.playbackSpeed = PlaybackSpeed.x1_0,
    this.autoPlayNext = true,
    this.backgroundPlayback = true,
    this.downloadOnWifiOnly = true,
    this.showNotification = true,
    this.lockScreenControls = true,
    this.volume = 1.0,
    this.skipSilenceThreshold = 500,
    this.gaplessPlayback = true,
    this.rememberPosition = true,
  });

  AudioSettings copyWith({
    String? selectedReciterId,
    AudioRepeatMode? repeatMode,
    PlaybackSpeed? playbackSpeed,
    bool? autoPlayNext,
    bool? backgroundPlayback,
    bool? downloadOnWifiOnly,
    bool? showNotification,
    bool? lockScreenControls,
    double? volume,
    int? skipSilenceThreshold,
    bool? gaplessPlayback,
    bool? rememberPosition,
  }) {
    return AudioSettings(
      selectedReciterId: selectedReciterId ?? this.selectedReciterId,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      autoPlayNext: autoPlayNext ?? this.autoPlayNext,
      backgroundPlayback: backgroundPlayback ?? this.backgroundPlayback,
      downloadOnWifiOnly: downloadOnWifiOnly ?? this.downloadOnWifiOnly,
      showNotification: showNotification ?? this.showNotification,
      lockScreenControls: lockScreenControls ?? this.lockScreenControls,
      volume: volume ?? this.volume,
      skipSilenceThreshold: skipSilenceThreshold ?? this.skipSilenceThreshold,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      rememberPosition: rememberPosition ?? this.rememberPosition,
    );
  }
}

/// Hadith display settings
class HadithDisplaySettings {
  final double fontSize;
  final double arabicFontSize;
  final double translationFontSize;
  final bool showArabic;
  final bool showTranslation;
  final bool showNarratorChain;
  final bool showGrade;
  final bool showReference;
  final bool showTopics;
  final bool groupByBook;
  final bool groupByChapter;
  final bool compactMode;
  final bool showDiacritics;
  final bool showFullText;
  final HadithGrade? minGrade;

  const HadithDisplaySettings({
    this.fontSize = 16.0,
    this.arabicFontSize = 18.0,
    this.translationFontSize = 14.0,
    this.showArabic = true,
    this.showTranslation = true,
    this.showNarratorChain = true,
    this.showGrade = true,
    this.showReference = true,
    this.showTopics = false,
    this.groupByBook = true,
    this.groupByChapter = false,
    this.compactMode = false,
    this.showDiacritics = true,
    this.showFullText = false,
    this.minGrade = HadithGrade.unknown,
  });

  HadithDisplaySettings copyWith({
    double? fontSize,
    double? arabicFontSize,
    double? translationFontSize,
    bool? showArabic,
    bool? showTranslation,
    bool? showNarratorChain,
    bool? showGrade,
    bool? showReference,
    bool? showTopics,
    bool? groupByBook,
    bool? groupByChapter,
    bool? compactMode,
    bool? showDiacritics,
    bool? showFullText,
    HadithGrade? minGrade,
  }) {
    return HadithDisplaySettings(
      fontSize: fontSize ?? this.fontSize,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      showArabic: showArabic ?? this.showArabic,
      showTranslation: showTranslation ?? this.showTranslation,
      showNarratorChain: showNarratorChain ?? this.showNarratorChain,
      showGrade: showGrade ?? this.showGrade,
      showReference: showReference ?? this.showReference,
      showTopics: showTopics ?? this.showTopics,
      groupByBook: groupByBook ?? this.groupByBook,
      groupByChapter: groupByChapter ?? this.groupByChapter,
      compactMode: compactMode ?? this.compactMode,
      showDiacritics: showDiacritics ?? this.showDiacritics,
      showFullText: showFullText ?? this.showFullText,
      minGrade: minGrade ?? this.minGrade,
    );
  }
}

/// Notification settings
class NotificationSettings {
  final bool dailyVerseEnabled;
  final TimeOfDay dailyVerseTime;
  final bool dailyHadithEnabled;
  final TimeOfDay dailyHadithTime;
  final bool prayerTimesEnabled;
  final bool prayerNotificationsEnabled;
  final int prayerNotificationOffset; // minutes before prayer
  final bool fridayReminderEnabled;
  final bool ramadanRemindersEnabled;
  final bool eidRemindersEnabled;
  final bool downloadCompleteEnabled;
  final bool quranReminder;
  final String reminderTime;

  const NotificationSettings({
    this.dailyVerseEnabled = true,
    this.dailyVerseTime = const TimeOfDay(hour: 8, minute: 0),
    this.dailyHadithEnabled = true,
    this.dailyHadithTime = const TimeOfDay(hour: 18, minute: 0),
    this.prayerTimesEnabled = true,
    this.prayerNotificationsEnabled = true,
    this.prayerNotificationOffset = 5,
    this.fridayReminderEnabled = true,
    this.ramadanRemindersEnabled = true,
    this.eidRemindersEnabled = true,
    this.downloadCompleteEnabled = true,
    this.quranReminder = false,
    this.reminderTime = '08:00',
  });

  // Compatibility aliases
  bool get dailyHadith => dailyHadithEnabled;
  bool get prayerTimes => prayerTimesEnabled;
  bool get quranReminderEnabled => quranReminder;
  String get reminderTimeCompat => reminderTime;

  NotificationSettings copyWith({
    bool? dailyVerseEnabled,
    TimeOfDay? dailyVerseTime,
    bool? dailyHadithEnabled,
    bool? dailyHadith,
    TimeOfDay? dailyHadithTime,
    bool? prayerTimesEnabled,
    bool? prayerTimes,
    bool? prayerNotificationsEnabled,
    int? prayerNotificationOffset,
    bool? fridayReminderEnabled,
    bool? ramadanRemindersEnabled,
    bool? eidRemindersEnabled,
    bool? downloadCompleteEnabled,
    bool? quranReminder,
    String? reminderTime,
  }) {
    return NotificationSettings(
      dailyVerseEnabled: dailyVerseEnabled ?? this.dailyVerseEnabled,
      dailyVerseTime: dailyVerseTime ?? this.dailyVerseTime,
      dailyHadithEnabled:
          dailyHadithEnabled ?? dailyHadith ?? this.dailyHadithEnabled,
      dailyHadithTime: dailyHadithTime ?? this.dailyHadithTime,
      prayerTimesEnabled:
          prayerTimesEnabled ?? prayerTimes ?? this.prayerTimesEnabled,
      prayerNotificationsEnabled:
          prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
      prayerNotificationOffset:
          prayerNotificationOffset ?? this.prayerNotificationOffset,
      fridayReminderEnabled:
          fridayReminderEnabled ?? this.fridayReminderEnabled,
      ramadanRemindersEnabled:
          ramadanRemindersEnabled ?? this.ramadanRemindersEnabled,
      eidRemindersEnabled: eidRemindersEnabled ?? this.eidRemindersEnabled,
      downloadCompleteEnabled:
          downloadCompleteEnabled ?? this.downloadCompleteEnabled,
      quranReminder: quranReminder ?? this.quranReminder,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

/// Privacy settings
class PrivacySettings {
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool shareUsageData;
  final bool personalizedContent;
  final bool cloudSync;
  final bool autoDownloadOnWifi;
  final bool syncBookmarks;
  final bool shareProgress;

  const PrivacySettings({
    this.analyticsEnabled = false,
    this.crashReportingEnabled = true,
    this.shareUsageData = false,
    this.personalizedContent = false,
    this.cloudSync = false,
    this.autoDownloadOnWifi = true,
    this.syncBookmarks = false,
    this.shareProgress = false,
  });

  // Compatibility aliases
  bool get analytics => analyticsEnabled;
  bool get crashReporting => crashReportingEnabled;
  bool get autoDownloadOnWifiEnabled => autoDownloadOnWifi;
  bool get syncBookmarksEnabled => syncBookmarks;
  bool get shareProgressEnabled => shareProgress;

  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? analytics,
    bool? crashReportingEnabled,
    bool? crashReporting,
    bool? shareUsageData,
    bool? personalizedContent,
    bool? cloudSync,
    bool? autoDownloadOnWifi,
    bool? syncBookmarks,
    bool? shareProgress,
  }) {
    return PrivacySettings(
      analyticsEnabled: analyticsEnabled ?? analytics ?? this.analyticsEnabled,
      crashReportingEnabled:
          crashReportingEnabled ?? crashReporting ?? this.crashReportingEnabled,
      shareUsageData: shareUsageData ?? this.shareUsageData,
      personalizedContent: personalizedContent ?? this.personalizedContent,
      cloudSync: cloudSync ?? this.cloudSync,
      autoDownloadOnWifi: autoDownloadOnWifi ?? this.autoDownloadOnWifi,
      syncBookmarks: syncBookmarks ?? this.syncBookmarks,
      shareProgress: shareProgress ?? this.shareProgress,
    );
  }
}

/// Complete app settings
class AppSettings {
  final ThemeMode themeMode;
  final AppLanguage language;
  final String selectedTranslationId;
  final QuranDisplaySettings quranDisplay;
  final AudioSettings audio;
  final HadithDisplaySettings hadithDisplay;
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final bool firstLaunch;
  final bool animationsEnabled;
  final double fontScale;
  final DateTime? lastUpdated;
  final int schemaVersion;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.english,
    this.selectedTranslationId = 'en.sahih',
    QuranDisplaySettings? quranDisplay,
    AudioSettings? audio,
    HadithDisplaySettings? hadithDisplay,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    this.firstLaunch = true,
    this.animationsEnabled = true,
    this.fontScale = 1.0,
    this.lastUpdated,
    this.schemaVersion = 1,
  })  : quranDisplay = quranDisplay ?? const QuranDisplaySettings(),
        audio = audio ?? const AudioSettings(),
        hadithDisplay = hadithDisplay ?? const HadithDisplaySettings(),
        notifications = notifications ?? const NotificationSettings(),
        privacy = privacy ?? const PrivacySettings();

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    String? selectedTranslationId,
    QuranDisplaySettings? quranDisplay,
    AudioSettings? audio,
    HadithDisplaySettings? hadithDisplay,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    bool? firstLaunch,
    bool? animationsEnabled,
    double? fontScale,
    DateTime? lastUpdated,
    int? schemaVersion,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      selectedTranslationId:
          selectedTranslationId ?? this.selectedTranslationId,
      quranDisplay: quranDisplay ?? this.quranDisplay,
      audio: audio ?? this.audio,
      hadithDisplay: hadithDisplay ?? this.hadithDisplay,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      firstLaunch: firstLaunch ?? this.firstLaunch,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      fontScale: fontScale ?? this.fontScale,
      lastUpdated: lastUpdated ?? DateTime.now(),
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }
}
