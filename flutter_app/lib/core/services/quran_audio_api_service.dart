/// Quran Audio API Service
/// Calls the Python FastAPI backend for audio URL resolution and reciter management.

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;
import '../../presentation/providers/app_providers.dart';

/// Base URL for the Python FastAPI backend
String get _apiBaseUrl {
  if (kIsWeb) return 'http://localhost:8000';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
  return 'http://localhost:8000';
}

@immutable
class QuranAudioState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final int? currentSurahNumber;
  final String? currentSurahName;
  final int? currentAyahNumber;
  final String currentReciterId;
  final String currentReciterName;
  final String? currentAudioUrl;
  final String? errorMessage;
  final double speed;

  const QuranAudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentSurahNumber,
    this.currentSurahName,
    this.currentAyahNumber,
    this.currentReciterId = '7',
    this.currentReciterName = 'Mishari Rashid al-`Afasy',
    this.currentAudioUrl,
    this.errorMessage,
    this.speed = 1.0,
  });

  bool get hasTrack => currentSurahNumber != null;
  int? get surahNumber => currentSurahNumber;
  int? get ayahNumber => currentAyahNumber;

  QuranAudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    int? currentSurahNumber,
    String? currentSurahName,
    int? currentAyahNumber,
    String? currentReciterId,
    String? currentReciterName,
    String? currentAudioUrl,
    String? errorMessage,
    double? speed,
    bool clearTrack = false,
  }) {
    if (clearTrack) {
      return QuranAudioState(
        currentReciterId: currentReciterId ?? this.currentReciterId,
        currentReciterName: currentReciterName ?? this.currentReciterName,
        speed: speed ?? this.speed,
      );
    }
    return QuranAudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentSurahNumber: currentSurahNumber ?? this.currentSurahNumber,
      currentSurahName: currentSurahName ?? this.currentSurahName,
      currentAyahNumber: currentAyahNumber ?? this.currentAyahNumber,
      currentReciterId: currentReciterId ?? this.currentReciterId,
      currentReciterName: currentReciterName ?? this.currentReciterName,
      currentAudioUrl: currentAudioUrl ?? this.currentAudioUrl,
      errorMessage: errorMessage,
      speed: speed ?? this.speed,
    );
  }
}

/// Data models matching the Python API
@immutable
class ReciterCountry {
  final String name;
  final String flag;
  final int priority;

  const ReciterCountry({
    required this.name,
    required this.flag,
    this.priority = 100,
  });

  String get displayName => '$flag $name';

  factory ReciterCountry.fromJson(Map<String, dynamic> json) {
    return ReciterCountry(
      name: json['name'] as String,
      flag: json['flag'] as String,
      priority: json['priority'] as int? ?? 100,
    );
  }
}

@immutable
class ReciterInfo {
  final String id;
  final String name;
  final String? nameArabic;
  final String style;
  final String country;

  const ReciterInfo({
    required this.id,
    required this.name,
    this.nameArabic,
    this.style = 'murattal',
    this.country = 'Saudi Arabia',
  });

  factory ReciterInfo.fromJson(Map<String, dynamic> json) {
    return ReciterInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      nameArabic: json['name_arabic'] as String?,
      style: json['style'] as String? ?? 'murattal',
      country: json['country'] as String? ?? 'Saudi Arabia',
    );
  }
}

@immutable
class AyahAudioResponse {
  final String audioUrl;
  final String reciterId;
  final String reciterName;
  final int surahNumber;
  final int ayahNumber;

  const AyahAudioResponse({
    required this.audioUrl,
    required this.reciterId,
    required this.reciterName,
    required this.surahNumber,
    required this.ayahNumber,
  });

  factory AyahAudioResponse.fromJson(Map<String, dynamic> json) {
    return AyahAudioResponse(
      audioUrl: json['audio_url'] as String,
      reciterId: json['reciter_id'] as String,
      reciterName: json['reciter_name'] as String,
      surahNumber: json['surah_number'] as int,
      ayahNumber: json['ayah_number'] as int,
    );
  }
}

