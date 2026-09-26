/// Ayah detail page with full ayah, translation, tafsir, and audio

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/quran_audio_api_service.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/quran_models.dart';
import '../../../shared/models/settings_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/reading_settings_sheet.dart';
import '../../widgets/audio/country_wise_reciter_selector.dart';
import '../../widgets/audio/quran_audio_player_bar.dart';

class AyahDetailPage extends ConsumerStatefulWidget {
  final int surahNumber;
  final int ayahNumber;

  const AyahDetailPage(
      {super.key, required this.surahNumber, required this.ayahNumber});

  @override
  ConsumerState<AyahDetailPage> createState() => _AyahDetailPageState();
}

class _AyahDetailPageState extends ConsumerState<AyahDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ayah Detail',
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'Reading Settings',
          onPressed: () => showReadingSettingsSheet(
            context,
            ReadingSettingsMode.quran,
          ),
        ),
      ],
      child: Stack(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final ayahAsync =
                  ref.watch(ayahProvider((widget.surahNumber, widget.ayahNumber)));
              final tafsirAsync = ref
                  .watch(tafsirProvider((widget.surahNumber, widget.ayahNumber)));
              final settings = ref.watch(settingsProvider);

              return settings.when(
                data: (settings) => ayahAsync.when(
                  data: (ayah) {
                    if (ayah == null) {
                      return _buildErrorState('Ayah not found');
                    }
                    return tafsirAsync.when(
                      data: (tafsirs) => _buildDetailContent(
                        context,
                        ayah,
                        tafsirs,
                        settings,
                      ),
                      loading: () => _buildDetailContent(
                        context,
                        ayah,
                        [],
                        settings,
                      ),
                      error: (error, stack) => _buildDetailContent(
                        context,
                        ayah,
                        [],
                        settings,
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorState(error),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(error),
              );
            },
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: QuranAudioPlayerBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    Ayah ayah,
    List<Tafsir> tafsirs,
    AppSettings settings,
  ) {
    final selectedTranslationId = settings.selectedTranslationId;
    final translationText = ayah.getTranslation(selectedTranslationId);

    return Column(
      children: [
        // Ayah Detail Card
        _buildAyahCard(ayah, translationText, settings),

        // Tab Bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.translate), text: 'Translations'),
            Tab(icon: Icon(Icons.menu_book), text: 'Tafsir'),
            Tab(icon: Icon(Icons.hearing), text: 'Audio'),
          ],
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTranslationsTab(ayah, settings),
              _buildTafsirTab(tafsirs, settings),
              _buildAudioTab(ayah, settings),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAyahCard(Ayah ayah, String translation, AppSettings settings) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingMD),
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  '${ayah.surahNumber}:${ayah.ayahInSurah}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (ayah.isSajdah) ...[
                const SizedBox(width: AppConstants.spacingSM),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: quranHadithTheme.sajdahColor.withValues(alpha: 0.15),
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
              // Actions
              IconButton(
                onPressed: () => ref
                    .read(audioPlayerStateProvider.notifier)
                    .setPlaying(true),
                icon: const Icon(Icons.play_circle_outline_rounded),
                tooltip: 'Play audio',
              ),
              IconButton(
                onPressed: _bookmarkAyah,
                icon: const Icon(Icons.bookmark_add_outlined),
                tooltip: 'Bookmark',
              ),
              IconButton(
                onPressed: _shareAyah,
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share',
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingLG),

          // Arabic Text
          if (settings.quranDisplay.showArabic) ...[
            Text(
              ayah.textUthmani,
              style: theme.textTheme.displaySmall?.copyWith(
                fontFamily: 'Uthmani',
                fontSize: settings.quranDisplay.fontSizeArabic + 4,
                height: 2.0,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],

          if (settings.quranDisplay.showTranslation && translation.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingLG),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Text(
                translation,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: settings.quranDisplay.fontSizeTranslation + 2,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTranslationsTab(Ayah ayah, AppSettings settings) {
    return Consumer(
      builder: (context, ref, _) {
        final translationsAsync = ref.watch(translationsProvider);
        return translationsAsync.when(
          data: (translations) => ListView(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            children: translations.map((t) {
              final translationText = ayah.getTranslation(t.id);
              final isSelected = t.id == settings.selectedTranslationId;
              return _TranslationCard(
                translation: t,
                translationText: translationText,
                isSelected: isSelected,
                onTap: () {
                  ref.read(settingsProvider.notifier).updateTranslation(t.id);
                },
              );
            }).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Error loading translations'),
        );
      },
    );
  }

  Widget _buildTafsirTab(List<Tafsir> tafsirs, AppSettings settings) {
    if (tafsirs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No Tafsir available for this ayah'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(
                  tafsirProvider((widget.surahNumber, widget.ayahNumber))),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      itemCount: tafsirs.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppConstants.spacingMD),
      itemBuilder: (context, index) {
        return _TafsirCard(tafsir: tafsirs[index]);
      },
    );
  }

  Widget _buildAudioTab(Ayah ayah, AppSettings settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ayah Audio Player Card
          _buildAyahAudioPlayer(ayah),

          const SizedBox(height: AppConstants.spacingLG),

          // Reciter Selection Grouped by Country
          Text(
            'Reciter (Grouped by Country)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: const CountryWiseReciterSelector(),
          ),

          const SizedBox(height: AppConstants.spacingLG),

          // Playback Speed
          _buildPlaybackSpeedControl(),

          const SizedBox(height: 80), // Space for floating bottom bar
        ],
      ),
    );
  }

  Widget _buildAyahAudioPlayer(Ayah ayah) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, _) {
        final audioState = ref.watch(quranAudioApiProvider);
        final isThisAyah = audioState.surahNumber == widget.surahNumber &&
            audioState.ayahNumber == widget.ayahNumber;
        final isPlaying = isThisAyah && audioState.isPlaying;
        final isLoading = isThisAyah && audioState.isLoading;

        final pos = isThisAyah ? audioState.position : Duration.zero;
        final dur = isThisAyah ? audioState.duration : Duration.zero;
        final maxSeconds =
            dur.inMilliseconds > 0 ? dur.inMilliseconds.toDouble() : 1.0;
        final currentSeconds =
            pos.inMilliseconds.toDouble().clamp(0.0, maxSeconds);

        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            border: Border.all(
              color: isPlaying
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.volume_up_rounded : Icons.headphones_rounded,
                      color: isPlaying
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verse ${widget.surahNumber}:${widget.ayahNumber}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          audioState.currentReciterName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  else
                    IconButton.filled(
                      icon: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 28,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          ref.read(quranAudioApiProvider.notifier).pause();
                        } else if (isThisAyah && audioState.hasTrack) {
                          ref.read(quranAudioApiProvider.notifier).resume();
                        } else {
                          ref.read(quranAudioApiProvider.notifier).playAyah(
                                surahNumber: widget.surahNumber,
                                ayahNumber: widget.ayahNumber,
                                surahName: 'Surah ${widget.surahNumber}',
                              );
                        }
                      },
                    ),
                ],
              ),
              if (isThisAyah && dur.inMilliseconds > 0) ...[
                const SizedBox(height: AppConstants.spacingMD),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: currentSeconds,
                    max: maxSeconds,
                    onChanged: (val) {
                      ref.read(quranAudioApiProvider.notifier).seek(
                            Duration(milliseconds: val.round()),
                          );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(pos),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _formatTime(dur),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildPlaybackSpeedControl() {
    return Consumer(
      builder: (context, ref, _) {
        final audioState = ref.watch(quranAudioApiProvider);
        final speeds = [
          PlaybackSpeed.x0_5,
          PlaybackSpeed.x0_75,
          PlaybackSpeed.x1_0,
          PlaybackSpeed.x1_25,
          PlaybackSpeed.x1_5,
          PlaybackSpeed.x2_0,
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Playback Speed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Wrap(
              spacing: AppConstants.spacingSM,
              runSpacing: AppConstants.spacingSM,
              children: speeds.map((speed) {
                final isSelected =
                    (audioState.speed - speed.value).abs() < 0.05;
                return FilterChip(
                  label: Text(speed.label),
                  selected: isSelected,
                  onSelected: (_) {
                    ref
                        .read(quranAudioApiProvider.notifier)
                        .setSpeed(speed.value);
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref
                .refresh(ayahProvider((widget.surahNumber, widget.ayahNumber))),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _bookmarkAyah() {
    ref.read(quranBookmarksProvider.notifier).add(
          QuranBookmark(
            id: 'ayah_${widget.surahNumber}_${widget.ayahNumber}_${DateTime.now().millisecondsSinceEpoch}',
            surahNumber: widget.surahNumber,
            ayahNumber: widget.ayahNumber,
            createdAt: DateTime.now(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Ayah ${widget.surahNumber}:${widget.ayahNumber} bookmarked')),
    );
  }

  void _shareAyah() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon')),
    );
  }
}

/// Translation Card
class _TranslationCard extends StatelessWidget {
  final TranslationInfo translation;
  final String translationText;
  final bool isSelected;
  final VoidCallback onTap;

  const _TranslationCard({
    required this.translation,
    required this.translationText,
    required this.isSelected,
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
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
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
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(
                    translation.language.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Expanded(
                  child: Text(
                    translation.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              translationText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                height: 1.6,
              ),
              textDirection: _getTextDirection(translation.language),
            ),
          ],
        ),
      ),
    );
  }

  TextDirection _getTextDirection(String languageCode) {
    const rtlLanguages = ['ar', 'ur', 'fa', 'ps', 'sd'];
    return rtlLanguages.contains(languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}

/// Tafsir Card
class _TafsirCard extends StatelessWidget {
  final Tafsir tafsir;

  const _TafsirCard({required this.tafsir});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
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
                    tafsir.sourceName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  tafsir.language.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              tafsir.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
