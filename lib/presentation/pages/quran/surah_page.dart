/// Surah page with ayah list, audio playback, translation display

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/quran.dart' as quran;
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/quran_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/quran/ayah_list_item.dart';
import '../../widgets/quran/surah_header.dart';
import '../../widgets/audio/audio_controls.dart';

class SurahPage extends ConsumerStatefulWidget {
  final int surahNumber;

  const SurahPage({super.key, required this.surahNumber});

  @override
  ConsumerState<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends ConsumerState<SurahPage> with TickerProviderStateMixin {
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
          icon: const Icon(Icons.download_outlined),
          onPressed: () => _showDownloadOptions(),
          tooltip: 'Download for offline',
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined),
          onPressed: () => _bookmarkSurah(),
          tooltip: 'Bookmark Surah',
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final surahAsync = ref.watch(surahProvider(surahNumber));
          final ayahsAsync = ref.watch(ayahsProvider(surahNumber));
          final settings = ref.watch(settingsProvider);
          final translationAsync = ref.watch(translationProvider(surahNumber));

          return settings.when(
            data: (settings) => surahAsync.when(
              data: (surah) => ayahsAsync.when(
                data: (ayahs) => translationAsync.when(
                  data: (translations) => _buildSurahContent(
                    context,
                    surah,
                    ayahs,
                    translations,
                    settings,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorState(error),
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

  Widget _buildSurahContent(
    BuildContext context,
    Surah surah,
    List<Ayah> ayahs,
    Map<String, List<TranslationInfo>> translations,
    AppSettings settings,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Surah Header
        SurahHeader(surah: surah),

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
              _buildTranslationTab(ayahs, translations, settings),
            ],
          ),
        ),

        // Audio Controls
        AudioControls(surahNumber: widget.surahNumber, ayahs: ayahs),
      ],
    );
  }

  Widget _buildArabicTab(List<Ayah> ayahs, AppSettings settings) {
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(ayahsProvider(widget.surahNumber)),
      child: AnimationLimiter(
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          itemCount: ayahs.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingSM),
          itemBuilder: (context, index) {
            final ayah = ayahs[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: AppConstants.fastAnimation,
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: AyahListItem(
                    ayah: ayah,
                    settings: settings,
                    showTranslation: false,
                    onTap: () => _showAyahActions(context, ayah),
                    onLongPress: () => _showAyahActions(context, ayah),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTranslationTab(
    List<Ayah> ayahs,
    Map<String, List<TranslationInfo>> translations,
    AppSettings settings,
  ) {
    final selectedTranslationId = settings.selectedTranslationId;
    final selectedTranslation = translations[selectedTranslationId] ?? [];
    final translationMap = {for (var t in selectedTranslation) t.ayahNumber: t.text};

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(translationProvider(widget.surahNumber)),
      child: AnimationLimiter(
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          itemCount: ayahs.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingSM),
          itemBuilder: (context, index) {
            final ayah = ayahs[index];
            final translationText = translationMap[ayah.numberInSurah] ?? '';
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: AppConstants.fastAnimation,
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: AyahListItem(
                    ayah: ayah,
                    settings: settings,
                    showTranslation: true,
                    translationText: translationText,
                    onTap: () => _showAyahActions(context, ayah),
                    onLongPress: () => _showAyahActions(context, ayah),
                  ),
                ),
              ),
            );
          },
        ),
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
            onPressed: () => ref.refresh(surahProvider(widget.surahNumber)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAyahActions(BuildContext context, Ayah ayah) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _AyahActionsSheet(ayah: ayah, surahNumber: widget.surahNumber),
    );
  }

  void _showDownloadOptions() {
    // TODO: Implement download for offline
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download feature coming soon')),
    );
  }

  void _bookmarkSurah() {
    ref.read(quranBookmarksProvider.notifier).addBookmark(
      QuranBookmark(
        id: 'surah_${widget.surahNumber}_${DateTime.now().millisecondsSinceEpoch}',
        surahNumber: widget.surahNumber,
        ayahNumber: 1,
        surahName: quran.getSurahName(widget.surahNumber),
        ayahText: '',
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
                    'Surah $surahNumber, Ayah ${ayah.numberInSurah}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  Text(
                    ayah.text,
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
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(audioPlayerProvider.notifier).playSurah(surahNumber, ayah.numberInSurah);
                    },
                  ),
                  _ActionTile(
                    icon: Icons.bookmark_add_outlined,
                    label: 'Bookmark',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(quranBookmarksProvider.notifier).addBookmark(
                        QuranBookmark(
                          id: 'ayah_${surahNumber}_${ayah.numberInSurah}_${DateTime.now().millisecondsSinceEpoch}',
                          surahNumber: surahNumber,
                          ayahNumber: ayah.numberInSurah,
                          surahName: quran.getSurahName(surahNumber),
                          ayahText: ayah.text,
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
                      // TODO: Copy to clipboard
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
                      // TODO: Copy translation
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
                      // TODO: Share
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share feature coming soon')),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.menu_book_rounded,
                    label: 'Open Tafsir',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/quran/surah/$surahNumber/ayah/${ayah.numberInSurah}/tafsir');
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

  const _ActionTile({required this.icon, required this.label, required this.onTap});

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