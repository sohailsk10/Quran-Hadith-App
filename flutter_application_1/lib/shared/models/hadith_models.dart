/// Hadith data models for collections, books, and individual hadiths

import 'package:flutter/foundation.dart';
import 'quran_models.dart' show BookmarkColor;

/// Represents a Hadith collection (e.g., Sahih Bukhari, Sahih Muslim)
class HadithCollection {
  final String id; // e.g., 'bukhari', 'muslim'
  final String name; // English name
  final String nameArabic; // Arabic name
  final String author; // Compiler name
  final String authorArabic; // Compiler name in Arabic
  final int authorBirthYear;
  final int authorDeathYear;
  final String description;
  final String descriptionArabic;
  final int totalHadiths;
  final int totalBooks;
  final int totalChapters;
  final CollectionAuthenticity authenticity;
  final bool isDownloaded;
  final String? localPath;
  final List<String> availableLanguages;
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
    required this.totalChapters,
    required this.authenticity,
    this.isDownloaded = false,
    this.localPath,
    required this.availableLanguages,
    required this.coverImageUrl,
  });

  String get displayName => '$name ($totalHadiths hadiths)';
  String get authorLifespan => '$authorBirthYear–$authorDeathYear CE';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithCollection &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HadithCollection($name)';
}

/// Authenticity level of a hadith collection
enum CollectionAuthenticity {
  sahih, // Most authentic
  hasan, // Good
  mixed, // Contains various grades
  weak, // Contains weak hadiths
}

/// Authenticity level of an individual hadith
enum HadithAuthenticity {
  sahih, // Authentic
  hasan, // Good
  daif, // Weak
  mawdu, // Fabricated
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
class HadithBook {
  final String id;
  final String collectionId;
  final int bookNumber;
  final String name;
  final String nameArabic;
  final String? bookDescription;
  final String? descriptionArabic;
  final int hadithStartNumber;
  final int hadithEndNumber;
  final int totalHadiths;
  final List<String> chapters; // Chapter names within this book

  const HadithBook({
    required this.id,
    required this.collectionId,
    required this.bookNumber,
    required this.name,
    required this.nameArabic,
    String? description,
    this.descriptionArabic,
    required this.hadithStartNumber,
    required this.hadithEndNumber,
    required this.totalHadiths,
    required this.chapters,
  }) : bookDescription = description;

  String get displayName => 'Book $bookNumber: $name';
  String get range => '$hadithStartNumber–$hadithEndNumber';

  // Aliases for compatibility
  int get number => bookNumber;
  String get title => name;
  int get hadithCount => totalHadiths;
  int get chapterCount => chapters.length;
  String? get description => bookDescription;

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
class HadithChapter {
  final String id;
  final String bookId;
  final int chapterNumber;
  final String name;
  final String nameArabic;
  final int hadithStartNumber;
  final int hadithEndNumber;
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
  int get endHadithNumber => hadithEndNumber;
  int get number => chapterNumber;
  String get nameEnglish => name;
  int get hadithCount => totalHadiths;
  int get hadithRangeStart => hadithStartNumber;
  int get hadithRangeEnd => hadithEndNumber;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithChapter &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents a single Hadith
class Hadith {
  final String id; // Unique identifier
  final String collectionId;
  final int bookNumber;
  final int hadithNumber; // Number within the collection
  final int? bookHadithNumber; // Number within the book
  final String? chapterId;
  final String textArabic;
  final Map<String, String>
      translations; // Key: language_code, Value: translated text
  final List<String> narrators; // Chain of narrators (isnad)
  final String narratorChainArabic; // Full isnad in Arabic
  final HadithGrade grade;
  final String gradeDetails; // Explanation of grading
  final List<String> topics; // Tags/categories
  final List<String> keywords; // Search keywords
  final String? reference; // e.g., "Bukhari 1234"
  final String? referenceUrl; // Link to online source
  final Map<String, String> audioUrls; // Key: reciter_id, Value: audio URL
  final Duration? audioDuration;
  final bool isFavorite;
  final DateTime? addedToFavorites;
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

