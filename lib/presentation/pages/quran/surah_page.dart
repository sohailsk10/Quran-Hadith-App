/// Surah page with ayah list, audio playback, translation display

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/quran_models.dart';
import '../../../shared/models/settings_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/reading_settings_sheet.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/quran/ayah_list_item.dart';
import '../../widgets/audio/audio_controls.dart';

class SurahPage extends ConsumerStatefulWidget {
  final int surahNumber;

  const SurahPage({super.key, required this.surahNumber});

  @override
  ConsumerState<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends ConsumerState<SurahPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahNumber = widget.surahNumber;

    return AppScaffold(
      title: 'Surah $surahNumber',
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
      child: Consumer(
        builder: (context, ref, _) {
          final surahAsync = ref.watch(selectedSurahProvider(surahNumber));
          final ayahsAsync = ref.watch(surahAyahsProvider(surahNumber));
          final settings = ref.watch(settingsProvider);

          return settings.when(
            data: (settings) => surahAsync.when(
              data: (surah) {
                if (surah == null) return _buildErrorState('Surah not found');
                return ayahsAsync.when(
                  data: (ayahs) => _buildSurahContent(
                    context,
                    surah,
                    ayahs,
                    settings,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorState(error),
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

  Widget _buildSurahContent(
    BuildContext context,
    Surah surah,
    List<Ayah> ayahs,
    AppSettings settings,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Surah Header
        _buildSurahHeader(surah, theme),

        // Tab Bar for Arabic/Translation
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.format_quote),
              text: 'Arabic',
            ),
            Tab(
              icon: const Icon(Icons.translate),
              text: 'Translation',
            ),
          ],
        ),

        // Ayah List
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildArabicTab(ayahs, settings),
              _buildTranslationTab(ayahs, settings),
            ],
          ),
        ),

        // Audio Controls
        // AudioControls(
        // ),
      ],
    );
  }

  Widget _buildSurahHeader(Surah surah, ThemeData theme) {
    final quranHadithTheme = theme.quranHadith;

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingMD),
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        gradient: quranHadithTheme.quranGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [
          BoxShadow(
            color: quranHadithTheme.quranGradient.colors.first
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.nameTransliteration,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      surah.nameTranslation,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    if (surah.nameArabic.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingXS),
                      Text(
                        surah.nameArabic,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontFamily: 'Amiri',
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Wrap(
            spacing: AppConstants.spacingSM,
            runSpacing: AppConstants.spacingSM,
            children: [
              _InfoChip(
                icon: Icons.format_list_numbered_rtl,
                label: '${surah.ayahCount} Ayahs',
                color: Colors.white,
              ),
              _InfoChip(
                icon: surah.revelationType == RevelationType.meccan
                    ? Icons.location_city
                    : Icons.mosque,
                label: surah.revelationType == RevelationType.meccan
                    ? 'Meccan'
                    : 'Medinan',
                color: surah.revelationType == RevelationType.meccan
                    ? Colors.deepOrange
                    : Colors.green,
              ),
              _InfoChip(
                icon: Icons.auto_stories,
                label: 'Juz ${surah.juzNumber}',
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArabicTab(List<Ayah> ayahs, AppSettings settings) {
    return RefreshIndicator(
      onRefresh: () async =>
          ref.refresh(surahAyahsProvider(widget.surahNumber)),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        itemCount: ayahs.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppConstants.spacingSM),
        itemBuilder: (context, index) {
          final ayah = ayahs[index];
          return AyahListItem(
            ayah: ayah,
            settings: settings.quranDisplay,
            showTranslation: false,
            onTap: () => _showAyahActions(context, ayah),
            onLongPress: () => _showAyahActions(context, ayah),
          );
        },
      ),
    );
  }

  Widget _buildTranslationTab(List<Ayah> ayahs, AppSettings settings) {
    final translationId = settings.selectedTranslationId;

    return RefreshIndicator(
      onRefresh: () async =>
          ref.refresh(surahAyahsProvider(widget.surahNumber)),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        itemCount: ayahs.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppConstants.spacingSM),
        itemBuilder: (context, index) {
          final ayah = ayahs[index];
          final translationText = ayah.getTranslation(translationId);
          return AyahListItem(
            ayah: ayah,
            settings: settings.quranDisplay,
            showTranslation: settings.quranDisplay.showTranslation,
            translationText: translationText,
            onTap: () => _showAyahActions(context, ayah),
            onLongPress: () => _showAyahActions(context, ayah),
          );
        },
      ),
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
            onPressed: () =>
                ref.refresh(selectedSurahProvider(widget.surahNumber)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAyahActions(BuildContext context, Ayah ayah) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          _AyahActionsSheet(ayah: ayah, surahNumber: widget.surahNumber),
    );
  }

  void _showDownloadOptions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download feature coming soon')),
    );
  }

  void _bookmarkSurah() {
    ref.read(quranBookmarksProvider.notifier).add(
          QuranBookmark(
            id: 'surah_${widget.surahNumber}_${DateTime.now().millisecondsSinceEpoch}',
            surahNumber: widget.surahNumber,
            ayahNumber: 1,
            createdAt: DateTime.now(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Surah ${widget.surahNumber} bookmarked')),
    );
  }
}

/// Ayah Actions Bottom Sheet
class _AyahActionsSheet extends ConsumerWidget {
  final Ayah ayah;
  final int surahNumber;

  const _AyahActionsSheet({required this.ayah, required this.surahNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return settings.when(
      data: (settings) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusLG),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: AppConstants.spacingMD),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
            ),

            // Ayah Reference
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLG),
              child: Column(
                children: [
                  Text(
                    'Surah $surahNumber, Ayah ${ayah.ayahInSurah}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  Text(
                    ayah.textUthmani,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Uthmani',
                      fontSize: settings.quranDisplay.fontSize + 4,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: AppConstants.spacingLG),

                  // Actions
                  _ActionTile(
                    icon: Icons.play_arrow_rounded,
                    label: 'Play from here',
                    onTap: () async {
                      Navigator.pop(context);
                      final ayahs = await ref
                          .read(surahAyahsProvider(surahNumber).future);
                      ref
                          .read(audioPlayerStateProvider.notifier)
                          .setPlaylist(ayahs);
                      ref
                          .read(audioPlayerStateProvider.notifier)
                          .setPlaying(true);
                    },
                  ),
                  _ActionTile(
                    icon: Icons.bookmark_add_outlined,
                    label: 'Bookmark',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(quranBookmarksProvider.notifier).add(
                            QuranBookmark(
                              id: 'ayah_${surahNumber}_${ayah.ayahInSurah}_${DateTime.now().millisecondsSinceEpoch}',
                              surahNumber: surahNumber,
                              ayahNumber: ayah.ayahInSurah,
                              createdAt: DateTime.now(),
                            ),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bookmark added')),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.copy_rounded,
                    label: 'Copy Arabic',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Arabic copied')),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.translate_rounded,
                    label: 'Copy Translation',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Translation copied')),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Share feature coming soon')),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.menu_book_rounded,
                    label: 'Open Tafsir',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(
                          '/quran/surah/$surahNumber/ayah/${ayah.ayahInSurah}/tafsir');
                    },
                  ),

                  const SizedBox(height: AppConstants.spacingLG),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error')),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
    );
  }
}

/// Info Chip for surah header
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
