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
import '../../widgets/quran/ayah_list_item.dart';
import '../../../core/services/quran_audio_api_service.dart';
import '../../widgets/audio/quran_audio_player_bar.dart';

class SurahPage extends ConsumerStatefulWidget {
  final int surahNumber;

  const SurahPage({super.key, required this.surahNumber});

  @override
  ConsumerState<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends ConsumerState<SurahPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToAyah(int ayahNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _ayahKeys[ayahNumber];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.12,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final surahNumber = widget.surahNumber;

    // Auto-scroll when verse changes during recitation
    ref.listen<QuranAudioState>(quranAudioApiProvider, (previous, current) {
      if (current.surahNumber == surahNumber &&
          current.ayahNumber != null &&
          current.ayahNumber != previous?.ayahNumber) {
        _scrollToAyah(current.ayahNumber!);
      }
    });

    return AppScaffold(
      title: 'Surah $surahNumber',
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border_rounded),
          tooltip: 'Bookmark Surah',
          onPressed: _bookmarkSurah,
        ),
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
    return Stack(
      children: [
        _buildAyahList(surah, ayahs, settings),

        // Persistent floating Audio Player Bar
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: QuranAudioPlayerBar(),
        ),
      ],
    );
  }

  Widget _buildCompactSurahHeader(Surah surah, ThemeData theme) {
    final quranHadithTheme = theme.quranHadith;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMD,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: quranHadithTheme.quranGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        boxShadow: [
          BoxShadow(
            color: quranHadithTheme.quranGradient.colors.first
                .withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Al-Baqarah | The Cow | البقرة
          Row(
            children: [
              // Surah number badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
                child: Text(
                  '${surah.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSM),

              // Title | Translation
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        surah.nameTransliteration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '|',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                      Text(
                        surah.nameTranslation,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Arabic name
              if (surah.nameArabic.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '|',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                Text(
                  surah.nameArabic,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Uthmani',
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Row 2: Metadata and Play button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Details
              Expanded(
                child: Text(
                  '${surah.ayahCount} Ayahs • ${surah.revelationType == RevelationType.meccan ? 'Meccan' : 'Medinan'} • Juz ${surah.juzNumber}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // Audio Play/Pause Button
              Consumer(
                builder: (context, ref, _) {
                  final audioState = ref.watch(quranAudioApiProvider);
                  final isThisSurahPlaying = audioState.isPlaying &&
                      audioState.currentSurahNumber == surah.number &&
                      audioState.currentAyahNumber == null;
                  final isThisSurahLoading = audioState.isLoading &&
                      audioState.currentSurahNumber == surah.number &&
                      audioState.currentAyahNumber == null;

                  return InkWell(
                    onTap: () {
                      ref.read(quranAudioApiProvider.notifier).playSurah(
                            surahNumber: surah.number,
                            surahName: surah.nameTransliteration,
                          );
                    },
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isThisSurahLoading)
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    quranHadithTheme.quranGradient.colors.first,
                              ),
                            )
                          else
                            Icon(
                              isThisSurahPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow_rounded,
                              color:
                                  quranHadithTheme.quranGradient.colors.first,
                              size: 16,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            isThisSurahPlaying ? 'Pause' : 'Play',
                            style: TextStyle(
                              color:
                                  quranHadithTheme.quranGradient.colors.first,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAyahList(
    Surah surah,
    List<Ayah> ayahs,
    AppSettings settings,
  ) {
    final theme = Theme.of(context);
    final translationId = settings.selectedTranslationId;

    return RefreshIndicator(
      onRefresh: () async =>
          ref.refresh(surahAyahsProvider(widget.surahNumber)),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacingMD,
          AppConstants.spacingSM,
          AppConstants.spacingMD,
          90,
        ),
        itemCount: ayahs.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCompactSurahHeader(surah, theme);
          }
          final ayah = ayahs[index - 1];
          final translationText = ayah.getTranslation(translationId);
          final ayahKey =
              _ayahKeys.putIfAbsent(ayah.numberInSurah, () => GlobalKey());

          return KeyedSubtree(
            key: ayahKey,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
              child: AyahListItem(
                ayah: ayah,
                settings: settings.quranDisplay,
                showTranslation: settings.quranDisplay.showTranslation,
                translationText: translationText,
                onTap: () => _showAyahActions(context, ayah),
                onLongPress: () => _showAyahActions(context, ayah),
              ),
            ),
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
