/// Settings and user preference models

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'settings_models.g.dart';

/// App theme mode
@HiveType(typeId: 40)
enum ThemeMode {
  @HiveField(0)
  system,
  @HiveField(1)
  light,
  @HiveField(2)
  dark,
}

/// App language
@HiveType(typeId: 41)
enum AppLanguage {
  @HiveField(0)
  english,
  @HiveField(1)
  arabic,
  @HiveField(2)
  urdu,
  @HiveField(3)
  turkish,
  @HiveField(4)
  indonesian,
  @HiveField(5)
  malay,
  @HiveField(6)
  bengali,
  @HiveField(7)
  persian,
  @HiveField(8)
  french,
  @HiveField(9)
  german,
  @HiveField(10)
  russian,
  @HiveField(11)
  chinese,
  @HiveField(12)
  spanish,
  @HiveField(13)
  italian,
  @HiveField(14)
  dutch,
  @HiveField(15)
  portuguese,
  @HiveField(16)
  swahili,
  @HiveField(17)
  tamil,
  @HiveField(18)
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

  bool get isRTL => this == AppLanguage.arabic || this == AppLanguage.urdu || this == AppLanguage.persian;
}

/// Quran font family options
@HiveType(typeId: 42)
enum QuranFontFamily {
  @HiveField(0)
  uthmani, // Classic Uthmani script
  @HiveField(1)
  indopak, // Indo-Pak script
  @HiveField(2)
  simple, // Simple Arabic
  @HiveField(3)
  amiri, // Amiri font
  @HiveField(4)
  notoNastaliq, // Noto Nastaliq Urdu
  @HiveField(5)
  scheherazade, // Scheherazade
  @HiveField(6)
  latex, // LaTeX-style
}

/// Audio repeat mode
@HiveType(typeId: 43)
enum AudioRepeatMode {
  @HiveField(0)
  none,
  @HiveField(1)
  ayah,
  @HiveField(2)
  surah,
  @HiveField(3)
  all,
}

/// Audio playback speed
@HiveType(typeId: 44)
enum PlaybackSpeed {
  @HiveField(0)
  x0_5,
  @HiveField(1)
  x0_75,
  @HiveField(2)
  x1_0,
  @HiveField(3)
  x1_25,
  @HiveField(4)
  x1_5,
  @HiveField(5)
  x1_75,
  @HiveField(6)
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
@HiveType(typeId: 45)
class QuranDisplaySettings extends HiveObject {
  @HiveField(0)
  final double fontSize;

  @HiveField(1)
  final double translationFontSize;

  @HiveField(2)
  final QuranFontFamily fontFamily;

  @HiveField(3)
  final bool showArabic;

  @HiveField(4)
  final bool showTranslation;

  @HiveField(5)
  final bool showTransliteration;

  @HiveField(6)
  final bool showAyahNumbers;

  @HiveField(7)
  final bool showJuzMarkers;

  @HiveField(8)
  final bool showHizbMarkers;

  @HiveField(9)
  final bool showSajdahMarkers;

  @HiveField(10)
  final bool showRukuMarkers;

  @HiveField(11)
  final bool showPageNumbers;

  @HiveField(12)
  final bool highlightCurrentAyah;

  @HiveField(13)
  final bool autoScrollToAyah;

  @HiveField(14)
  final double lineSpacing;

  @HiveField(15)
  final double wordSpacing;

  @HiveField(16)
  final bool nightMode;

  @HiveField(17)
  final bool showBismillah;

  @HiveField(18)
  final bool verseByVerse;

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
  });

  QuranDisplaySettings copyWith({
    double? fontSize,
    double? translationFontSize,
    QuranFontFamily? fontFamily,
    bool? showArabic,
    bool? showTranslation,
    bool? showTransliteration,
    bool? showAyahNumbers,
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
  }) {
    return QuranDisplaySettings(
      fontSize: fontSize ?? this.fontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      showArabic: showArabic ?? this.showArabic,
      showTranslation: showTranslation ?? this.showTranslation,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showAyahNumbers: showAyahNumbers ?? this.showAyahNumbers,
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
    );
  }
}

/// Audio settings
@HiveType(typeId: 46)
class AudioSettings extends HiveObject {
  @HiveField(0)
  final String selectedReciterId;

  @HiveField(1)
  final AudioRepeatMode repeatMode;

  @HiveField(2)
  final PlaybackSpeed playbackSpeed;

  @HiveField(3)
  final bool autoPlayNext;

  @HiveField(4)
  final bool backgroundPlayback;

  @HiveField(5)
  final bool downloadOnWifiOnly;

  @HiveField(6)
  final bool showNotification;

  @HiveField(7)
  final bool lockScreenControls;

  @HiveField(8)
  final double volume;

  @HiveField(9)
  final int skipSilenceThreshold; // milliseconds

  @HiveField(10)
  final bool gaplessPlayback;

  @HiveField(11)
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
@HiveType(typeId: 47)
class HadithDisplaySettings extends HiveObject {
  @HiveField(0)
  final double fontSize;

  @HiveField(1)
  final double arabicFontSize;

  @HiveField(2)
  final bool showArabic;

  @HiveField(3)
  final bool showTranslation;

  @HiveField(4)
  final bool showNarratorChain;

  @HiveField(5)
  final bool showGrade;

  @HiveField(6)
  final bool showReference;

  @HiveField(7)
  final bool showTopics;

