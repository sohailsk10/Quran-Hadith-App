/// Quran data models for Surahs, Ayahs, Juz, and related entities

import 'package:flutter/foundation.dart';

/// Represents a Surah (chapter) in the Quran
class Surah {
  final int number;
  final String nameArabic;
  final String nameTransliteration;
  final String nameTranslation;
  final int ayahCount;
  final int revelationOrder;
  final RevelationType revelationType;
  final int juzNumber;
  final int hizbNumber;
  final int rubNumber;
  final String bismillahArabic;
  final String bismillahTranslation;
  final bool hasSajdah;
  final List<int> sajdahAyahNumbers;
  final int pageStart;
  final int pageEnd;
  final String description;

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameTransliteration,
    required this.nameTranslation,
    required this.ayahCount,
    required this.revelationOrder,
    required this.revelationType,
    required this.juzNumber,
    required this.hizbNumber,
    required this.rubNumber,
    required this.bismillahArabic,
    required this.bismillahTranslation,
    required this.hasSajdah,
    required this.sajdahAyahNumbers,
    required this.pageStart,
    required this.pageEnd,
    required this.description,
  });

  String get displayName => '$number. $nameTransliteration ($nameTranslation)';
  String get shortName => '$nameTransliteration ($number)';
  bool get isMeccan => revelationType == RevelationType.meccan;
  bool get isMedinan => revelationType == RevelationType.medinan;
  int get pageCount => pageEnd - pageStart + 1;

  Surah copyWith({
    int? number,
    String? nameArabic,
    String? nameTransliteration,
    String? nameTranslation,
    int? ayahCount,
    int? revelationOrder,
    RevelationType? revelationType,
    int? juzNumber,
    int? hizbNumber,
    int? rubNumber,
    String? bismillahArabic,
    String? bismillahTranslation,
    bool? hasSajdah,
    List<int>? sajdahAyahNumbers,
    int? pageStart,
    int? pageEnd,
    String? description,
  }) {
    return Surah(
      number: number ?? this.number,
      nameArabic: nameArabic ?? this.nameArabic,
      nameTransliteration: nameTransliteration ?? this.nameTransliteration,
      nameTranslation: nameTranslation ?? this.nameTranslation,
      ayahCount: ayahCount ?? this.ayahCount,
      revelationOrder: revelationOrder ?? this.revelationOrder,
      revelationType: revelationType ?? this.revelationType,
      juzNumber: juzNumber ?? this.juzNumber,
      hizbNumber: hizbNumber ?? this.hizbNumber,
      rubNumber: rubNumber ?? this.rubNumber,
      bismillahArabic: bismillahArabic ?? this.bismillahArabic,
      bismillahTranslation: bismillahTranslation ?? this.bismillahTranslation,
      hasSajdah: hasSajdah ?? this.hasSajdah,
      sajdahAyahNumbers: sajdahAyahNumbers ?? this.sajdahAyahNumbers,
      pageStart: pageStart ?? this.pageStart,
      pageEnd: pageEnd ?? this.pageEnd,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Surah && runtimeType == other.runtimeType && number == other.number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'Surah($number: $nameTransliteration)';
}

/// Type of revelation
enum RevelationType {
  meccan,
  medinan,
}

/// Represents a single Ayah (verse) in the Quran
class Ayah {
  final int number; // Global ayah number (1-6236)
  final int surahNumber;
  final int ayahInSurah; // Ayah number within the surah (1-based)
  final String textArabic;
  final String textUthmani; // Uthmani script
  final String textSimple; // Simple Arabic without diacritics
  final Map<String, String> translations; // Key: translation_id, Value: translated text
  final int juzNumber;
  final int hizbNumber;
  final int rubNumber;
  final int pageNumber;
  final bool isSajdah;
  final SajdahType? sajdahType;
  final String audioUrl; // Base URL for audio
  final Map<String, String> audioUrls; // Key: reciter_id, Value: audio URL
  final Duration? audioDuration;
  final int rukuNumber;
  final int manzilNumber;

  const Ayah({
    required this.number,
    required this.surahNumber,
    required this.ayahInSurah,
    required this.textArabic,
    required this.textUthmani,
    required this.textSimple,
    required this.translations,
    required this.juzNumber,
    required this.hizbNumber,
    required this.rubNumber,
    required this.pageNumber,
    required this.isSajdah,
    this.sajdahType,
    required this.audioUrl,
    required this.audioUrls,
    this.audioDuration,
    required this.rukuNumber,
    required this.manzilNumber,
  });

  String getTranslation(String translationId) {
    return translations[translationId] ?? translations.values.firstOrNull ?? '';
  }

  String getAudioUrl(String reciterId) {
    return audioUrls[reciterId] ?? audioUrl;
  }

  String get uniqueKey => '${surahNumber}:$ayahInSurah';
  String get reference => '$surahNumber:$ayahInSurah';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ayah && runtimeType == other.runtimeType && number == other.number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'Ayah($reference)';
}

/// Type of Sajdah (prostration)
enum SajdahType {
  obligatory, // Wajib
  recommended, // Mustahabb
}

/// Represents a Juz (Para) - 1/30th of the Quran
class Juz {
  final int number; // 1-30
  final int surahStart;
  final int ayahStart;
  final int surahEnd;
  final int ayahEnd;
  final int pageStart;
  final int pageEnd;
  final int ayahCount;

  const Juz({
    required this.number,
    required this.surahStart,
    required this.ayahStart,
    required this.surahEnd,
    required this.ayahEnd,
    required this.pageStart,
    required this.pageEnd,
    required this.ayahCount,
  });

  String get displayName => 'Juz $number';
  String get range => '$surahStart:$ayahStart - $surahEnd:$ayahEnd';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Juz && runtimeType == other.runtimeType && number == other.number;

  @override
  int get hashCode => number.hashCode;
}

/// Represents a Hizb (1/60th of the Quran)
class Hizb {
  final int number; // 1-60
  final int juzNumber;
  final int surahStart;
  final int ayahStart;
  final int surahEnd;
  final int ayahEnd;
  final int quarterNumber; // 1-4 (Rub)

  const Hizb({
    required this.number,
    required this.juzNumber,
    required this.surahStart,
    required this.ayahStart,
    required this.surahEnd,
    required this.ayahEnd,
    required this.quarterNumber,
  });

  String get displayName => 'Hizb $number (Juz $juzNumber)';
}

/// Represents a Rub' (quarter of Hizb, 1/240th of Quran)
class Rub {
  final int number; // 1-240
  final int hizbNumber;
  final int juzNumber;
  final int surahStart;
  final int ayahStart;
  final int surahEnd;
  final int ayahEnd;

  const Rub({
    required this.number,
    required this.hizbNumber,
    required this.juzNumber,
    required this.surahStart,
    required this.ayahStart,
    required this.surahEnd,
    required this.ayahEnd,
  });

  String get displayName => "Rub' $number (Hizb $hizbNumber)";
}

/// Represents translation metadata
class TranslationInfo {
  final String id;
  final String name;
  final String language;
  final String languageName;
  final String author;
  final String description;
  final int year;
  final bool isDownloaded;
  final String? localPath;

  const TranslationInfo({
    required this.id,
    required this.name,
    required this.language,
    required this.languageName,
    required this.author,
    required this.description,
    required this.year,
    this.isDownloaded = false,
    this.localPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationInfo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents reciter metadata
class ReciterInfo {
  final String id;
  final String name;
  final String nameArabic;
  final RecitationStyle style;
  final String country;
  final bool isDownloaded;
  final String? localPath;
  final int totalSize; // Total size in bytes

  const ReciterInfo({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.style,
    required this.country,
    this.isDownloaded = false,
    this.localPath,
    this.totalSize = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReciterInfo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Style of recitation
enum RecitationStyle {
  murattal, // Slow, measured
  mujawwad, // Melodic, with tajweed
  teaching, // For learning
}

/// Bookmark model for Quran
class QuranBookmark {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final DateTime createdAt;
  final String? note;
  final BookmarkColor color;

  const QuranBookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.createdAt,
    this.note,
    this.color = BookmarkColor.gold,
  });

  String get reference => '$surahNumber:$ayahNumber';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranBookmark && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Bookmark color options
enum BookmarkColor {
  gold,
  green,
  blue,
  red,
  purple,
  orange,
}

/// Reading progress tracking
class ReadingProgress {
  final int surahNumber;
  final int ayahNumber;
  final DateTime lastRead;
  final Duration timeSpent;
  final int scrollPosition; // Pixel offset

  const ReadingProgress({
    required this.surahNumber,
    required this.ayahNumber,
    required this.lastRead,
    required this.timeSpent,
    this.scrollPosition = 0,
  });

  String get reference => '$surahNumber:$ayahNumber';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgress &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber);
}

/// Search result model
@immutable
class QuranSearchResult {
  final Ayah ayah;
  final Surah surah;
  final String matchedText;
  final String translationId;
  final int matchType; // 0: exact, 1: partial, 2: fuzzy

  const QuranSearchResult({
    required this.ayah,
    required this.surah,
    required this.matchedText,
    required this.translationId,
    this.matchType = 0,
  });

  String get reference => ayah.reference;
  String get surahName => surah.nameTransliteration;
}

/// Tafsir (exegesis) model
class Tafsir {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String source; // e.g., 'ibn-kathir', 'jalalayn', 'maarif'
  final String sourceName;
  final String text;
  final String language;

  const Tafsir({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.source,
    required this.sourceName,
    required this.text,
    required this.language,
  });

  String get reference => '$surahNumber:$ayahNumber';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tafsir && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
