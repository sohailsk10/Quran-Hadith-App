/// Ayah list item widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran;
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/quran_audio_api_service.dart';
import '../../../shared/models/quran_models.dart';
import '../../../shared/models/settings_models.dart';

class AyahListItem extends ConsumerWidget {
  final Ayah ayah;
  final QuranDisplaySettings settings;
  final bool showTranslation;
  final String? translationText;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AyahListItem({
    super.key,
    required this.ayah,
    required this.settings,
    this.showTranslation = false,
    this.translationText,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;
    final audioState = ref.watch(quranAudioApiProvider);
    final isThisAyah = audioState.surahNumber == ayah.surahNumber &&
        audioState.ayahNumber == ayah.numberInSurah;
    final isPlaying = isThisAyah && audioState.isPlaying;
    final isLoading = isThisAyah && audioState.isLoading;
    final isHighlighted =
        isThisAyah && (audioState.isPlaying || audioState.isLoading);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: isHighlighted
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: isHighlighted
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isHighlighted ? 2.0 : 1.0,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color:
                        theme.colorScheme.primary.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ayah Header
            Row(
              children: [
                // Ayah Number
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isHighlighted
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                if (isHighlighted) ...[
                  const SizedBox(width: AppConstants.spacingSM),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPlaying
                              ? Icons.volume_up_rounded
                              : Icons.hourglass_top_rounded,
                          size: 12,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPlaying ? 'Reciting' : 'Loading',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(width: AppConstants.spacingSM),

                // Ayah Audio Play Button
                InkWell(
                  onTap: () {
                    if (isPlaying) {
                      ref.read(quranAudioApiProvider.notifier).pause();
                    } else if (isThisAyah && audioState.hasTrack) {
                      ref.read(quranAudioApiProvider.notifier).resume();
                    } else {
                      final surahName =
                          quran.getSurahName(ayah.surahNumber);
                      ref.read(quranAudioApiProvider.notifier).playAyah(
                            surahNumber: ayah.surahNumber,
                            ayahNumber: ayah.numberInSurah,
                            surahName: surahName.isNotEmpty
                                ? surahName
                                : 'Surah ${ayah.surahNumber}',
                          );
                    }
                  },
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                      border: Border.all(
                        color: isPlaying
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        else
                          Icon(
                            isPlaying
                                ? Icons.pause
                                : Icons.play_arrow_rounded,
                            size: 14,
                            color: isPlaying
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          isPlaying ? 'Playing' : 'Audio',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isPlaying
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isPlaying
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sajdah Marker
                if (settings.showSajdahMarkers && ayah.isSajdah) ...[
                  const SizedBox(width: AppConstants.spacingSM),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          quranHadithTheme.sajdahColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.accessibility,
                          size: 12,
                          color: quranHadithTheme.sajdahColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sajdah',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: quranHadithTheme.sajdahColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Page Number
                if (settings.showPageNumbers) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      'Page ${ayah.pageNumber}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppConstants.spacingMD),

            // Bismillah (recited before verse 1)
            if (settings.showBismillah &&
                ayah.numberInSurah == 1 &&
                ayah.surahNumber != 1 &&
                ayah.surahNumber != 9) ...[
              _buildBismillah(context),
              const SizedBox(height: AppConstants.spacingMD),
            ],

            // Arabic Text
            if (ayah.text.isNotEmpty && settings.showArabic) ...[
              Text(
                ayah.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Uthmani',
                  fontSize: isHighlighted
                      ? settings.fontSizeArabic + 2
                      : settings.fontSizeArabic,
                  height: 2.0,
                  fontWeight:
                      isHighlighted ? FontWeight.w900 : FontWeight.w400,
                  color: isHighlighted ? theme.colorScheme.primary : null,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: AppConstants.spacingMD),
            ],

            // Translation
            if (showTranslation &&
                settings.showTranslation &&
                translationText != null &&
                translationText!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
                child: Text(
                  translationText!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: settings.translationFontSize,
                    height: 1.6,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBismillah(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: quranHadithTheme.bismillahColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
        border: Border.all(
            color: quranHadithTheme.bismillahColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'Uthmani',
              fontSize: settings.fontSize + 2,
              height: 2.0,
              color: quranHadithTheme.bismillahColor,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: theme.textTheme.bodySmall?.copyWith(
              color: quranHadithTheme.bismillahColor.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Compact ayah item for search results
class CompactAyahListItem extends StatelessWidget {
  final Ayah ayah;
  final String query;
  final VoidCallback onTap;

  const CompactAyahListItem({
    super.key,
    required this.ayah,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(
                    '${ayah.surahNumber}:${ayah.numberInSurah}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (ayah.isSajdah)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          theme.quranHadith.sajdahColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      'Sajdah',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.quranHadith.sajdahColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              ayah.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'Uthmani',
                fontSize: 20,
                height: 1.8,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
