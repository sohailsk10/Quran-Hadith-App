/// Hadith data models for collections, books, and individual hadiths

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'hadith_models.g.dart';

/// Represents a Hadith collection (e.g., Sahih Bukhari, Sahih Muslim)
@HiveType(typeId: 20)
class HadithCollection extends HiveObject {
  @HiveField(0)
  final String id; // e.g., 'bukhari', 'muslim'

  @HiveField(1)
  final String name; // English name

  @HiveField(2)
  final String nameArabic; // Arabic name

  @HiveField(3)
  final String author; // Compiler name

  @HiveField(4)
  final String authorArabic; // Compiler name in Arabic

  @HiveField(5)
  final int authorBirthYear;

  @HiveField(6)
  final int authorDeathYear;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final String descriptionArabic;

  @HiveField(9)
  final int totalHadiths;

  @HiveField(10)
  final int totalBooks;

  @HiveField(11)
  final CollectionAuthenticity authenticity;

  @HiveField(12)
  final bool isDownloaded;

  @HiveField(13)
  final String? localPath;

  @HiveField(14)
  final List<String> availableLanguages;

  @HiveField(15)
  final String coverImageUrl;

  const HadithCollection({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.author,
    required this.authorArabic,
    required this.authorBirthYear,
    required this.authorDeathYear,
    required this.description,
    required this.descriptionArabic,
    required this.totalHadiths,
    required this.totalBooks,
    required this.authenticity,
    this.isDownloaded = false,
    this.localPath,
    required this.availableLanguages,
    required this.coverImageUrl,
  });

  /// Get display name with hadith count
  String get displayName => '$name ($totalHadiths hadiths)';

  /// Get author lifespan
  String get authorLifespan => '$authorBirthYear–$authorDeathYear CE';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithCollection && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HadithCollection($name)';
}

/// Authenticity level of a hadith collection
@HiveType(typeId: 21)
enum CollectionAuthenticity {
  @HiveField(0)
  sahih, // Most authentic
  @HiveField(1)
  hasan, // Good
  @HiveField(2)
  mixed, // Contains various grades
  @HiveField(3)
  weak, // Contains weak hadiths
}

/// Authenticity level of an individual hadith
@HiveType(typeId: 21)
enum HadithAuthenticity {
  @HiveField(0)
  sahih, // Authentic
  @HiveField(1)
  hasan, // Good
  @HiveField(2)
  daif, // Weak
  @HiveField(3)
  mawdu, // Fabricated
  @HiveField(4)
  unknown, // Unknown
}

extension HadithAuthenticityExtension on HadithAuthenticity {
  String get displayName {
    switch (this) {
      case HadithAuthenticity.sahih:
        return 'Ṣaḥīḥ (Authentic)';
      case HadithAuthenticity.hasan:
        return 'Ḥasan (Good)';
      case HadithAuthenticity.daif:
        return 'Ḍaʻīf (Weak)';
      case HadithAuthenticity.mawdu:
        return 'Mawḍūʻ (Fabricated)';
      case HadithAuthenticity.unknown:
        return 'Unknown';
    }
  }

  String get shortName {
    switch (this) {
      case HadithAuthenticity.sahih:
        return 'Ṣaḥīḥ';
      case HadithAuthenticity.hasan:
        return 'Ḥasan';
      case HadithAuthenticity.daif:
        return 'Ḍaʻīf';
      case HadithAuthenticity.mawdu:
        return 'Mawḍūʻ';
      case HadithAuthenticity.unknown:
        return '—';
    }
  }

  String get arabicName {
    switch (this) {
      case HadithAuthenticity.sahih:
        return 'صحيح';
      case HadithAuthenticity.hasan:
        return 'حسن';
      case HadithAuthenticity.daif:
        return 'ضعيف';
      case HadithAuthenticity.mawdu:
        return 'موضوع';
      case HadithAuthenticity.unknown:
        return '—';
    }
  }
}