  String getTranslation(String languageCode) {
    return translations[languageCode] ??
        translations['en'] ??
        translations.values.firstOrNull ??
        '';
  }

  String? getAudioUrl(String reciterId) {
    return audioUrls[reciterId];
  }

  String get formattedReference {
    if (reference != null) return reference!;
    return '$collectionId $hadithNumber';
  }

  String get shortReference => '$collectionId $hadithNumber';

  String get displayTitle {
    final translation = getTranslation('en');
    if (translation.isEmpty) return formattedReference;
    final words = translation.split(' ');
    return words.take(8).join(' ') + (words.length > 8 ? '...' : '');
  }

  String get arabicText => textArabic;
  int get numberInBook => bookHadithNumber ?? hadithNumber;
  String get collectionName => collectionId.toUpperCase();
  bool get isBookmarked => isFavorite;

  // Compatibility aliases
  String get bookName => metadata['bookName'] as String? ?? '';
  String get chapterName => metadata['chapterName'] as String? ?? '';

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

  int? get volumeNumber {
    if (metadata.containsKey('volume')) {
      return metadata['volume'] as int?;
    }
    return null;
  }

  int? get pageNumber {
    if (metadata.containsKey('page')) {
      return metadata['page'] as int?;
    }
    return null;
  }

  String? get notes {
    if (metadata.containsKey('notes')) {
      return metadata['notes'] as String?;
    }
    return null;
  }

  bool get isSahih => grade == HadithGrade.sahih;
  bool get isHasan => grade == HadithGrade.hasan;
  bool get isDaif => grade == HadithGrade.daif;

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
enum HadithGrade {
  sahih, // Authentic
  hasan, // Good
  daif, // Weak
  mawdu, // Fabricated
  munkar, // Rejected
  mudtarib, // Shaky
  muallal, // Defective
  unknown, // Not graded/unknown
}

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
class HadithBookmark {
  final String id;
  final String hadithId;
  final String collectionId;
  final int bookNumber;
  final int hadithNumber;
  final DateTime createdAt;
  final String? note;
  final BookmarkColor color;
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
      other is HadithBookmark &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
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
class Narrator {
  final String id;
  final String name;
  final String nameArabic;
  final String kunya; // e.g., "Abu Hurairah"
  final int? birthYear;
  final int? deathYear;
  final String biography;
  final String biographyArabic;
  final NarratorReliability reliability;
  final List<String> teachers; // Who they narrated from
  final List<String> students; // Who narrated from them
  final List<String> collections; // Which collections they appear in
  final int? order; // Position in isnad chain

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
    this.order,
  });

  String get lifespan {
    if (birthYear != null && deathYear != null) {
      return '$birthYear–$deathYear CE';
    } else if (deathYear != null) {
      return 'd. $deathYear CE';
    }
    return 'Unknown';
  }

  // Compatibility aliases
  String get birthDeath => lifespan;
  int get narratorOrder => order ?? 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Narrator && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Narrator reliability grading
enum NarratorReliability {
  thiqa, // Trustworthy
  saduq, // Truthful
  hasan, // Good
  daif, // Weak
  matruk, // Abandoned
  majhul, // Unknown
  kadhdhab, // Liar
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
        return "Da'if (Weak)";
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
        return "Da'if";
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
  final Set<HadithAuthenticity> authenticities;
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
    Set<HadithAuthenticity>? authenticities,
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
class HadithTopic {
  final String id;
  final String name;
  final String nameArabic;
  final String? parentId; // For hierarchical topics
  final int level; // 0 = top level
  final String description;
  final String descriptionArabic;
  final int hadithCount;
  final int collectionCount;
  final HadithGrade grade;
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
    this.collectionCount = 0,
    this.grade = HadithGrade.unknown,
    required this.iconName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithTopic &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
