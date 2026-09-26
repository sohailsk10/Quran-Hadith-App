/// Search page for Quran and Hadith

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/quran_models.dart';
import '../../../shared/models/hadith_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/section_header.dart';

class SearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  final String? initialType;

  const SearchPage({super.key, this.initialQuery, this.initialType});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _currentQuery = widget.initialQuery ?? '';

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_currentQuery.trim().isEmpty) return;
    ref.read(quranSearchProvider(_currentQuery));
    ref.read(hadithSearchProvider(_currentQuery));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Search',
      showBackButton: false,
      child: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Quran'),
              Tab(text: 'Hadith'),
            ],
            onTap: (index) {
              _performSearch();
            },
          ),

          // Results
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllResults(),
                _buildQuranResults(),
                _buildHadithResults(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Quran verses or Hadith...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _currentQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _currentQuery = '');
                    ref.invalidate(quranSearchProvider(''));
                    ref.invalidate(hadithSearchProvider(''));
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
          filled: true,
        ),
        onChanged: (value) {
          setState(() => _currentQuery = value);
        },
        onSubmitted: (value) => _performSearch(),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildAllResults() {
    return Consumer(
      builder: (context, ref, _) {
        final quranResults = ref.watch(quranSearchProvider(_currentQuery));
        final hadithResults = ref.watch(hadithSearchProvider(_currentQuery));

        return _buildResultsList(quranResults, hadithResults);
      },
    );
  }

  Widget _buildQuranResults() {
    final searchAsync = ref.watch(quranSearchProvider(_currentQuery));

    return searchAsync.when(
      data: (results) => _buildQuranResultsList(results),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildHadithResults() {
    final searchAsync = ref.watch(hadithSearchProvider(_currentQuery));

    return searchAsync.when(
      data: (results) => _buildHadithResultsList(results),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildResultsList(AsyncValue<List<QuranSearchResult>> quranAsync,
      AsyncValue<List<Hadith>> hadithAsync) {
    if (_currentQuery.isEmpty) {
      return _buildEmptyState();
    }

    final quranData = quranAsync.valueOrNull;
    final hadithData = hadithAsync.valueOrNull;
    final isLoading = quranAsync.isLoading || hadithAsync.isLoading;
    final hasData = (quranData != null && quranData.isNotEmpty) ||
        (hadithData != null && hadithData.isNotEmpty);

    if (isLoading && !hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quranAsync.hasError && hadithAsync.hasError && !hasData) {
      return _buildErrorState(quranAsync.error ?? hadithAsync.error!);
    }

    final quranResults = quranData ?? [];
    final hadithResults = hadithData ?? [];

    if (!isLoading && quranResults.isEmpty && hadithResults.isEmpty) {
      if (quranAsync.hasError && !hadithAsync.hasValue) {
        return _buildErrorState(quranAsync.error!);
      }
      if (hadithAsync.hasError && !quranAsync.hasValue) {
        return _buildErrorState(hadithAsync.error!);
      }
      return _buildNoResultsState();
    }

    return RefreshIndicator(
      onRefresh: _performSearch,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        children: [
          if (quranResults.isNotEmpty) ...[
            SectionHeader(
              title: 'Quran Results',
              subtitle: '${quranResults.length} verses found',
            ),
            const SizedBox(height: AppConstants.spacingMD),
            ...quranResults.map((result) => _QuranSearchResultItem(
                  ayah: result,
                  query: _currentQuery,
                  onTap: () => context.go(
                      '/quran/surah/${result.ayah.surahNumber}/ayah/${result.ayah.ayahInSurah}'),
                )),
            const SizedBox(height: AppConstants.spacingLG),
          ],
          if (hadithResults.isNotEmpty) ...[
            SectionHeader(
              title: 'Hadith Results',
              subtitle: '${hadithResults.length} hadiths found',
            ),
            const SizedBox(height: AppConstants.spacingMD),
            ...hadithResults.map((hadith) => _HadithSearchResultItem(
                  hadith: hadith,
                  query: _currentQuery,
                  onTap: () => context.go(
                      '/hadith/collection/${hadith.collectionId}/hadith/${hadith.hadithNumber}'),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildQuranResultsList(List<QuranSearchResult> results) {
    if (_currentQuery.isEmpty) return _buildEmptyState();
    if (results.isEmpty) return _buildNoResultsState();

    return RefreshIndicator(
      onRefresh: _performSearch,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        children: results
            .map((result) => _QuranSearchResultItem(
                  ayah: result,
                  query: _currentQuery,
                  onTap: () => context.go(
                      '/quran/surah/${result.ayah.surahNumber}/ayah/${result.ayah.ayahInSurah}'),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildHadithResultsList(List<Hadith> results) {
    if (_currentQuery.isEmpty) return _buildEmptyState();
    if (results.isEmpty) return _buildNoResultsState();

    return RefreshIndicator(
      onRefresh: _performSearch,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        children: results
            .map((hadith) => _HadithSearchResultItem(
                  hadith: hadith,
                  query: _currentQuery,
                  onTap: () => context.go(
                      '/hadith/collection/${hadith.collectionId}/hadith/${hadith.hadithNumber}'),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_outlined,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            'Search Quran & Hadith',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'Enter keywords to find verses or hadiths',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingLG),
          _buildSearchSuggestions(),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_outlined,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            'No results found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'Try different keywords or check spelling',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      'Bismillah',
      'Al-Fatihah',
      'Patience',
      'Prayer',
      'Charity',
      'Forgiveness',
      'Paradise',
      'Hellfire',
    ];

    return Wrap(
      spacing: AppConstants.spacingSM,
      runSpacing: AppConstants.spacingSM,
      alignment: WrapAlignment.center,
      children: suggestions
          .map((suggestion) => ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  _searchController.text = suggestion;
                  setState(() => _currentQuery = suggestion);
                  _performSearch();
                },
              ))
          .toList(),
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
            onPressed: _performSearch,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Quran Search Result Item
class _QuranSearchResultItem extends StatelessWidget {
  final QuranSearchResult ayah;
  final String query;
  final VoidCallback onTap;

  const _QuranSearchResultItem({
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
                    '${ayah.ayah.surahNumber}:${ayah.ayah.ayahInSurah}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Surah ${ayah.surah.nameTransliteration}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (ayah.ayah.isSajdah)
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
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              ayah.ayah.textUthmani,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'Uthmani',
                fontSize: 20,
                height: 1.8,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            if (ayah.matchedText.isNotEmpty ||
                ayah.ayah.translations.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacingSM),
              Text(
                ayah.matchedText.isNotEmpty
                    ? ayah.matchedText
                    : ayah.ayah.getTranslation(ayah.translationId),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hadith Search Result Item
class _HadithSearchResultItem extends StatelessWidget {
  final Hadith hadith;
  final String query;
  final VoidCallback onTap;

  const _HadithSearchResultItem({
    required this.hadith,
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
                    color: _getGradeColor(hadith.grade).withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(
                    hadith.grade.arabicName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getGradeColor(hadith.grade),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Expanded(
                  child: Text(
                    hadith.formattedReference,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              hadith.getTranslation('en'),
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(HadithGrade grade) {
    switch (grade) {
      case HadithGrade.sahih:
        return const Color(0xFF006D4C);
      case HadithGrade.hasan:
        return const Color(0xFFD4A843);
      case HadithGrade.daif:
        return Colors.orange;
      case HadithGrade.mawdu:
        return Colors.red;
      case HadithGrade.munkar:
        return Colors.purple;
      case HadithGrade.mudtarib:
        return Colors.teal;
      case HadithGrade.muallal:
        return Colors.brown;
      case HadithGrade.unknown:
        return Colors.grey;
    }
  }
}