/// Represents a Book within a Hadith collection (e.g., "Book of Prayer")
@HiveType(typeId: 22)
class HadithBook extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String collectionId;

  @HiveField(2)
  final int bookNumber;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final String nameArabic;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String? descriptionArabic;

  @HiveField(7)
  final int hadithStartNumber;

  @HiveField(8)
  final int hadithEndNumber;

  @HiveField(9)
  final int totalHadiths;

  @HiveField(10)
  final List<String> chapters; // Chapter names within this book

  const HadithBook({
    required this.id,
    required this.collectionId,
    required this.bookNumber,
    required this.name,
    required this.nameArabic,
    this.description,
    this.descriptionArabic,
    required this.hadithStartNumber,
    required this.hadithEndNumber,
    required this.totalHadiths,
    required this.chapters,
  });

  String get displayName => 'Book $bookNumber: $name';
  String get range => '$hadithStartNumber–$hadithEndNumber';

  // Aliases for compatibility
  int get number => bookNumber;
  String get title => name;
  int get hadithCount => totalHadiths;
  int get chapterCount => chapters.length;
  String? get description => this.description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithBook && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HadithBook($name)';
}

/// Represents a Chapter within a Book
@HiveType(typeId: 23)
class HadithChapter extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bookId;

  @HiveField(2)
  final int chapterNumber;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final String nameArabic;

  @HiveField(5)
  final int hadithStartNumber;

  @HiveField(6)
  final int hadithEndNumber;

  @HiveField(7)
  final int totalHadiths;

  const HadithChapter({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.name,
    required this.nameArabic,
    required this.hadithStartNumber,
    required this.hadithEndNumber,
    required this.totalHadiths,
  });

  String get displayName => 'Chapter $chapterNumber: $name';
  String get range => '$hadithStartNumber–$hadithEndNumber';

  // Aliases for compatibility
  int get startHadithNumber => hadithStartNumber;
  int get number => chapterNumber;
  String get nameEnglish => name;
  int get hadithCount => totalHadiths;
  int get hadithRangeStart => hadithStartNumber;
  int get hadithRangeEnd => hadithEndNumber;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithChapter && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents a single Hadith
@HiveType(typeId: 24)
class Hadith extends HiveObject {
  @HiveField(0)
  final String id; // Unique identifier

  @HiveField(1)
  final String collectionId;

  @HiveField(2)
  final int bookNumber;

  @HiveField(3)
  final int hadithNumber; // Number within the collection

  @HiveField(4)
  final int? bookHadithNumber; // Number within the book

  @HiveField(5)
  final String? chapterId;

  @HiveField(6)
  final String textArabic;

  @HiveField(7)
  final Map<String, String> translations; // Key: language_code, Value: translated text

  @HiveField(8)
  final List<String> narrators; // Chain of narrators (isnad)

  @HiveField(9)
  final String narratorChainArabic; // Full isnad in Arabic

  @HiveField(10)
  final HadithGrade grade;

  @HiveField(11)
  final String gradeDetails; // Explanation of grading

  @HiveField(12)
  final List<String> topics; // Tags/categories

  @HiveField(13)
  final List<String> keywords; // Search keywords

  @HiveField(14)
  final String? reference; // e.g., "Bukhari 1234"

  @HiveField(15)
  final String? referenceUrl; // Link to online source

  @HiveField(16)
  final Map<String, String> audioUrls; // Key: reciter_id, Value: audio URL

  @HiveField(17)
  final Duration? audioDuration;

  @HiveField(18)
  final bool isFavorite;

  @HiveField(19)
  final DateTime? addedToFavorites;

  @HiveField(20)
  final Map<String, dynamic> metadata; // Additional flexible metadata