@immutable
class SurahAudioResponse {
  final List<String> audioUrls;
  final String reciterId;
  final String reciterName;
  final int surahNumber;
  final String surahName;
  final int totalAyahs;

  const SurahAudioResponse({
    required this.audioUrls,
    required this.reciterId,
    required this.reciterName,
    required this.surahNumber,
    required this.surahName,
    required this.totalAyahs,
  });

  factory SurahAudioResponse.fromJson(Map<String, dynamic> json) {
    return SurahAudioResponse(
      audioUrls: (json['audio_urls'] as List).cast<String>(),
      reciterId: json['reciter_id'] as String,
      reciterName: json['reciter_name'] as String,
      surahNumber: json['surah_number'] as int,
      surahName: json['surah_name'] as String,
      totalAyahs: json['total_ayahs'] as int,
    );
  }
}

@immutable
class RecitersResponse {
  final List<ReciterInfo> reciters;
  final Map<String, ReciterCountry> countries;

  const RecitersResponse({
    required this.reciters,
    required this.countries,
  });

  factory RecitersResponse.fromJson(Map<String, dynamic> json) {
    return RecitersResponse(
      reciters: (json['reciters'] as List)
          .map((e) => ReciterInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      countries: (json['countries'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, ReciterCountry.fromJson(value as Map<String, dynamic>)),
      ),
    );
  }
}

class QuranAudioApiNotifier extends Notifier<QuranAudioState> {
  late final AudioPlayer _player;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: _apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'User-Agent': 'QuranHadithApp/1.0'},
  ));

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  List<ReciterInfo> _cachedReciters = [];
  Map<String, ReciterCountry> _cachedCountries = {};

  @override
  QuranAudioState build() {
    _player = AudioPlayer();

    // Listen to player state
    _playerStateSubscription = _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      final isLoading = processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering;

      if (processingState == ProcessingState.completed) {
        state = state.copyWith(
          isPlaying: false,
          position: state.duration,
        );
        _handleTrackCompleted();
      } else {
        state = state.copyWith(
          isPlaying: isPlaying,
          isLoading: isLoading,
        );
      }
    });

    // Listen to position changes
    _positionSubscription = _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    // Listen to duration changes
    _durationSubscription = _player.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _player.dispose();
      _dio.close();
    });

    // Load reciters from API on startup
    _loadRecitersFromApi();

    // Read initial selected reciter from settings
    final settings = ref.read(settingsProvider).valueOrNull;
    final reciterId = settings?.audio.selectedReciterId ?? '7';
    return QuranAudioState(
      currentReciterId: reciterId,
      currentReciterName: _getReciterName(reciterId),
    );
  }

  Future<void> _loadRecitersFromApi() async {
    try {
      final response = await _dio.get('/api/reciters');
      if (response.statusCode == 200) {
        final data = RecitersResponse.fromJson(response.data as Map<String, dynamic>);
        if (data.reciters.isNotEmpty) {
          _cachedReciters = data.reciters;
          _cachedCountries = data.countries;
          debugPrint('Loaded ${_cachedReciters.length} reciters from API');
          return;
        }
      }
    } catch (e) {
      debugPrint('Failed to load reciters from API: $e');
    }
    // Fallback to local data if API fails
    _cachedReciters = getFallbackReciters();
  }

  static List<ReciterInfo> getFallbackReciters() {
    return const [
      ReciterInfo(
        id: '7',
        name: 'Mishari Rashid al-`Afasy',
        nameArabic: 'مشاري بن راشد العفاسي',
        style: 'murattal',
        country: 'Kuwait',
      ),
      ReciterInfo(
        id: '3',
        name: 'Abdur-Rahman as-Sudais',
        nameArabic: 'عبد الرحمن السديس',
        style: 'murattal',
        country: 'Saudi Arabia',
      ),
      ReciterInfo(
        id: 'ar.dossari',
        name: 'Sheikh Yasser Al-Dosari',
        nameArabic: 'الشيخ ياسر الدوسري',
        style: 'murattal',
        country: 'Saudi Arabia',
      ),
      ReciterInfo(
        id: '10',
        name: 'Sa`ud ash-Shuraym',
        nameArabic: 'سعود الشريم',
        style: 'murattal',
        country: 'Saudi Arabia',
      ),
      ReciterInfo(
        id: '4',
        name: 'Abu Bakr al-Shatri',
        nameArabic: 'أبو بكر الشاطري',
        style: 'murattal',
        country: 'Saudi Arabia',
      ),
      ReciterInfo(
        id: '5',
        name: 'Hani ar-Rifai',
        nameArabic: 'هاني الرفاعي',
        style: 'murattal',
        country: 'Saudi Arabia',
      ),
      ReciterInfo(
        id: '2',
        name: 'AbdulBaset AbdulSamad (Murattal)',
        nameArabic: 'عبد الباسط عبد الصمد (مرتل)',
        style: 'murattal',
        country: 'Egypt',
      ),
      ReciterInfo(
        id: '1',
        name: 'AbdulBaset AbdulSamad (Mujawwad)',
        nameArabic: 'عبد الباسط عبد الصمد (مجود)',
        style: 'mujawwad',
        country: 'Egypt',
      ),
      ReciterInfo(
        id: '6',
        name: 'Mahmoud Khalil Al-Husary (Murattal)',
        nameArabic: 'محمود خليل الحصري (مرتل)',
        style: 'murattal',
        country: 'Egypt',
      ),
      ReciterInfo(
        id: '12',
        name: 'Mahmoud Khalil Al-Husary (Muallim)',
        nameArabic: 'محمود خليل الحصري (معلم)',
        style: 'murattal',
        country: 'Egypt',
      ),
      ReciterInfo(
        id: '9',
        name: 'Mohamed Siddiq al-Minshawi (Murattal)',
        nameArabic: 'محمد صديق المنشاوي (مرتل)',
        style: 'murattal',
        country: 'Egypt',
      ),
      ReciterInfo(
        id: '8',
        name: 'Mohamed Siddiq al-Minshawi (Mujawwad)',
        nameArabic: 'محمد صديق المنشاوي (مجود)',
        style: 'mujawwad',
        country: 'Egypt',
      ),
      ReciterInfo(
        id: '11',
        name: 'Mohamed al-Tablawi',
        nameArabic: 'محمد محمود الطبلاوي',
        style: 'murattal',
        country: 'Egypt',
      ),
    ];
  }

  void _handleTrackCompleted() {
    final surahNum = state.currentSurahNumber;
    final ayahNum = state.currentAyahNumber;

    if (surahNum != null && ayahNum != null) {
      int totalAyahs = 7;
      try {
        totalAyahs = quran.getVerseCount(surahNum);
      } catch (_) {
        totalAyahs = 286;
      }

      if (ayahNum < totalAyahs) {
        // Automatically play next ayah in the Surah
        playAyah(
          surahNumber: surahNum,
          ayahNumber: ayahNum + 1,
          surahName: state.currentSurahName ?? 'Surah $surahNum',
          reciterId: state.currentReciterId,
          reciterName: state.currentReciterName,
        );
      }
    }
  }

  /// Plays a Surah verse-by-verse starting at Ayah 1 (or toggles current playback if same surah)
  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
    String? reciterId,
    String? reciterName,
  }) async {
    final targetReciterId = reciterId ?? state.currentReciterId;
    final targetReciterName = reciterName ??
        (reciterId != null ? _getReciterName(reciterId) : state.currentReciterName);

    // If same Surah and reciter already loaded, just toggle play/pause
    if (state.currentSurahNumber == surahNumber &&
        state.currentReciterId == targetReciterId &&
        state.currentAudioUrl != null) {
      if (state.isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    // Start playing from Ayah 1 so verses are individually tracked, highlighted, and bolded!
    await playAyah(
      surahNumber: surahNumber,
      ayahNumber: 1,
      surahName: surahName,
      reciterId: targetReciterId,
      reciterName: targetReciterName,
    );
  }

  Future<void> nextAyah() async {
    final surahNum = state.currentSurahNumber;
    final ayahNum = state.currentAyahNumber;
    if (surahNum != null && ayahNum != null) {
      int totalAyahs = 7;
      try {
        totalAyahs = quran.getVerseCount(surahNum);
      } catch (_) {}
      if (ayahNum < totalAyahs) {
        await playAyah(
          surahNumber: surahNum,
          ayahNumber: ayahNum + 1,
          surahName: state.currentSurahName ?? 'Surah $surahNum',
        );
      }
    }
  }

  Future<void> previousAyah() async {
    final surahNum = state.currentSurahNumber;
    final ayahNum = state.currentAyahNumber;
    if (surahNum != null && ayahNum != null && ayahNum > 1) {
      await playAyah(
        surahNumber: surahNum,
        ayahNumber: ayahNum - 1,
        surahName: state.currentSurahName ?? 'Surah $surahNum',
      );
    }
  }

  String _getReciterName(String id) {
    // First check cached reciters from API
    final match = _cachedReciters.where((r) => r.id == id).firstOrNull;
    if (match != null) return match.name;

    // Fallback to local mapping
    final lower = id.toLowerCase();
    if (lower == 'ar.dossari' ||
        lower == 'ar.dosari' ||
        lower == 'ar.dossary' ||
        lower.contains('dosari') ||
        lower.contains('dossari') ||
        lower.contains('dussary') ||
        lower.contains('yasser')) {
      return 'Sheikh Yasser Al-Dosari';
    }
    return 'Mishari Rashid al-`Afasy';
  }

  ReciterCountry? getCountryForReciter(String reciterId) {
    return _cachedCountries[reciterId];
  }

  List<ReciterInfo> getAllReciters() {
    return _cachedReciters;
  }

  /// Plays a specific Ayah with the chosen or selected reciter
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    String? reciterId,
    String? reciterName,
  }) async {
    final targetReciterId = reciterId ?? state.currentReciterId;
    final targetReciterName = reciterName ??
        (reciterId != null ? _getReciterName(reciterId) : state.currentReciterName);

    // If same Ayah and reciter already playing, toggle
    if (state.currentSurahNumber == surahNumber &&
        state.currentAyahNumber == ayahNumber &&
        state.currentReciterId == targetReciterId &&
        state.currentAudioUrl != null) {
      if (state.isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    state = state.copyWith(
      isLoading: true,
      currentSurahNumber: surahNumber,
      currentSurahName: surahName,
      currentAyahNumber: ayahNumber,
      currentReciterId: targetReciterId,
      currentReciterName: targetReciterName,
      errorMessage: null,
      position: Duration.zero,
    );

    try {
      final audioUrl = await _resolveAyahAudioUrl(
          targetReciterId, surahNumber, ayahNumber);

      if (audioUrl == null || audioUrl.isEmpty) {
        throw Exception('Verse audio URL not available');
      }

      state = state.copyWith(currentAudioUrl: audioUrl);
      await _player.stop();
      await _player.setUrl(audioUrl);
      await _player.play();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        errorMessage: 'Failed to play ayah audio: ${e.toString()}',
      );
    }
  }

  /// Changes the active reciter. If currently playing, automatically switches audio to new reciter!
  Future<void> changeReciter({
    required String reciterId,
    required String reciterName,
  }) async {
    final previousReciterId = state.currentReciterId;
    state = state.copyWith(
      currentReciterId: reciterId,
      currentReciterName: reciterName,
    );

    // Also persist in app settings
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentSettings = ref.read(settingsProvider).valueOrNull;
    if (currentSettings != null) {
      settingsNotifier.updateAudioSettings(
        currentSettings.audio.copyWith(selectedReciterId: reciterId),
      );
    }

    // If audio was already active or playing, immediately reload with the new reciter!
    if (state.hasTrack && previousReciterId != reciterId) {
      if (state.currentAyahNumber != null) {
        await playAyah(
          surahNumber: state.currentSurahNumber!,
          ayahNumber: state.currentAyahNumber!,
          surahName: state.currentSurahName ?? 'Surah',
          reciterId: reciterId,
          reciterName: reciterName,
        );
      } else if (state.currentSurahNumber != null) {
        await playSurah(
          surahNumber: state.currentSurahNumber!,
          surahName: state.currentSurahName ?? 'Surah',
          reciterId: reciterId,
          reciterName: reciterName,
        );
      }
    }
  }

  /// Pause current audio
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resume current audio
  Future<void> resume() async {
    await _player.play();
  }

  /// Stop audio and close player
  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(
      clearTrack: true,
      isPlaying: false,
      isLoading: false,
    );
  }

  /// Seek to a duration
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Change playback speed
  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    await _player.setSpeed(speed);
  }

  /// Resolves verse audio URL via Python API
  Future<String?> _resolveAyahAudioUrl(
    String reciterId,
    int surahNumber,
    int ayahNumber,
  ) async {
    try {
      final response = await _dio.post(
        '/api/audio/ayah',
        data: {
          'reciter_id': reciterId,
          'surah_number': surahNumber,
          'ayah_number': ayahNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = AyahAudioResponse.fromJson(response.data as Map<String, dynamic>);
        return data.audioUrl;
      }
    } catch (e) {
      debugPrint('API error resolving audio URL: $e');
    }

    // Fallback to direct URL construction (same logic as Python API)
    final lowerId = reciterId.toLowerCase();
    final sStr = surahNumber.toString().padLeft(3, '0');
    final aStr = ayahNumber.toString().padLeft(3, '0');

    // Sheikh Yasser Al-Dosari
    if (lowerId == 'ar.dossari' ||
        lowerId == 'ar.dosari' ||
        lowerId == 'ar.dossary' ||
        lowerId.contains('dosari') ||
        lowerId.contains('dossari') ||
        lowerId.contains('dussary') ||
        lowerId.contains('yasser')) {
      return 'https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/$sStr$aStr.mp3';
    }

    // Default fallback
    return 'https://verses.quran.com/Alafasy/mp3/$sStr$aStr.mp3';
  }
}

