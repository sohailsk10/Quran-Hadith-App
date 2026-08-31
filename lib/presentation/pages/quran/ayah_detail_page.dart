/// Ayah detail page with full ayah, translation, tafsir, and audio

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/quran.dart' as quran;
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/quran_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/quran/ayah_detail_card.dart';
import '../../widgets/quran/tafsir_card.dart';
import '../../widgets/audio/audio_controls.dart';

class AyahDetailPage extends ConsumerStatefulWidget {
  final int surahNumber;
  final int ayahNumber;

  const AyahDetailPage({super.key, required this.surahNumber, required this.ayahNumber});

  @override
  ConsumerState<AyahDetailPage> createState() => _AyahDetailPageState();
}

class _AyahDetailPageState extends ConsumerState<AyahDetailPage> with SingleTickerProviderStateMixin {
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
    final theme = Theme.of(context);

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
          final ayahAsync = ref.watch(ayahProvider(widget.surahNumber, widget.ayahNumber));
          final translationAsync = ref.watch(ayahTranslationProvider(widget.surahNumber, widget.ayahNumber));
          final tafsirAsync = ref.watch(tafsirProvider(widget.surahNumber, widget.ayahNumber));
          final settings = ref.watch(settingsProvider);
          final audioState = ref.watch(audioPlayerProvider);