  const Hadith({
    required this.id,
    required this.collectionId,
    required this.bookNumber,
    required this.hadithNumber,
    this.bookHadithNumber,
    this.chapterId,
    required this.textArabic,
    required this.translations,
    required this.narrators,
    required this.narratorChainArabic,
    required this.grade,
    required this.gradeDetails,
    required this.topics,
    required this.keywords,
    this.reference,
    this.referenceUrl,
    required this.audioUrls,
    this.audioDuration,
    this.isFavorite = false,
    this.addedToFavorites,
    required this.metadata,
  });

  /// Get translation for a specific language
  String getTranslation(String languageCode) {
    return translations[languageCode] ?? translations['en'] ?? translations.values.firstOrNull ?? '';
  }

  /// Get audio URL for a specific reciter
  String? getAudioUrl(String reciterId) {
    return audioUrls[reciterId];
  }

  /// Get formatted reference string
  String get formattedReference {
    if (reference != null) return reference!;
    return '$collectionId $hadithNumber';
  }

  /// Get short reference for display
  String get shortReference => '$collectionId $hadithNumber';

  /// Get display title (first few words of translation)
  String get displayTitle {
    final translation = getTranslation('en');
    if (translation.isEmpty) return formattedReference;
    final words = translation.split(' ');
    return words.take(8).join(' ') + (words.length > 8 ? '...' : '');
  }

  /// Arabic text getter (alias for textArabic)
  String get arabicText => textArabic;

  /// Number in book getter (alias for bookHadithNumber or hadithNumber)
  int get numberInBook => bookHadithNumber ?? hadithNumber;

  /// Collection name getter
  String get collectionName => collectionId.toUpperCase();

  /// Is bookmarked getter (alias for isFavorite)
  bool get isBookmarked => isFavorite;

  /// Authenticity getter based on grade
  HadithAuthenticity get authenticity {
    switch (grade) {
      case HadithGrade.sahih:
        return HadithAuthenticity.sahih;
      case HadithGrade.hasan:
        return HadithAuthenticity.hasan;
      case HadithGrade.daif:
        return HadithAuthenticity.daif;
      case HadithGrade.mawdu:
        return HadithAuthenticity.mawdu;
      default:
        return HadithAuthenticity.unknown;
    }
  }

  /// Reliability getter based on grade
  NarratorReliability get reliability {
    switch (grade) {
      case HadithGrade.sahih:
        return NarratorReliability.thiqa;
      case HadithGrade.hasan:
        return NarratorReliability.saduq;
      case HadithGrade.daif:
        return NarratorReliability.daif;
      case HadithGrade.mawdu:
        return NarratorReliability.kadhdhab;
      default:
        return NarratorReliability.majhul;
    }
  }

  /// Volume number (from metadata if available)
  int? get volumeNumber {
    if (metadata.containsKey('volume')) {
      return metadata['volume'] as int?;
    }
    return null;
  }

  /// Page number (from metadata if available)
  int? get pageNumber {
    if (metadata.containsKey('page')) {
      return metadata['page'] as int?;
    }
    return null;
  }

  /// Notes (from metadata if available)
  String? get notes {
    if (metadata.containsKey('notes')) {
      return metadata['notes'] as String?;
    }
    return null;
  }

  /// Check if hadith is graded Sahih
  bool get isSahih => grade == HadithGrade.sahih;

  /// Check if hadith is graded Hasan
  bool get isHasan => grade == HadithGrade.hasan;

  /// Check if hadith is graded Da'if
  bool get isDaif => grade == HadithGrade.daif;

