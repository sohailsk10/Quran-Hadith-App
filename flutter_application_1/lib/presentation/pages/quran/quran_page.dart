/// Quran main page with Surah list, Juz navigation, and search

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/quran/surah_list_item.dart';
import '../../widgets/quran/juz_list_item.dart';
import '../../widgets/quran/quran_search_bar.dart';
import '../../widgets/quran/country_wise_translation_selector.dart';

class QuranPage extends ConsumerStatefulWidget {
  final int? initialJuz;
  final int? initialPage;

  const QuranPage({super.key, this.initialJuz, this.initialPage});

  @override
  ConsumerState<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends ConsumerState<QuranPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Navigate to initial juz/page if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialJuz != null) {
        _tabController.animateTo(1);
      } else if (widget.initialPage != null) {
        _tabController.animateTo(2);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return AppScaffold(
      title: 'Quran',
      showBackButton: false,
      child: settings.when(
        data: (settings) => Column(
          children: [
            // Search Bar
            QuranSearchBar(
              onSearch: (query) => context.go('/search?q=$query&type=quran'),
              onFilterTap: _showFilterBottomSheet,
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Surahs'),
                Tab(text: 'Juz'),
                Tab(text: 'Pages'),
              ],
              isScrollable: true,
              tabAlignment: TabAlignment.start,
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSurahsTab(),
                  _buildJuzTab(),
                  _buildPagesTab(),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSurahsTab() {
    final surahsAsync = ref.watch(surahsProvider);

    return surahsAsync.when(
      data: (surahs) => RefreshIndicator(
        onRefresh: () async => ref.refresh(surahsProvider),
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          itemCount: surahs.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppConstants.spacingXS),
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return SurahListItem(
              surah: surah,
              onTap: () => context.go('/quran/surah/${surah.number}'),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(surahsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJuzTab() {
    final juzAsync = ref.watch(juzsProvider);

    return juzAsync.when(
      data: (juzList) => RefreshIndicator(
        onRefresh: () async => ref.refresh(juzsProvider),
        child: ListView.separated(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          itemCount: juzList.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppConstants.spacingXS),
          itemBuilder: (context, index) {
            final juz = juzList[index];
            return JuzListItem(
              juz: juz,
              onTap: () => context.go('/quran/juz/${juz.number}'),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildPagesTab() {
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        itemCount: 604, // Total pages in Quran
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppConstants.spacingXS),
        itemBuilder: (context, index) {
          final pageNumber = index + 1;
          return _PageListItem(
            pageNumber: pageNumber,
            onTap: () => context.go('/quran/page/$pageNumber'),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(),
    );
  }
}

/// Page List Item
class _PageListItem extends StatelessWidget {
  final int pageNumber;
  final VoidCallback onTap;

  const _PageListItem({required this.pageNumber, required this.onTap});

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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Center(
                child: Text(
                  '$pageNumber',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
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
                    'Page $pageNumber',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    _getPageInfo(pageNumber),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _getPageInfo(int pageNumber) {
    if (pageNumber <= 2) return 'Al-Fatihah & Al-Baqarah (beginning)';
    if (pageNumber >= 603) return 'An-Nas (end)';
    return 'Tap to view page';
  }
}

/// Filter Bottom Sheet
class _FilterBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusLG),
          ),
        ),
        child: Column(
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

            // Sheet Title & Close button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLG,
                vertical: AppConstants.spacingSM,
              ),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: AppConstants.spacingSM),
                  Text(
                    'Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: settings.when(
                data: (settings) => ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.spacingLG),
                  children: [
                    // Translation Section
                    Row(
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppConstants.spacingSM),
                        Text(
                          'Translation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grouped by scholar / compiler country of origin',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMD),

                    // Country-wise Translation Selector
                    const CountryWiseTranslationSelector(),

                    const SizedBox(height: AppConstants.spacingXL),

                    // Reciter Section
                    Row(
                      children: [
                        Icon(
                          Icons.record_voice_over_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppConstants.spacingSM),
                        Text(
                          'Reciter',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingMD),
                    Consumer(
                      builder: (context, ref, _) {
                        final recitersAsync = ref.watch(recitersProvider);
                        return recitersAsync.when(
                          data: (reciters) => Wrap(
                            spacing: AppConstants.spacingSM,
                            runSpacing: AppConstants.spacingSM,
                            children: reciters.map((r) {
                              final isSelected =
                                  r.id == settings.audio.selectedReciterId;
                              return FilterChip(
                                label: Text(r.name),
                                selected: isSelected,
                                onSelected: (_) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .updateAudioSettings(
                                        settings.audio
                                            .copyWith(selectedReciterId: r.id),
                                      );
                                },
                                selectedColor:
                                    theme.colorScheme.primaryContainer,
                                checkmarkColor:
                                    theme.colorScheme.onPrimaryContainer,
                              );
                            }).toList(),
                          ),
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppConstants.spacingMD),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (_, __) =>
                              const Text('Error loading reciters'),
                        );
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingXL),

                    // Font Size Section
                    Row(
                      children: [
                        Icon(
                          Icons.format_size_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppConstants.spacingSM),
                        Text(
                          'Arabic Font Size',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Text(
                            '${settings.quranDisplay.fontSizeArabic.round()}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingSM),
                    Slider(
                      value: settings.quranDisplay.fontSizeArabic,
                      min: 12,
                      max: 40,
                      divisions: 28,
                      label: '${settings.quranDisplay.fontSizeArabic.toInt()}',
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).updateQuranDisplay(
                              settings.quranDisplay
                                  .copyWith(fontSizeArabic: value),
                            );
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingXXL),
                  ],
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
