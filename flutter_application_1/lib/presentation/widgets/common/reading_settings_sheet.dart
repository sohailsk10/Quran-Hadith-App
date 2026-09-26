/// Reading Settings Bottom Sheet
/// Slide-up panel with content toggles and font size sliders for reading pages.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/translation_country_mapper.dart';
import '../../../core/services/quran_audio_api_service.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/settings_models.dart';
import '../quran/country_wise_translation_selector.dart';
import '../audio/country_wise_reciter_selector.dart';

enum ReadingSettingsMode { quran, hadith }

/// Call this to show the reading settings sheet from any page.
void showReadingSettingsSheet(BuildContext context, ReadingSettingsMode mode) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ReadingSettingsSheet(mode: mode),
  );
}

class _ReadingSettingsSheet extends ConsumerWidget {
  final ReadingSettingsMode mode;

  const _ReadingSettingsSheet({required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: 200,
        child: Center(child: Text('Error: $e')),
      ),
      data: (settings) => _buildSheet(context, ref, theme, settings),
    );
  }

  Widget _buildSheet(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppSettings settings,
  ) {
    final isQuran = mode == ReadingSettingsMode.quran;
    final qd = settings.quranDisplay;
    final hd = settings.hadithDisplay;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLG,
            ),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Reading Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    if (isQuran) {
                      ref.read(settingsProvider.notifier).updateQuranDisplay(
                            const QuranDisplaySettings(),
                          );
                    } else {
                      ref.read(settingsProvider.notifier).updateHadithDisplay(
                            const HadithDisplaySettings(),
                          );
                    }
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable body
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLG,
                vertical: AppConstants.spacingMD,
              ),
              children: [
                // ── CONTENT section ──────────────────────────────
                _sectionLabel(theme, 'Content'),
                const SizedBox(height: AppConstants.spacingSM),

                if (isQuran) ...[
                  _CheckTile(
                    label: 'Show Arabic',
                    icon: Icons.text_fields_rounded,
                    value: qd.showArabic,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updateQuranDisplay(qd.copyWith(showArabic: v)),
                  ),
                  _CheckTile(
                    label: 'Show Translation',
                    icon: Icons.translate_rounded,
                    value: qd.showTranslation,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updateQuranDisplay(qd.copyWith(showTranslation: v)),
                  ),
                  _CheckTile(
                    label: 'Show Transliteration',
                    icon: Icons.abc_rounded,
                    value: qd.showTransliteration,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updateQuranDisplay(
                            qd.copyWith(showTransliteration: v)),
                  ),
                ] else ...[
                  _CheckTile(
                    label: 'Show Arabic',
                    icon: Icons.text_fields_rounded,
                    value: hd.showArabic,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updateHadithDisplay(hd.copyWith(showArabic: v)),
                  ),
                  _CheckTile(
                    label: 'Show Translation',
                    icon: Icons.translate_rounded,
                    value: hd.showTranslation,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updateHadithDisplay(hd.copyWith(showTranslation: v)),
                  ),
                ],

                // ── TRANSLATIONS section ─────────────────────────
                if (isQuran) ...[
                  const SizedBox(height: AppConstants.spacingLG),
                  _sectionLabel(theme, 'Translations'),
                  const SizedBox(height: AppConstants.spacingSM),
                  Consumer(
                    builder: (context, ref, _) {
                      final translationsAsync = ref.watch(translationsProvider);
                      final currentId = settings.selectedTranslationId;
                      final currentT = translationsAsync.valueOrNull
                          ?.where((t) => t.id == currentId)
                          .firstOrNull;
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMD),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMD),
                          child: ExpansionTile(
                            leading: const Icon(Icons.translate_rounded),
                            title: Text(
                              currentT != null
                                  ? '${currentT.countryFlag} ${currentT.name}'
                                  : 'Select Translation',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              currentT != null
                                  ? '${currentT.countryName} • ${currentT.languageName.toUpperCase()}'
                                  : 'Tap to choose country & translator',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(AppConstants.spacingMD),
                                child: CountryWiseTranslationSelector(
                                  showSearch: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // ── RECITATIONS (AUDIO) section ───────────────────
                if (isQuran) ...[
                  const SizedBox(height: AppConstants.spacingLG),
                  _sectionLabel(theme, 'Recitations (Audio)'),
                  const SizedBox(height: AppConstants.spacingSM),
                  Consumer(
                    builder: (context, ref, _) {
                      final recitersAsync = ref.watch(quranAudioRecitersProvider);
                      final audioState = ref.watch(quranAudioApiProvider);
                      final currentId = audioState.currentReciterId;

                      return recitersAsync.when(
                        data: (reciters) {
                          final allReciters = reciters.isNotEmpty
                              ? reciters
                              : <ReciterInfo>[];
                          final currentR = allReciters
                                  .where((r) => r.id == currentId)
                                  .firstOrNull ??
                              (allReciters.isNotEmpty ? allReciters.first : null);

                          if (currentR == null) {
                            return const SizedBox.shrink();
                          }

                          // Country flag mapping
                          final countryFlags = {
                            'Kuwait': '🇰🇼',
                            'Saudi Arabia': '🇸🇦',
                            'Egypt': '🇪🇬',
                            'Yemen': '🇾🇪',
                            'United Arab Emirates': '🇦🇪',
                            'Other': '🌐',
                          };
                          final flag = countryFlags[currentR.country] ?? '🌐';

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh,
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusMD),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusMD),
                              child: ExpansionTile(
                                leading:
                                    const Icon(Icons.record_voice_over_rounded),
                                title: Text(
                                  '$flag ${currentR.name}',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${currentR.country} • ${currentR.style.toUpperCase()}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(AppConstants.spacingMD),
                                    child: CountryWiseReciterSelector(
                                      showSearch: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),
                ],

                const SizedBox(height: AppConstants.spacingLG),

                // ── FONT SIZE section ────────────────────────────
                _sectionLabel(theme, 'Font Size'),
                const SizedBox(height: AppConstants.spacingSM),

                if (isQuran) ...[
                  _SliderTile(
                    label: 'Arabic Font Size',
                    value: qd.fontSizeArabic,
                    min: 14,
                    max: 40,
                    divisions: 26,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updateQuranDisplay(qd.copyWith(fontSizeArabic: v)),
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  _SliderTile(
                    label: 'Translation Font Size',
                    value: qd.fontSizeTranslation,
                    min: 10,
                    max: 28,
                    divisions: 18,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updateQuranDisplay(
                            qd.copyWith(fontSizeTranslation: v)),
                  ),
                ] else ...[
                  _SliderTile(
                    label: 'Arabic Font Size',
                    value: hd.arabicFontSize,
                    min: 14,
                    max: 40,
                    divisions: 26,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updateHadithDisplay(hd.copyWith(arabicFontSize: v)),
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  _SliderTile(
                    label: 'Translation Font Size',
                    value: hd.translationFontSize,
                    min: 10,
                    max: 28,
                    divisions: 18,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updateHadithDisplay(
                            hd.copyWith(translationFontSize: v)),
                  ),
                ],

                const SizedBox(height: AppConstants.spacingXL),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String label) {
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// A checkbox row tile
class _CheckTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// A slider row tile with label + current value
class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyLarge),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                value.round().toString(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