  @HiveField(8)
  final bool groupByBook;

  @HiveField(9)
  final bool groupByChapter;

  @HiveField(10)
  final bool compactMode;

  @HiveField(11)
  final bool showDiacritics;

  const HadithDisplaySettings({
    this.fontSize = 16.0,
    this.arabicFontSize = 18.0,
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
  });

  HadithDisplaySettings copyWith({
    double? fontSize,
    double? arabicFontSize,
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
  }) {
    return HadithDisplaySettings(
      fontSize: fontSize ?? this.fontSize,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
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
    );
  }
}

/// Notification settings
@HiveType(typeId: 48)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  final bool dailyVerseEnabled;

  @HiveField(1)
  final TimeOfDay dailyVerseTime;

  @HiveField(2)
  final bool dailyHadithEnabled;

  @HiveField(3)
  final TimeOfDay dailyHadithTime;

  @HiveField(4)
  final bool prayerTimesEnabled;

  @HiveField(5)
  final bool prayerNotificationsEnabled;

  @HiveField(6)
  final int prayerNotificationOffset; // minutes before prayer

  @HiveField(7)
  final bool fridayReminderEnabled;

  @HiveField(8)
  final bool ramadanRemindersEnabled;

  @HiveField(9)
  final bool eidRemindersEnabled;

  @HiveField(10)
  final bool downloadCompleteEnabled;

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
  });

  NotificationSettings copyWith({
    bool? dailyVerseEnabled,
    TimeOfDay? dailyVerseTime,
    bool? dailyHadithEnabled,
    TimeOfDay? dailyHadithTime,
    bool? prayerTimesEnabled,
    bool? prayerNotificationsEnabled,
    int? prayerNotificationOffset,
    bool? fridayReminderEnabled,
    bool? ramadanRemindersEnabled,
    bool? eidRemindersEnabled,
    bool? downloadCompleteEnabled,
  }) {
    return NotificationSettings(
      dailyVerseEnabled: dailyVerseEnabled ?? this.dailyVerseEnabled,
      dailyVerseTime: dailyVerseTime ?? this.dailyVerseTime,
      dailyHadithEnabled: dailyHadithEnabled ?? this.dailyHadithEnabled,
      dailyHadithTime: dailyHadithTime ?? this.dailyHadithTime,
      prayerTimesEnabled: prayerTimesEnabled ?? this.prayerTimesEnabled,
      prayerNotificationsEnabled: prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
      prayerNotificationOffset: prayerNotificationOffset ?? this.prayerNotificationOffset,
      fridayReminderEnabled: fridayReminderEnabled ?? this.fridayReminderEnabled,
      ramadanRemindersEnabled: ramadanRemindersEnabled ?? this.ramadanRemindersEnabled,
      eidRemindersEnabled: eidRemindersEnabled ?? this.eidRemindersEnabled,
      downloadCompleteEnabled: downloadCompleteEnabled ?? this.downloadCompleteEnabled,
    );
  }
}

/// TimeOfDay adapter for Hive
@HiveType(typeId: 49)
class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 49;

  @override
  TimeOfDay read(BinaryReader reader) {
    return TimeOfDay(hour: reader.readByte(), minute: reader.readByte());
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeByte(obj.hour);
    writer.writeByte(obj.minute);
  }
}

/// Privacy settings
@HiveType(typeId: 50)
class PrivacySettings extends HiveObject {
  @HiveField(0)
  final bool analyticsEnabled;

  @HiveField(1)
  final bool crashReportingEnabled;

  @HiveField(2)
  final bool shareUsageData;

  @HiveField(3)
  final bool personalizedContent;

  @HiveField(4)
  final bool cloudSync;

  const PrivacySettings({
    this.analyticsEnabled = false,
    this.crashReportingEnabled = true,
    this.shareUsageData = false,
    this.personalizedContent = false,
    this.cloudSync = false,
  });

  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? shareUsageData,
    bool? personalizedContent,
    bool? cloudSync,
  }) {
    return PrivacySettings(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      shareUsageData: shareUsageData ?? this.shareUsageData,
      personalizedContent: personalizedContent ?? this.personalizedContent,
      cloudSync: cloudSync ?? this.cloudSync,
    );
  }
}

/// Complete app settings
@HiveType(typeId: 51)
class AppSettings extends HiveObject {
  @HiveField(0)
  final ThemeMode themeMode;

  @HiveField(1)
  final AppLanguage language;

  @HiveField(2)
  final String selectedTranslationId;

  @HiveField(3)
  final QuranDisplaySettings quranDisplay;

  @HiveField(4)
  final AudioSettings audio;

  @HiveField(5)
  final HadithDisplaySettings hadithDisplay;

  @HiveField(6)
  final NotificationSettings notifications;

  @HiveField(7)
  final PrivacySettings privacy;

  @HiveField(8)
  final bool firstLaunch;

  @HiveField(9)
  final DateTime? lastUpdated;

  @HiveField(10)
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
    DateTime? lastUpdated,
    int? schemaVersion,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      selectedTranslationId: selectedTranslationId ?? this.selectedTranslationId,
      quranDisplay: quranDisplay ?? this.quranDisplay,
      audio: audio ?? this.audio,
      hadithDisplay: hadithDisplay ?? this.hadithDisplay,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      firstLaunch: firstLaunch ?? this.firstLaunch,
      lastUpdated: lastUpdated ?? DateTime.now(),
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }
}