/// Global provider for Quran audio playback using Python API
final quranAudioApiProvider =
    NotifierProvider<QuranAudioApiNotifier, QuranAudioState>(
  QuranAudioApiNotifier.new,
);

// Provider for accessing reciters list from API
final quranAudioRecitersProvider = FutureProvider<List<ReciterInfo>>((ref) async {
  final dio = Dio(BaseOptions(
    baseUrl: _apiBaseUrl,
    connectTimeout: const Duration(seconds: 4),
    receiveTimeout: const Duration(seconds: 4),
  ));
  try {
    final response = await dio.get('/api/reciters');
    if (response.statusCode == 200) {
      final data = RecitersResponse.fromJson(response.data as Map<String, dynamic>);
      if (data.reciters.isNotEmpty) {
        return data.reciters;
      }
    }
  } catch (e) {
    debugPrint('Could not load reciters from API ($_apiBaseUrl): $e');
  }
  // Fallback so the reciter list is always populated
  return QuranAudioApiNotifier.getFallbackReciters();
});

// Provider for accessing countries from API
final quranAudioReciterCountriesProvider = FutureProvider<Map<String, ReciterCountry>>((ref) async {
  final dio = Dio(BaseOptions(
    baseUrl: _apiBaseUrl,
    connectTimeout: const Duration(seconds: 4),
    receiveTimeout: const Duration(seconds: 4),
  ));
  try {
    final response = await dio.get('/api/countries');
    if (response.statusCode == 200) {
      return (response.data as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, ReciterCountry.fromJson(value as Map<String, dynamic>)),
      );
    }
  } catch (e) {
    debugPrint('Could not load countries from API ($_apiBaseUrl): $e');
  }
  return const {
    'kuwait': ReciterCountry(name: 'Kuwait', flag: '🇰🇼', priority: 1),
    'saudi_arabia': ReciterCountry(name: 'Saudi Arabia', flag: '🇸🇦', priority: 2),
    'egypt': ReciterCountry(name: 'Egypt', flag: '🇪🇬', priority: 3),
    'yemen': ReciterCountry(name: 'Yemen', flag: '🇾🇪', priority: 4),
    'uae': ReciterCountry(name: 'United Arab Emirates', flag: '🇦🇪', priority: 5),
    'other': ReciterCountry(name: 'Other', flag: '🌐', priority: 99),
  };
});