          return settings.when(
            data: (settings) => ayahAsync.when(
              data: (ayah) => translationAsync.when(
                data: (translations) => tafsirAsync.when(
                  data: (tafsirs) => _buildDetailContent(
                    context,
                    ayah,
                    translations,
                    tafsirs,
                    settings,
                    audioState,
                  ),
                  loading: () => _buildDetailContent(
                    context,
                    ayah,
                    translations,
                    [],
                    settings,
                    audioState,
                  ),
                  error: (error, stack) => _buildDetailContent(
                    context,
                    ayah,
                    translations,
                    [],
                    settings,
                    audioState,
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(error),
              ),
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
    Map<String, List<TranslationInfo>> translations,
    List<Tafsir> tafsirs,
    AppSettings settings,
    AudioPlayerState audioState,
  ) {
    final theme = Theme.of(context);
    final selectedTranslationId = settings.selectedTranslationId;
    final selectedTranslation = translations[selectedTranslationId]?.firstWhere(
      (t) => t.ayahNumber == ayah.numberInSurah,
      orElse: () => TranslationInfo(
        id: selectedTranslationId,
        name: 'Translation',
        languageCode: 'en',
        ayahNumber: ayah.numberInSurah,
        text: '',
      ),
    );

    return Column(
      children: [
        // Ayah Detail Card
        AyahDetailCard(
          ayah: ayah,
          translation: selectedTranslation?.text ?? '',
          settings: settings,
          surahName: quran.getSurahName(widget.surahNumber),
          onPlay: () => ref.read(audioPlayerProvider.notifier).playAyah(widget.surahNumber, widget.ayahNumber),
          onBookmark: _bookmarkAyah,
          onShare: _shareAyah,
        ),

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
              _buildTranslationsTab(translations, settings),
              _buildTafsirTab(tafsirs, settings),
              _buildAudioTab(ayah, audioState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTranslationsTab(
    Map<String, List<TranslationInfo>> translations,
    AppSettings settings,
  ) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      children: translations.entries.map((entry) {
        final translation = entry.value.firstWhere(
          (t) => t.ayahNumber == widget.ayahNumber,
          orElse: () => TranslationInfo(
            id: entry.key,
            name: entry.key,
            languageCode: 'en',
            ayahNumber: widget.ayahNumber,
            text: '',
          ),
        );
        return _TranslationCard(
          translation: translation,
          isSelected: entry.key == settings.selectedTranslationId,
          onTap: () {
            ref.read(settingsProvider.notifier).updateTranslation(entry.key);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  Widget _buildTafsirTab(List<Tafsir> tafsirs, AppSettings settings) {
    if (tafsirs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No Tafsir available for this ayah'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(tafsirProvider(widget.surahNumber, widget.ayahNumber)),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      itemCount: tafsirs.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMD),
      itemBuilder: (context, index) {
        return TafsirCard(tafsir: tafsirs[index]);
      },
    );
  }

  Widget _buildAudioTab(Ayah ayah, AudioPlayerState audioState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Column(
        children: [
          // Reciter Selection
          _buildReciterSelector(),

          const SizedBox(height: AppConstants.spacingLG),

          // Audio Controls
          AudioControls(
            surahNumber: widget.surahNumber,
            ayahs: [ayah],
            initialAyahIndex: 0,
          ),

          const SizedBox(height: AppConstants.spacingLG),

          // Playback Speed
          _buildPlaybackSpeedControl(audioState),

          const SizedBox(height: AppConstants.spacingLG),

          // Repeat Options
          _buildRepeatOptions(audioState),
        ],
      ),
    );
  }

  Widget _buildReciterSelector() {
    return Consumer(
      builder: (context, ref, _) {
        final recitersAsync = ref.watch(recitersProvider);
        final settings = ref.watch(settingsProvider);

        return settings.when(
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
                    separatorBuilder: (_, __) => const SizedBox(width: AppConstants.spacingMD),
                    itemBuilder: (context, index) {
                      final reciter = reciters[index];
                      final isSelected = reciter.id == settings.audio.selectedReciterId;
                      return InkWell(
                        onTap: () {
                          ref.read(settingsProvider.notifier).updateAudioSettings(
                            settings.audio.copyWith(selectedReciterId: reciter.id),
                          );
                        },
                        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(AppConstants.spacingMD),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimaryContainer
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: AppConstants.spacingXS),
                              Text(
                                reciter.name,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSurface,
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
        );
      },
    );
  }

  Widget _buildPlaybackSpeedControl(AudioPlayerState audioState) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

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
              label: Text('${speed}x'),
              selected: isSelected,
              onSelected: (_) {
                ref.read(audioPlayerProvider.notifier).setPlaybackSpeed(speed);
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRepeatOptions(AudioPlayerState audioState) {
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
          children: RepeatMode.values.map((mode) {
            final isSelected = audioState.repeatMode == mode;
            return FilterChip(
              label: Text(_getRepeatModeLabel(mode)),
              selected: isSelected,
              onSelected: (_) {
                ref.read(audioPlayerProvider.notifier).setRepeatMode(mode);
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getRepeatModeLabel(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return 'Off';
      case RepeatMode.one:
        return 'Repeat One';
      case RepeatMode.all:
        return 'Repeat All';
      case RepeatMode.ayah:
        return 'Repeat Ayah';
      case RepeatMode.surah:
        return 'Repeat Surah';
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
            onPressed: () => ref.refresh(ayahProvider(widget.surahNumber, widget.ayahNumber)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _bookmarkAyah() {
    ref.read(quranBookmarksProvider.notifier).addBookmark(
      QuranBookmark(
        id: 'ayah_${widget.surahNumber}_${widget.ayahNumber}_${DateTime.now().millisecondsSinceEpoch}',
        surahNumber: widget.surahNumber,
        ayahNumber: widget.ayahNumber,
        surahName: quran.getSurahName(widget.surahNumber),
        ayahText: '',
        createdAt: DateTime.now(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ayah ${widget.surahNumber}:${widget.ayahNumber} bookmarked')),
    );
  }

  void _shareAyah() {
    // TODO: Implement share
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon')),
    );
  }
}

/// Translation Card
class _TranslationCard extends StatelessWidget {
  final TranslationInfo translation;
  final bool isSelected;
  final VoidCallback onTap;

  const _TranslationCard({
    required this.translation,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(
                    translation.languageCode.toUpperCase(),
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
              translation.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                height: 1.6,
              ),
              textDirection: _getTextDirection(translation.languageCode),
            ),
          ],
        ),
      ),
    );
  }

  TextDirection _getTextDirection(String languageCode) {
    const rtlLanguages = ['ar', 'ur', 'fa', 'ps', 'sd'];
    return rtlLanguages.contains(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }
}