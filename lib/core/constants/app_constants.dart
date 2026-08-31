/// Application-wide constants for the Quran & Hadith App

class AppConstants {
  // App Info
  static const String appName = 'Quran & Hadith';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.flutter.hadith.app';

  // API Endpoints
  static const String quranApiBaseUrl = 'https://api.quran.com/api/v4';
  static const String hadithApiBaseUrl = 'https://api.hadith.gading.dev';
  static const String audioBaseUrl = 'https://verses.quran.com';

  // Local Storage Keys
  static const String keySelectedTranslation = 'selected_translation';
  static const String keySelectedReciter = 'selected_reciter';
  static const String keyFontSize = 'font_size';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLastReadSurah = 'last_read_surah';
  static const String keyLastReadAyah = 'last_read_ayah';
  static const String keyBookmarks = 'bookmarks';
  static const String keyHadithBookmarks = 'hadith_bookmarks';
  static const String keyReadingHistory = 'reading_history';
  static const String keyDownloadProgress = 'download_progress';
  static const String keyLanguage = 'app_language';
  static const String keyAutoPlayAudio = 'auto_play_audio';
  static const String keyRepeatMode = 'repeat_mode';

  // Default Values
  static const int defaultFontSize = 18;
  static const String defaultTranslation = 'en.sahih';
  static const String defaultReciter = 'ar.alafasy';
  static const int defaultRepeatMode = 0; // 0: none, 1: ayah, 2: surah, 3: all

  // Quran Constants
  static const int totalSurahs = 114;
  static const int totalAyahs = 6236;
  static const int totalJuz = 30;
  static const int totalHizb = 60;
  static const int totalRub = 240;
  static const int totalSajdahs = 14;

  // Hadith Collections
  static const List<String> hadithCollections = [
    'bukhari',
    'muslim',
    'nasai',
    'abu-dawud',
    'tirmidhi',
    'ibn-majah',
    'malik',
    'ahmad',
  ];

  // Available Translations
  static const Map<String, String> translations = {
    'en.sahih': 'Sahih International (English)',
    'en.pickthall': 'Pickthall (English)',
    'en.yusufali': 'Yusuf Ali (English)',
    'en.shakir': 'Shakir (English)',
    'en.muhsin': 'Muhsin Khan (English)',
    'ur.junagarhi': 'Junagarhi (Urdu)',
    'ur.maududi': 'Maududi (Urdu)',
    'tr.ozeley': 'Ozeley (Turkish)',
    'tr.diyanet': 'Diyanet (Turkish)',
    'id.kemenag': 'Kemenag (Indonesian)',
    'ms.basmeih': 'Basmeih (Malay)',
    'bn.bengali': 'Bengali',
    'fa.ayati': 'Ayati (Persian)',
    'fr.hamidullah': 'Hamidullah (French)',
    'de.bubenheim': 'Bubenheim (German)',
    'ru.kuliev': 'Kuliev (Russian)',
    'zh.chinese': 'Chinese',
    'es.garcia': 'Garcia (Spanish)',
    'it.piccardo': 'Piccardo (Italian)',
    'nl.keyzer': 'Keyzer (Dutch)',
    'pt.elhayek': 'El-Hayek (Portuguese)',
    'sw.barwani': 'Barwani (Swahili)',
    'ta.tamil': 'Tamil',
    'ml.malayalam': 'Malayalam',
  };

  // Available Reciters
  static const Map<String, String> reciters = {
    'ar.alafasy': 'Mishary Alafasy',
    'ar.abdulbasit': 'Abdul Basit Abdus Samad',
    'ar.abdulbasitmujawwad': 'Abdul Basit (Mujawwad)',
    'ar.husary': 'Mahmoud Khalil Al-Husary',
    'ar.husarymujawwad': 'Al-Husary (Mujawwad)',
    'ar.minshawi': 'Muhammad Siddiq Al-Minshawi',
    'ar.minshawimujawwad': 'Al-Minshawi (Mujawwad)',
    'ar.sudais': 'Abdul Rahman Al-Sudais',
    'ar.shuraim': 'Saud Al-Shuraim',
    'ar.maher': 'Maher Al-Muaiqly',
    'ar.hudhaify': 'Ali Al-Hudhaify',
    'ar.ghamdi': 'Saad Al-Ghamdi',
    'ar.basfar': 'Abdullah Basfar',
    'ar.madhkur': 'Ibrahim Al-Madhkur',
    'ar.dossary': 'Yasser Al-Dossary',
    'ar.ayyoub': 'Muhammad Ayyoub',
    'ar.khatri': 'Hani Al-Khatri',
    'ar.maqtari': 'Mahmoud Al-Maqtari',
  };

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // Breakpoints
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;
}