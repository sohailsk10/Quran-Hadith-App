/// Hadith main page with collections list and search

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'
import 'package:go_router/go_router.dart'
import '../../../core/theme/app_theme.dart'
import '../../../core/constants/app_constants.dart'
import '../../../presentation/providers/app_providers.dart'
import '../../widgets/common/app_scaffold.dart'
import '../../widgets/common/section_header.dart'
import '../../widgets/hadith/collection_card.dart'
import '../../widgets/hadith/hadith_search_bar.dart'

class HadithPage extends ConsumerStatefulWidget {
  const HadithPage({super.key})

  @override
  ConsumerState<HadithPage> createState() => _HadithPageState()
}

class _HadithPageState extends ConsumerState<HadithPage> with SingleTickerProviderStateMixin {
  late TabController _tabController
  final ScrollController _scrollController = ScrollController()

  @override
  void initState() {
    super.initState()
    _tabController = TabController(length: 2, vsync: this)
  }

  @override
  void dispose() {
    _tabController.dispose()
    _scrollController.dispose()
    super.dispose()
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context)

    return AppScaffold(
      title: 'Hadith',
      showBackButton: false,
      child: Column(
        children: [
          // Search Bar
          HadithSearchBar(
            onSearch: (query) => context.go('/search?q=$query&type=hadith'),
            onFilterTap: _showFilterBottomSheet,
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Collections'),
              Tab(text: 'Topics'),
            ],
            isScrollable: true,
            tabAlignment: TabAlignment.start,
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCollectionsTab(),
                _buildTopicsTab(),
              ],
            ),
          ),
        ],
      ),
    )
  }

  Widget _buildCollectionsTab() {
    final collectionsAsync = ref.watch(hadithCollectionsProvider)

    return collectionsAsync.when(
      data: (collections) => RefreshIndicator(
        onRefresh: () async => ref.refresh(hadithCollectionsProvider),
        child: AnimationLimiter(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            itemCount: collections.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMD),
            itemBuilder: (context, index) {
              final collection = collections[index]
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: CollectionCard(
                      collection: collection,
                      onTap: () => context.go('/hadith/collection/${collection.id}'),
                    ),
                  ),
                ),
              )
            },
          ),
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
              onPressed: () => ref.refresh(hadithCollectionsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    )
  }

  Widget _buildTopicsTab() {
    final topicsAsync = ref.watch(hadithTopicsProvider)

    return topicsAsync.when(
      data: (topics) => RefreshIndicator(
        onRefresh: () async => ref.refresh(hadithTopicsProvider),
        child: AnimationLimiter(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            itemCount: topics.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMD),
            itemBuilder: (context, index) {
              final topic = topics[index]
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _TopicCard(
                      topic: topic,
                      onTap: () => context.go('/hadith/topic/${topic.id}'),
                    ),
                  ),
                ),
              )
            },
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    )
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(),
    )
  }
}

/// Topic Card
class _TopicCard extends StatelessWidget {
  final HadithTopic topic
  final VoidCallback onTap

  const _TopicCard({required this.topic, required this.onTap})

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context)

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
              child: Icon(
                Icons.topic_outlined,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    topic.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGradeColor(topic.grade).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(
                    topic.grade.arabicName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getGradeColor(topic.grade),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  '${topic.hadithCount} hadiths',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
  }

  Color _getGradeColor(HadithGrade grade) {
    switch (grade) {
      case HadithGrade.sahih:
        return const Color(0xFF006D4C)
      case HadithGrade.hasan:
        return const Color(0xFFD4A843)
      case HadithGrade.daif:
        return Colors.orange
      case HadithGrade.mawdu:
        return Colors.red
      case HadithGrade.mursal:
        return Colors.purple
      case HadithGrade.muttasil:
        return Colors.blue
      case HadithGrade.munqati:
        return Colors.teal
      case HadithGrade.unknown:
        return Colors.grey
    }
  }
}

/// Filter Bottom Sheet
class _FilterBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context)
    final settings = ref.watch(settingsProvider)

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

            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLG),

                  // Grade Filter
                  Text(
                    'Minimum Grade',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  Wrap(
                    spacing: AppConstants.spacingSM,
                    runSpacing: AppConstants.spacingSM,
                    children: HadithGrade.values.where((g) => g != HadithGrade.unknown).map((grade) {
                      final isSelected = settings.hadithDisplay.minGrade.index <= grade.index
                      return FilterChip(
                        label: Text(grade.arabicName),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(settingsProvider.notifier).updateHadithDisplay(
                            settings.hadithDisplay.copyWith(minGrade: grade),
                          )
                          Navigator.pop(context)
                        },
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.onPrimaryContainer,
                      )
                    }).toList(),
                  ),

                  const SizedBox(height: AppConstants.spacingLG),

                  // Language Filter
                  Text(
                    'Language',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  Wrap(
                    spacing: AppConstants.spacingSM,
                    runSpacing: AppConstants.spacingSM,
                    children: AppLanguage.values.map((lang) {
                      final isSelected = lang == settings.language
                      return FilterChip(
                        label: Text(lang.name),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(settingsProvider.notifier).updateLanguage(lang)
                          Navigator.pop(context)
                        },
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.onPrimaryContainer,
                      )
                    }).toList(),
                  ),

                  const SizedBox(height: AppConstants.spacingLG),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading settings')),
    )
  }
}