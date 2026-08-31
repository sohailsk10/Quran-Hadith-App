/// Hadith topic page with related hadiths

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/hadith_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/hadith/hadith_list_item.dart';

class HadithTopicPage extends ConsumerStatefulWidget {
  final String topicId;

  const HadithTopicPage({super.key, required this.topicId});

  @override
  ConsumerState<HadithTopicPage> createState() => _HadithTopicPageState();
}

class _HadithTopicPageState extends ConsumerState<HadithTopicPage> with SingleTickerProviderStateMixin {
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

    return AppScaffold(
      title: 'Topic',
      child: Consumer(
        builder: (context, ref, _) {
          final topicAsync = ref.watch(hadithTopicProvider(widget.topicId));
          final hadithsAsync = ref.watch(hadithsByTopicProvider(widget.topicId));
          final settings = ref.watch(settingsProvider);

          return topicAsync.when(
            data: (topic) => Column(
              children: [
                // Topic Header
                _buildTopicHeader(topic),

                // Tab Bar
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Hadiths'),
                    Tab(text: 'Related Topics'),
                  ],
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHadithsTab(hadithsAsync, settings),
                      _buildRelatedTopicsTab(settings),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error),
          );
        },
      ),
    );
  }

  Widget _buildTopicHeader(HadithTopic topic) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingMD),
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        gradient: quranHadithTheme.hadithGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [
          BoxShadow(
            color: quranHadithTheme.hadithGradient.colors.first.withValues(alpha: 0.3),
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
                child: Icon(
                  _getTopicIcon(topic.name),
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getGradeColor(topic.grade).withValues(alpha: 0.2),
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
                  ],
                ),
              ),
            ],
          ),
          if (topic.description.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              topic.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.6,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            children: [
              _StatChip(
                icon: Icons.article_outlined,
                label: '${topic.hadithCount} Hadiths',
              ),
              const SizedBox(width: AppConstants.spacingMD),
              _StatChip(
                icon: Icons.collections_bookmark_outlined,
                label: '${topic.collectionCount} Collections',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHadithsTab(AsyncValue<List<Hadith>> hadithsAsync, AsyncValue<AppSettings> settingsAsync) {
    return settingsAsync.when(
      data: (settings) => hadithsAsync.when(
        data: (hadiths) {
          if (hadiths.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(hadithsByTopicProvider(widget.topicId)),
            child: AnimationLimiter(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                itemCount: hadiths.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingSM),
                itemBuilder: (context, index) {
                  final hadith = hadiths[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: AppConstants.fastAnimation,
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: HadithListItem(
                          hadith: hadith,
                          settings: settings,
                          onTap: () => context.go('/hadith/collection/${hadith.collectionId}/hadith/${hadith.hadithNumber}'),
                          onLongPress: () => _showHadithActions(context, hadith),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading settings')),
    );
  }

  Widget _buildRelatedTopicsTab(AsyncValue<AppSettings> settingsAsync) {
    return settingsAsync.when(
      data: (settings) => Consumer(
        builder: (context, ref, _) {
          final relatedTopicsAsync = ref.watch(relatedTopicsProvider(widget.topicId));
          return relatedTopicsAsync.when(
            data: (topics) {
              if (topics.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.topic_outlined,
                  title: 'No Related Topics',
                  subtitle: 'No related topics found for this category',
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.refresh(relatedTopicsProvider(widget.topicId)),
                child: AnimationLimiter(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppConstants.spacingMD),
                    itemCount: topics.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMD),
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: AppConstants.mediumAnimation,
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _RelatedTopicCard(
                              topic: topic,
                              onTap: () => context.go('/hadith/topic/${topic.id}'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading settings')),
    );
  }

  Widget _buildEmptyState({
    IconData icon = Icons.topic_outlined,
    String title = 'No Hadiths Found',
    String subtitle = 'No hadiths available for this topic',
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLG),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
            onPressed: () {
              ref.refresh(hadithTopicProvider(widget.topicId));
              ref.refresh(hadithsByTopicProvider(widget.topicId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showHadithActions(BuildContext context, Hadith hadith) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _HadithActionsSheet(hadith: hadith),
    );
  }

  IconData _getTopicIcon(String topicName) {
    final name = topicName.toLowerCase();
    if (name.contains('prayer') || name.contains('salah')) return Icons.accessibility;
    if (name.contains('fast') || name.contains('sawm')) return Icons.wb_sunny_outlined;
    if (name.contains('charity') || name.contains('zakat')) return Icons.volunteer_activism;
    if (name.contains('hajj') || name.contains('pilgrim')) return Icons.flight;
    if (name.contains('faith') || name.contains('iman')) return Icons.favorite;
    if (name.contains('knowledge') || name.contains('ilm')) return Icons.school;
    if (name.contains('manners') || name.contains('akhlaq')) return Icons.psychology;
    if (name.contains('family') || name.contains('marriage')) return Icons.family_restroom;
    if (name.contains('business') || name.contains('trade')) return Icons.business;
    if (name.contains('death') || name.contains('funeral')) return Icons.bedtime;
    return Icons.topic;
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
      case HadithGrade.mursal:
        return Colors.purple;
      case HadithGrade.muttasil:
        return Colors.blue;
      case HadithGrade.munqati:
        return Colors.teal;
      case HadithGrade.unknown:
        return Colors.grey;
    }
  }
}

class _RelatedTopicCard extends StatelessWidget {
  final HadithTopic topic;
  final VoidCallback onTap;

  const _RelatedTopicCard({required this.topic, required this.onTap});

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
      case HadithGrade.mursal:
        return Colors.purple;
      case HadithGrade.muttasil:
        return Colors.blue;
      case HadithGrade.munqati:
        return Colors.teal;
      case HadithGrade.unknown:
        return Colors.grey;
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HadithActionsSheet extends ConsumerWidget {
  final Hadith hadith;

  const _HadithActionsSheet({required this.hadith});

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
                children: [
                  Text(
                    hadith.formattedReference,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getGradeColor(hadith.grade).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      hadith.grade.arabicName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getGradeColor(hadith.grade),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLG),
                  Text(
                    hadith.getTranslation(settings.language.code),
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    textAlign: TextAlign.center,
                    textDirection: _getTextDirection(settings.language.code),
                  ),
                  const SizedBox(height: AppConstants.spacingLG),
                  _ActionTile(
                    icon: Icons.bookmark_add_outlined,
                    label: 'Bookmark',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(hadithBookmarksProvider.notifier).addBookmark(
                        HadithBookmark(
                          id: 'hadith_${hadith.collectionId}_${hadith.hadithNumber}_${DateTime.now().millisecondsSinceEpoch}',
                          collectionId: hadith.collectionId,
                          bookNumber: hadith.bookNumber,
                          hadithNumber: hadith.hadithNumber,
                          collectionName: '',
                          bookTitle: '',
                          hadithText: hadith.getTranslation(settings.language.code),
                          grade: hadith.grade,
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
                    label: 'Copy Text',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.translate_rounded,
                    label: 'Copy Arabic',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Arabic copied')),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share feature coming soon')),
                      );
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
      case HadithGrade.mursal:
        return Colors.purple;
      case HadithGrade.muttasil:
        return Colors.blue;
      case HadithGrade.munqati:
        return Colors.teal;
      case HadithGrade.unknown:
        return Colors.grey;
    }
  }

  TextDirection _getTextDirection(String languageCode) {
    const rtlLanguages = ['ar', 'ur', 'fa', 'ps', 'sd'];
    return rtlLanguages.contains(languageCode) ? TextDirection.rtl : TextDirection.ltr;
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