  /// Create copy with updated fields
  Hadith copyWith({
    String? id,
    String? collectionId,
    int? bookNumber,
    int? hadithNumber,
    int? bookHadithNumber,
    String? chapterId,
    String? textArabic,
    Map<String, String>? translations,
    List<String>? narrators,
    String? narratorChainArabic,
    HadithGrade? grade,
    String? gradeDetails,
    List<String>? topics,
    List<String>? keywords,
    String? reference,
    String? referenceUrl,
    Map<String, String>? audioUrls,
    Duration? audioDuration,
    bool? isFavorite,
    DateTime? addedToFavorites,
    Map<String, dynamic>? metadata,
  }) {
    return Hadith(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      bookNumber: bookNumber ?? this.bookNumber,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      bookHadithNumber: bookHadithNumber ?? this.bookHadithNumber,
      chapterId: chapterId ?? this.chapterId,
      textArabic: textArabic ?? this.textArabic,
      translations: translations ?? this.translations,
      narrators: narrators ?? this.narrators,
      narratorChainArabic: narratorChainArabic ?? this.narratorChainArabic,
      grade: grade ?? this.grade,
      gradeDetails: gradeDetails ?? this.gradeDetails,
      topics: topics ?? this.topics,
      keywords: keywords ?? this.keywords,
      reference: reference ?? this.reference,
      referenceUrl: referenceUrl ?? this.referenceUrl,
      audioUrls: audioUrls ?? this.audioUrls,
      audioDuration: audioDuration ?? this.audioDuration,
      isFavorite: isFavorite ?? this.isFavorite,
      addedToFavorites: addedToFavorites ?? this.addedToFavorites,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hadith && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Hadith($formattedReference)';
}

/// Hadith grading/strength
@HiveType(typeId: 25)
enum HadithGrade {
  @HiveField(0)
  sahih, // Authentic
  @HiveField(1)
  hasan, // Good
  @HiveField(2)
  daif, // Weak
  @HiveField(3)
  mawdu, // Fabricated
  @HiveField(4)
  munkar, // Rejected
  @HiveField(5)
  mudtarib, // Shaky
  @HiveField(6)
  muallal, // Defective
  @HiveField(7)
  unknown, // Not graded/unknown
}

/// Grade display info
extension HadithGradeExtension on HadithGrade {
  String get displayName {
    switch (this) {
      case HadithGrade.sahih:
        return 'Ṣaḥīḥ (Authentic)';
      case HadithGrade.hasan:
        return 'Ḥasan (Good)';
      case HadithGrade.daif:
        return 'Ḍaʻīf (Weak)';
      case HadithGrade.mawdu:
        return 'Mawḍūʻ (Fabricated)';
      case HadithGrade.munkar:
        return 'Munkar (Rejected)';
      case HadithGrade.mudtarib:
        return 'Muḍṭarib (Shaky)';
      case HadithGrade.muallal:
        return 'Muʻallal (Defective)';
      case HadithGrade.unknown:
        return 'Unknown';
    }
  }

  String get shortName {
    switch (this) {
      case HadithGrade.sahih:
        return 'Ṣaḥīḥ';
      case HadithGrade.hasan:
        return 'Ḥasan';
      case HadithGrade.daif:
        return 'Ḍaʻīf';
      case HadithGrade.mawdu:
        return 'Mawḍūʻ';
      case HadithGrade.munkar:
        return 'Munkar';
      case HadithGrade.mudtarib:
        return 'Muḍṭarib';
      case HadithGrade.muallal:
        return 'Muʻallal';
      case HadithGrade.unknown:
        return '—';
    }
  }

  String get arabicName {
    switch (this) {
      case HadithGrade.sahih:
        return 'صحيح';
      case HadithGrade.hasan:
        return 'حسن';
      case HadithGrade.daif:
        return 'ضعيف';
      case HadithGrade.mawdu:
        return 'موضوع';
      case HadithGrade.munkar:
        return 'منكر';
      case HadithGrade.mudtarib:
        return 'مضطرب';
      case HadithGrade.muallal:
        return 'معلل';
      case HadithGrade.unknown:
        return '—';
    }
  }

  int get sortOrder {
    switch (this) {
      case HadithGrade.sahih:
        return 0;
      case HadithGrade.hasan:
        return 1;
      case HadithGrade.daif:
        return 2;
      case HadithGrade.mudtarib:
        return 3;
      case HadithGrade.muallal:
        return 4;
      case HadithGrade.munkar:
        return 5;
      case HadithGrade.mawdu:
        return 6;
      case HadithGrade.unknown:
        return 7;
    }
  }
}

/// Bookmark for Hadith
@HiveType(typeId: 26)
class HadithBookmark extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String hadithId;

  @HiveField(2)
  final String collectionId;

  @HiveField(3)
  final int bookNumber;

  @HiveField(4)
  final int hadithNumber;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final BookmarkColor color;

  @HiveField(8)
  final List<String> tags;

  const HadithBookmark({
    required this.id,
    required this.hadithId,
    required this.collectionId,
    required this.bookNumber,
    required this.hadithNumber,
    required this.createdAt,
    this.note,
    this.color = BookmarkColor.gold,
    this.tags = const [],
  });

  String get reference => '$collectionId $hadithNumber';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithBookmark && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Reuse BookmarkColor from Quran models
@HiveType(typeId: 27)
enum BookmarkColor {
  @HiveField(0)
  gold,
  @HiveField(1)
  green,
  @HiveField(2)
  blue,
  @HiveField(3)
  red,
  @HiveField(4)
  purple,
  @HiveField(5)
  orange,
}

/// Search result for Hadith
@immutable
class HadithSearchResult {
  final Hadith hadith;
  final HadithCollection collection;
  final HadithBook? book;
  final HadithChapter? chapter;
  final String matchedText;
  final String languageCode;
  final int matchType; // 0: exact, 1: partial, 2: fuzzy, 3: narrator match

  const HadithSearchResult({
    required this.hadith,
    required this.collection,
    this.book,
    this.chapter,
    required this.matchedText,
    required this.languageCode,
    this.matchType = 0,
  });

  String get reference => hadith.formattedReference;
  String get collectionName => collection.name;
}

/// Narrator (Rawi) information
@HiveType(typeId: 28)
class Narrator extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String nameArabic;

  @HiveField(3)
  final String kunya; // e.g., "Abu Hurairah"

  @HiveField(4)
  final int? birthYear;

  @HiveField(5)
  final int? deathYear;

  @HiveField(6)
  final String biography;

  @HiveField(7)
  final String biographyArabic;

  @HiveField(8)
  final NarratorReliability reliability;

  @HiveField(9)
  final List<String> teachers; // Who they narrated from

  @HiveField(10)
  final List<String> students; // Who narrated from them

  @HiveField(11)
  final List<String> collections; // Which collections they appear in

  const Narrator({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.kunya,
    this.birthYear,
    this.deathYear,
    required this.biography,
    required this.biographyArabic,
    required this.reliability,
    required this.teachers,
    required this.students,
    required this.collections,
  });

  String get lifespan {
    if (birthYear != null && deathYear != null) {
      return '$birthYear–$deathYear CE';
    } else if (deathYear != null) {
      return 'd. $deathYear CE';
    }
    return 'Unknown';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Narrator && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Narrator reliability grading
@HiveType(typeId: 29)
enum NarratorReliability {
  @HiveField(0)
  thiqa, // Trustworthy
  @HiveField(1)
  saduq, // Truthful
  @HiveField(2)
  hasan, // Good
  @HiveField(3)
  daif, // Weak
  @HiveField(4)
  matruk, // Abandoned
  @HiveField(5)
  majhul, // Unknown
  @HiveField(6)
  kadhdhab, // Liar
  @HiveField(7)
  unknown, // Not graded/unknown
}

extension NarratorReliabilityExtension on NarratorReliability {
  String get displayName {
    switch (this) {
      case NarratorReliability.thiqa:
        return 'Thiqa (Trustworthy)';
      case NarratorReliability.saduq:
        return 'Saduq (Truthful)';
      case NarratorReliability.hasan:
        return 'Hasan (Good)';
      case NarratorReliability.daif:
        return 'Da\'if (Weak)';
      case NarratorReliability.matruk:
        return 'Matruk (Abandoned)';
      case NarratorReliability.majhul:
        return 'Majhul (Unknown)';
      case NarratorReliability.kadhdhab:
        return 'Kadhdhab (Liar)';
      case NarratorReliability.unknown:
        return 'Unknown';
    }
  }

  String get shortName {
    switch (this) {
      case NarratorReliability.thiqa:
        return 'Thiqa';
      case NarratorReliability.saduq:
        return 'Saduq';
      case NarratorReliability.hasan:
        return 'Hasan';
      case NarratorReliability.daif:
        return 'Da\'if';
      case NarratorReliability.matruk:
        return 'Matruk';
      case NarratorReliability.majhul:
        return 'Majhul';
      case NarratorReliability.kadhdhab:
        return 'Kadhdhab';
      case NarratorReliability.unknown:
        return '—';
    }
  }

  String get arabicName {
    switch (this) {
      case NarratorReliability.thiqa:
        return 'ثقة';
      case NarratorReliability.saduq:
        return 'صادق';
      case NarratorReliability.hasan:
        return 'حسن';
      case NarratorReliability.daif:
        return 'ضعيف';
      case NarratorReliability.matruk:
        return 'متروك';
      case NarratorReliability.majhul:
        return 'مجهول';
      case NarratorReliability.kadhdhab:
        return 'كذاب';
      case NarratorReliability.unknown:
        return '—';
    }
  }
}

/// Filter class for hadith search/filtering
@immutable
class HadithFilter {
  final Set<String> collections;
  final Set<CollectionAuthenticity> authenticities;
  final Set<HadithGrade> grades;
  final Set<String> topics;
  final bool bookmarkedOnly;

  const HadithFilter({
    this.collections = const {},
    this.authenticities = const {},
    this.grades = const {},
    this.topics = const {},
    this.bookmarkedOnly = false,
  });

  HadithFilter copyWith({
    Set<String>? collections,
    Set<CollectionAuthenticity>? authenticities,
    Set<HadithGrade>? grades,
    Set<String>? topics,
    bool? bookmarkedOnly,
  }) {
    return HadithFilter(
      collections: collections ?? this.collections,
      authenticities: authenticities ?? this.authenticities,
      grades: grades ?? this.grades,
      topics: topics ?? this.topics,
      bookmarkedOnly: bookmarkedOnly ?? this.bookmarkedOnly,
    );
  }

  bool get hasActiveFilters =>
      collections.isNotEmpty ||
      authenticities.isNotEmpty ||
      grades.isNotEmpty ||
      topics.isNotEmpty ||
      bookmarkedOnly;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithFilter &&
          runtimeType == other.runtimeType &&
          collections == other.collections &&
          authenticities == other.authenticities &&
          grades == other.grades &&
          topics == other.topics &&
          bookmarkedOnly == other.bookmarkedOnly;

  @override
  int get hashCode =>
      collections.hashCode ^
      authenticities.hashCode ^
      grades.hashCode ^
      topics.hashCode ^
      bookmarkedOnly.hashCode;
}

/// Topic/Category for hadith classification
@HiveType(typeId: 30)
class HadithTopic extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String nameArabic;

  @HiveField(3)
  final String? parentId; // For hierarchical topics

  @HiveField(4)
  final int level; // 0 = top level

  @HiveField(5)
  final String description;

  @HiveField(6)
  final String descriptionArabic;

  @HiveField(7)
  final int hadithCount;

  @HiveField(8)
  final String iconName; // Material icon name

  const HadithTopic({
    required this.id,
    required this.name,
    required this.nameArabic,
    this.parentId,
    required this.level,
    required this.description,
    required this.descriptionArabic,
    required this.hadithCount,
    required this.iconName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithTopic && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}