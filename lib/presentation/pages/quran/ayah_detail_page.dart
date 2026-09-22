/// Ayah detail page with full ayah, translation, tafsir, and audio

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/quran_models.dart';
import '../../../shared/models/settings_models.dart';
import '../../widgets/common/app_scaffold.dart';

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
          icon: const Icon(Icons.share_outlined),
          onPressed: () => _shareAyah(),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined),
          onPressed: () => _bookmarkAyah(),
        ),
      ],
      child: Consumer(
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
          Text(
            ayah.textUthmani,
            style: theme.textTheme.displaySmall?.copyWith(
              fontFamily: 'Uthmani',
              fontSize: settings.quranDisplay.fontSize + 4,
              height: 2.0,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),

          if (translation.isNotEmpty) ...[
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
                  fontSize: settings.quranDisplay.translationFontSize + 2,
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
        children: [
          // Reciter Selection
          _buildReciterSelector(),

          const SizedBox(height: AppConstants.spacingLG),

          // Audio Controls
          // AudioControls(
          // ),

          const SizedBox(height: AppConstants.spacingLG),

          // Playback Speed
          _buildPlaybackSpeedControl(),

          const SizedBox(height: AppConstants.spacingLG),

          // Repeat Options
          _buildRepeatOptions(),
        ],
      ),
    );
  }

  Widget _buildReciterSelector() {
    return Consumer(
      builder: (context, ref, _) {
        final recitersAsync = ref.watch(recitersProvider);
        final settingsAsync = ref.watch(settingsProvider);

        return settingsAsync.when(
          data: (settings) => recitersAsync.when(
            data: (reciters) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Reciter',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingMD),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: reciters.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppConstants.spacingMD),
                    itemBuilder: (context, index) {
                      final reciter = reciters[index];
                      final isSelected =
                          reciter.id == settings.audio.selectedReciterId;
                      return InkWell(
                        onTap: () {
                          ref
                              .read(settingsProvider.notifier)
                              .updateAudioSettings(
                                settings.audio
                                    .copyWith(selectedReciterId: reciter.id),
                              );
                        },
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMD),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(AppConstants.spacingMD),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMD),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                              const SizedBox(height: AppConstants.spacingXS),
                              Text(
                                reciter.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildPlaybackSpeedControl() {
    return Consumer(
      builder: (context, ref, _) {
        final audioState = ref.watch(audioPlayerStateProvider);
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
                final isSelected = audioState.playbackSpeed == speed;
                return FilterChip(
                  label: Text(speed.label),
                  selected: isSelected,
                  onSelected: (_) {
                    ref
                        .read(audioPlayerStateProvider.notifier)
                        .setPlaybackSpeed(speed);
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

  Widget _buildRepeatOptions() {
    return Consumer(
      builder: (context, ref, _) {
        final audioState = ref.watch(audioPlayerStateProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repeat Mode',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Wrap(
              spacing: AppConstants.spacingSM,
              runSpacing: AppConstants.spacingSM,
              children: AudioRepeatMode.values.map((mode) {
                final isSelected = audioState.repeatMode == mode;
                return FilterChip(
                  label: Text(_getRepeatModeLabel(mode)),
                  selected: isSelected,
                  onSelected: (_) {
                    ref
                        .read(audioPlayerStateProvider.notifier)
                        .setRepeatMode(mode);
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

  String _getRepeatModeLabel(AudioRepeatMode mode) {
    switch (mode) {
      case AudioRepeatMode.none:
        return 'Off';
      case AudioRepeatMode.ayah:
        return 'Repeat Ayah';
      case AudioRepeatMode.surah:
        return 'Repeat Surah';
      case AudioRepeatMode.all:
        return 'Repeat All';
    }
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
