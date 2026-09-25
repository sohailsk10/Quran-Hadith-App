/// Quran Audio Service
/// Manages real audio streaming and playback for Quran surahs and ayahs using just_audio.

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/reciter_country_mapper.dart';
import '../../presentation/providers/app_providers.dart';

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

class QuranAudioNotifier extends Notifier<QuranAudioState> {
  late final AudioPlayer _player;
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'User-Agent': 'QuranHadithApp/1.0'},
  ));

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

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

    // Read initial selected reciter from settings
    final settings = ref.read(settingsProvider).valueOrNull;
    final reciterId = settings?.audio.selectedReciterId ?? '7';
    return QuranAudioState(
      currentReciterId: reciterId,
      currentReciterName: _getReciterName(reciterId),
    );
  }

  String _getReciterName(String id) {
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
    final standard = ReciterCountryMapper.getStandardReciters();
    final match = standard.where((r) => r.id == id).firstOrNull;
    if (match != null) return match.name;
    return 'Mishari Rashid al-`Afasy';
  }

  /// Plays an entire Surah with the chosen or currently selected reciter
  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
    String? reciterId,
    String? reciterName,
  }) {
    return _startSurahPlayback(
      surahNumber: surahNumber,
      surahName: surahName,
      reciterId: reciterId,
      reciterName: reciterName,
    );
  }

  Future<void> _startSurahPlayback({
    required int surahNumber,
    required String surahName,
    String? reciterId,
    String? reciterName,
  }) async {
    final targetReciterId =
        reciterId ?? state.currentReciterId;
    final targetReciterName = reciterName ??
        (reciterId != null ? _getReciterName(reciterId) : state.currentReciterName);

    // If same Surah and reciter already loaded, just toggle play/pause
    if (state.currentSurahNumber == surahNumber &&
        state.currentAyahNumber == null &&
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
      currentAyahNumber: null, // Full Surah
      currentReciterId: targetReciterId,
      currentReciterName: targetReciterName,
      errorMessage: null,
      position: Duration.zero,
    );

    try {
      final audioUrl =
          await _resolveSurahAudioUrl(targetReciterId, surahNumber);

      if (audioUrl == null || audioUrl.isEmpty) {
        throw Exception('Audio URL not available for this reciter');
      }

      state = state.copyWith(currentAudioUrl: audioUrl);
      await _player.stop();
      await _player.setUrl(audioUrl);
      await _player.play();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        errorMessage: 'Failed to play audio: ${e.toString()}',
      );
    }
  }

  /// Plays a specific Ayah with the chosen or selected reciter
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    String? reciterId,
    String? reciterName,
  }) async {
    final targetReciterId =
        reciterId ?? state.currentReciterId;
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

  /// Resolves direct MP3 URL for a Surah
  Future<String?> _resolveSurahAudioUrl(String reciterId, int surahNumber) async {
    final lowerId = reciterId.toLowerCase();
    final sStr = surahNumber.toString().padLeft(3, '0');

    // 1. Sheikh Yasser Al-Dosari
    if (lowerId == 'ar.dossari' ||
        lowerId == 'ar.dosari' ||
        lowerId == 'ar.dossary' ||
        lowerId.contains('dosari') ||
        lowerId.contains('dossari') ||
        lowerId.contains('dussary') ||
        lowerId.contains('yasser')) {
      return 'https://download.quranicaudio.com/quran/yasser_ad-dussary/$sStr.mp3';
    }

    final apiId = ReciterCountryMapper.getReciterApiId(reciterId);
    try {
      final res = await _dio.get(
        'https://api.quran.com/api/v4/chapter_recitations/$apiId/$surahNumber',
      );
      if (res.data != null && res.data['audio_file'] != null) {
        final url = res.data['audio_file']['audio_url'] as String?;
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }
    } catch (_) {
      // Fallback below
    }

    // Direct QuranicAudio CDN fallbacks
    switch (apiId) {
      case 7:
        return 'https://download.quranicaudio.com/qdc/mishari_al_afasy/murattal/$surahNumber.mp3';
      case 2:
        return 'https://download.quranicaudio.com/qdc/abdul_baset/murattal/$surahNumber.mp3';
      case 1:
        return 'https://download.quranicaudio.com/qdc/abdul_baset/mujawwad/$surahNumber.mp3';
      case 3:
        return 'https://download.quranicaudio.com/qdc/abdurrahmaan_as_sudais/murattal/$surahNumber.mp3';
      case 4:
        return 'https://download.quranicaudio.com/qdc/abu_bakr_shatri/murattal/$surahNumber.mp3';
      case 5:
        return 'https://download.quranicaudio.com/qdc/hani_ar_rifai/murattal/$surahNumber.mp3';
      case 6:
        return 'https://download.quranicaudio.com/qdc/khalil_al_husary/murattal/$surahNumber.mp3';
      case 9:
        return 'https://download.quranicaudio.com/qdc/siddiq_minshawi/murattal/$surahNumber.mp3';
      case 8:
        return 'https://download.quranicaudio.com/qdc/siddiq_al-minshawi/mujawwad/$sStr.mp3';
      case 10:
        return 'https://download.quranicaudio.com/qdc/saud_ash-shuraym/murattal/$sStr.mp3';
      default:
        return 'https://download.quranicaudio.com/qdc/mishari_al_afasy/murattal/$surahNumber.mp3';
    }
  }

  /// Resolves verse audio URL
  Future<String?> _resolveAyahAudioUrl(
    String reciterId,
    int surahNumber,
    int ayahNumber,
  ) async {
    final lowerId = reciterId.toLowerCase();
    final sStr = surahNumber.toString().padLeft(3, '0');
    final aStr = ayahNumber.toString().padLeft(3, '0');

    // 1. Sheikh Yasser Al-Dosari
    if (lowerId == 'ar.dossari' ||
        lowerId == 'ar.dosari' ||
        lowerId == 'ar.dossary' ||
        lowerId.contains('dosari') ||
        lowerId.contains('dossari') ||
        lowerId.contains('dussary') ||
        lowerId.contains('yasser')) {
      return 'https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/$sStr$aStr.mp3';
    }

    final apiId = ReciterCountryMapper.getReciterApiId(reciterId);
    try {
      final res = await _dio.get(
        'https://api.quran.com/api/v4/recitations/$apiId/by_ayah/$surahNumber:$ayahNumber',
      );
      if (res.data != null &&
          res.data['audio_files'] != null &&
          (res.data['audio_files'] as List).isNotEmpty) {
        final rawUrl = res.data['audio_files'][0]['url'] as String?;
        if (rawUrl != null && rawUrl.isNotEmpty) {
          if (rawUrl.startsWith('http')) return rawUrl;
          if (rawUrl.startsWith('//')) return 'https:$rawUrl';
          return 'https://verses.quran.com/$rawUrl';
        }
      }
    } catch (_) {
      // Fallback
    }

    // Direct fallback
    return 'https://verses.quran.com/Alafasy/mp3/$sStr$aStr.mp3';
  }
}

/// Global provider for Quran audio playback
final quranAudioProvider =
    NotifierProvider<QuranAudioNotifier, QuranAudioState>(
  QuranAudioNotifier.new,
);
