/// Home page with quick access to Quran, Hadith, and features

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/quran_models.dart';
import '../../../shared/models/hadith_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/quran/surah_card.dart';
import '../../widgets/hadith/hadith_card.dart';
import '../../widgets/common/continue_reading_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;
    final settings = ref.watch(settingsProvider);

    return AppScaffold(
      title: 'Home',
      showBackButton: false,
      child: settings.when(
        data: (settings) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(surahsProvider);
            ref.invalidate(hadithCollectionsProvider);
            ref.invalidate(quranBookmarksProvider);
            ref.invalidate(readingProgressProvider);
            ref.invalidate(hadithBookmarksProvider);
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Greeting Section
              SliverToBoxAdapter(
                child: _buildGreetingSection(context, settings),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: _buildQuickActions(context),
              ),

              // Continue Reading (Quran)
              _buildContinueReadingSection(),

              // Recent Bookmarks (Quran)
              _buildQuranBookmarksSection(),

              // Hadith Collections
              _buildHadithCollectionsSection(),

              // Random Hadith
              _buildRandomHadithSection(),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spacingXXL)),
            ],
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
                onPressed: () => ref.invalidate(settingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) greeting = 'Good Morning';
    else if (hour < 17) greeting = 'Good Afternoon';
    else greeting = 'Good Evening';

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingMD),
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        gradient: quranHadithTheme.quranGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [
          BoxShadow(
            color: quranHadithTheme.quranGradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  'Read, Listen, Reflect',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    final actions = [
      QuickAction(
        icon: Icons.menu_book_rounded,
        label: 'Quran',
        subtitle: '114 Surahs',
        color: quranHadithTheme.quranGradient.colors.first,
        onTap: () => context.go('/quran'),
      ),
      QuickAction(
        icon: Icons.library_books_rounded,
        label: 'Hadith',
        subtitle: '9 Collections',
        color: quranHadithTheme.hadithGradient.colors.first,
        onTap: () => context.go('/hadith'),
      ),
      QuickAction(
        icon: Icons.search_rounded,
        label: 'Search',
        subtitle: 'Find verses/hadiths',
        color: theme.colorScheme.primary,
        onTap: () => context.go('/search'),
      ),
      QuickAction(
        icon: Icons.bookmark_rounded,
        label: 'Bookmarks',
        subtitle: 'Saved items',
        color: quranHadithTheme.bookmarkColor,
        onTap: () => context.go('/bookmarks'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Quick Access',
            onSeeAll: () => context.go('/quran'),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          SizedBox(
            height: 120,
            child: AnimationLimiter(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: actions.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppConstants.spacingMD),
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: AppConstants.mediumAnimation,
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _QuickActionCard(action: actions[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueReadingSection() {
    return SliverToBoxAdapter(
      child: Consumer(
        builder: (context, ref, _) {
          final progressAsync = ref.watch(readingProgressProvider);

          return progressAsync.when(
            data: (progressList) {
              if (progressList.isEmpty) return const SizedBox.shrink();

              final latest = progressList.first;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD, vertical: AppConstants.spacingMD),
                child: ContinueReadingCard(
                  surahNumber: latest.surahNumber,
                  ayahNumber: latest.ayahNumber,
                  lastRead: latest.lastRead,
                  onTap: () => context.go('/quran/surah/${latest.surahNumber}/ayah/${latest.ayahNumber}'),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildQuranBookmarksSection() {
    return SliverToBoxAdapter(
      child: Consumer(
        builder: (context, ref, _) {
          final bookmarksAsync = ref.watch(quranBookmarksProvider);

          return bookmarksAsync.when(
            data: (bookmarks) {
              if (bookmarks.isEmpty) return const SizedBox.shrink();

              final recentBookmarks = bookmarks.take(5).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Recent Bookmarks',
                      subtitle: '${bookmarks.length} saved',
                      onSeeAll: () => context.go('/bookmarks'),
                    ),
                    const SizedBox(height: AppConstants.spacingMD),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentBookmarks.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppConstants.spacingMD),
                        itemBuilder: (context, index) {
                          final bookmark = recentBookmarks[index];
                          return _BookmarkCard(
                            bookmark: bookmark,
                            onTap: () => context.go('/quran/surah/${bookmark.surahNumber}/ayah/${bookmark.ayahNumber}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildHadithCollectionsSection() {
    return SliverToBoxAdapter(
      child: Consumer(
        builder: (context, ref, _) {
          final collectionsAsync = ref.watch(hadithCollectionsProvider);

          return collectionsAsync.when(
            data: (collections) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Hadith Collections',
                      subtitle: '${collections.length} books',
                      onSeeAll: () => context.go('/hadith'),
                    ),
                    const SizedBox(height: AppConstants.spacingMD),
                    SizedBox(
                      height: 160,
                      child: AnimationLimiter(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: collections.length,
                          separatorBuilder: (_, __) => const SizedBox(width: AppConstants.spacingMD),
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: AppConstants.mediumAnimation,
                              child: SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: _CollectionCard(
                                    collection: collections[index],
                                    onTap: () => context.go('/hadith/collection/${collections[index].id}'),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildRandomHadithSection() {
    return SliverToBoxAdapter(
      child: Consumer(
        builder: (context, ref, _) {
          final randomHadithAsync = ref.watch(randomHadithProvider);

          return randomHadithAsync.when(
            data: (hadith) {
              if (hadith == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD, vertical: AppConstants.spacingMD),
                child: _RandomHadithCard(
                  hadith: hadith,
                  onTap: () => context.go('/hadith/collection/${hadith.collectionId}/hadith/${hadith.hadithNumber}'),
                  onRefresh: () => ref.refresh(randomHadithProvider),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

/// Quick Action Card
class _QuickActionCard extends StatelessWidget {
  final QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Icon(action.icon, color: action.color, size: 24),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              action.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              action.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

/// Bookmark Card
class _BookmarkCard extends StatelessWidget {
  final QuranBookmark bookmark;
  final VoidCallback onTap;

  const _BookmarkCard({required this.bookmark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getColor(bookmark.color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                '${bookmark.surahNumber}:${bookmark.ayahNumber}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getColor(bookmark.color),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Surah $bookmark.surahNumber',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              'Ayah $bookmark.ayahNumber',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (bookmark.note != null) ...[
              const SizedBox(height: AppConstants.spacingXS),
              Text(
                bookmark.note!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColor(BookmarkColor color) {
    switch (color) {
      case BookmarkColor.gold:
        return const Color(0xFFD4A843);
      case BookmarkColor.green:
        return const Color(0xFF006D4C);
      case BookmarkColor.blue:
        return Colors.blue;
      case BookmarkColor.red:
        return Colors.red;
      case BookmarkColor.purple:
        return Colors.purple;
      case BookmarkColor.orange:
        return Colors.orange;
    }
  }
}

/// Collection Card
class _CollectionCard extends StatelessWidget {
  final HadithCollection collection;
  final VoidCallback onTap;

  const _CollectionCard({required this.collection, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Icon(
                Icons.library_books_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              collection.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              collection.author,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${collection.totalHadiths} hadiths',
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
}

/// Random Hadith Card
class _RandomHadithCard extends StatelessWidget {
  final Hadith hadith;
  final VoidCallback onTap;
  final VoidCallback onRefresh;

  const _RandomHadithCard({
    required this.hadith,
    required this.onTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.casino_rounded, color: Colors.white.withValues(alpha: 0.9), size: 20),
                    const SizedBox(width: AppConstants.spacingXS),
                    Text(
                      'Hadith of the Day',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              hadith.getTranslation('en'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hadith.formattedReference,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(
                    hadith.grade.arabicName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}