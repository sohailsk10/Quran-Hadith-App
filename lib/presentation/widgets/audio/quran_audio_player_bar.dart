/// Quran Audio Player Mini Bar
/// Floats at the bottom of the reading view when audio is playing or loaded.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/quran_audio_service.dart';

class QuranAudioPlayerBar extends ConsumerWidget {
  const QuranAudioPlayerBar({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(quranAudioProvider);
    final audioNotifier = ref.read(quranAudioProvider.notifier);
    final theme = Theme.of(context);

    if (!audioState.hasTrack) {
      return const SizedBox.shrink();
    }

    final totalSeconds = audioState.duration.inSeconds.toDouble();
    final currentSeconds = audioState.position.inSeconds.toDouble().clamp(
          0.0,
          totalSeconds > 0 ? totalSeconds : 1.0,
        );

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linear Progress Indicator / Slider
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusLG),
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 3,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                trackShape: const RectangularSliderTrackShape(),
              ),
              child: Slider(
                value: currentSeconds,
                max: totalSeconds > 0 ? totalSeconds : 1.0,
                activeColor: theme.colorScheme.primary,
                inactiveColor: theme.colorScheme.surfaceContainerHighest,
                onChanged: (val) {
                  audioNotifier.seek(Duration(seconds: val.toInt()));
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: AppConstants.spacingMD,
              right: AppConstants.spacingSM,
              bottom: AppConstants.spacingSM,
            ),
            child: Row(
              children: [
                // Play / Pause / Loading button
                GestureDetector(
                  onTap: () {
                    if (audioState.isPlaying) {
                      audioNotifier.pause();
                    } else {
                      audioNotifier.resume();
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: audioState.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Icon(
                              audioState.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 26,
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: AppConstants.spacingMD),

                // Track & Reciter info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        audioState.currentAyahNumber != null
                            ? '${audioState.currentSurahName} (Ayah ${audioState.currentAyahNumber})'
                            : (audioState.currentSurahName ?? 'Surah Audio'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              audioState.currentReciterName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDuration(audioState.position)} / ${_formatDuration(audioState.duration)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppConstants.spacingSM),

                // Close / Stop button
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => audioNotifier.stop(),
                  tooltip: 'Close audio',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
