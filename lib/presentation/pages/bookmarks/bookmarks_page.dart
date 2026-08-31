/// Bookmarks page with Quran and Hadith bookmarks

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
import '../../widgets/quran/bookmark_list_item.dart';
import '../../widgets/hadith/bookmark_list_item.dart';

class BookmarksPage extends ConsumerStatefulWidget {
  const BookmarksPage({super.key});

  @override
  ConsumerState<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends ConsumerState<BookmarksPage> with SingleTickerProviderStateMixin {
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
      title: 'Bookmarks',
      showBackButton: false,
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final quranBookmarks = ref.watch(quranBookmarksProvider);
            final hadithBookmarks = ref.watch(hadithBookmarksProvider);

            return quranBookmarks.when(
              data: (qBookmarks) => hadithBookmarks.when(
                data: (hBookmarks) {
                  if (qBookmarks.isEmpty && hBookmarks.isEmpty) return const SizedBox.shrink();
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'clear_quran') {
                        _showClearDialog('Quran', () => ref.read(quranBookmarksProvider.notifier).clearAll());
                      } else if (value == 'clear_hadith') {
                        _showClearDialog('Hadith', () => ref.read(hadithBookmarksProvider.notifier).clearAll());
                      } else if (value == 'clear_all') {
                        _showClearDialog('All', () {
                          ref.read(quranBookmarksProvider.notifier).clearAll();
                          ref.read(hadithBookmarksProvider.notifier).clearAll();
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      if (qBookmarks.isNotEmpty)
                        const PopupMenuItem(
                          value: 'clear_quran',
                          child: Row(
                            children: [
                              Icon(Icons.menu_book_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Clear Quran Bookmarks'),
                            ],
                          ),
                        ),
                      if (hBookmarks.isNotEmpty)
                        const PopupMenuItem(
                          value: 'clear_hadith',
                          child: Row(
                            children: [
                              Icon(Icons.library_books_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Clear Hadith Bookmarks'),
                            ],
                          ),
                        ),
                      if (qBookmarks.isNotEmpty && hBookmarks.isNotEmpty)
                        const PopupMenuItem(
                          value: 'clear_all',
                          child: Row(
                            children: [
                              Icon(Icons.delete_sweep_outlined, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Clear All', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
        ),
      ],
      child: Column(
        children: [
          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.menu_book_outlined), text: 'Quran'),
              Tab(icon: Icon(Icons.library_books_outlined), text: 'Hadith'),
              Tab(icon: Icon(Icons.favorite_outlined), text: 'Favorites'),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuranBookmarksTab(),
                _buildHadithBookmarksTab(),
                _buildFavoritesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranBookmarksTab() {
    final bookmarksAsync = ref.watch(quranBookmarksProvider);

    return bookmarksAsync.when(
      data: (bookmarks) {
        if (bookmarks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.menu_book_outlined,
            title: 'No Quran Bookmarks',
            subtitle: 'Bookmark verses while reading to see them here',
            actionLabel: 'Go to Quran',
            onAction: () => context.go('/quran'),
          );
        }

        // Group by surah
        final grouped = <int, List<QuranBookmark>>{};
        for (final bookmark in bookmarks) {
          grouped.putIfAbsent(bookmark.surahNumber, () => []).add(bookmark);
        }

        final sortedSurahs = grouped.keys.toList()..sort();

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(quranBookmarksProvider),
          child: AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              itemCount: sortedSurahs.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingLG),
              itemBuilder: (context, index) {
                final surahNumber = sortedSurahs[index];
                final surahBookmarks = grouped[surahNumber]!;
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: AppConstants.mediumAnimation,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _SurahBookmarkGroup(
                        surahNumber: surahNumber,
                        bookmarks: surahBookmarks,
                        onBookmarkTap: (bookmark) => context.go('/quran/surah/${bookmark.surahNumber}/ayah/${bookmark.ayahNumber}'),
                        onBookmarkDelete: (bookmark) => ref.read(quranBookmarksProvider.notifier).removeBookmark(bookmark.id),
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
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildHadithBookmarksTab() {
    final bookmarksAsync = ref.watch(hadithBookmarksProvider);

    return bookmarksAsync.when(
      data: (bookmarks) {
        if (bookmarks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.library_books_outlined,
            title: 'No Hadith Bookmarks',
            subtitle: 'Bookmark hadiths while reading to see them here',
            actionLabel: 'Go to Hadith',
            onAction: () => context.go('/hadith'),
          );
        }

        // Group by collection
        final grouped = <String, List<HadithBookmark>>{};
        for (final bookmark in bookmarks) {
          grouped.putIfAbsent(bookmark.collectionId, () => []).add(bookmark);
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(hadithBookmarksProvider),
          child: AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              itemCount: grouped.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingLG),
              itemBuilder: (context, index) {
                final collectionId = grouped.keys.elementAt(index);
                final collectionBookmarks = grouped[collectionId]!;
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: AppConstants.mediumAnimation,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _CollectionBookmarkGroup(
                        collectionId: collectionId,
                        bookmarks: collectionBookmarks,
                        onBookmarkTap: (bookmark) => context.go('/hadith/collection/${bookmark.collectionId}/book/${bookmark.bookNumber}/hadith/${bookmark.hadithNumber}'),
                        onBookmarkDelete: (bookmark) => ref.read(hadithBookmarksProvider.notifier).removeBookmark(bookmark.id),
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
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildFavoritesTab() {
    final quranBookmarks = ref.watch(quranBookmarksProvider);
    final hadithBookmarks = ref.watch(hadithBookmarksProvider);

    return quranBookmarks.when(
      data: (qBookmarks) => hadithBookmarks.when(
        data: (hBookmarks) {
          final favorites = [
            ...qBookmarks.where((b) => b.color == BookmarkColor.gold),
            ...hBookmarks.where((b) => b.color == BookmarkColor.gold),
          ];

          if (favorites.isEmpty) {
            return _buildEmptyState(
              icon: Icons.favorite_outlined,
              title: 'No Favorites',
              subtitle: 'Mark bookmarks as favorites (gold color) to see them here',
              actionLabel: 'Browse Content',
              onAction: () => context.go('/quran'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(quranBookmarksProvider);
              ref.refresh(hadithBookmarksProvider);
            },
            child: AnimationLimiter(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMD),
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: AppConstants.fastAnimation,
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: item is QuranBookmark
                            ? QuranBookmarkListItem(
                                bookmark: item,
                                onTap: () => context.go('/quran/surah/${item.surahNumber}/ayah/${item.ayahNumber}'),
                                onDelete: () => ref.read(quranBookmarksProvider.notifier).removeBookmark(item.id),
                              )
                            : HadithBookmarkListItem(
                                bookmark: item,
                                onTap: () => context.go('/hadith/collection/${item.collectionId}/book/${item.bookNumber}/hadith/${item.hadithNumber}'),
                                onDelete: () => ref.read(hadithBookmarksProvider.notifier).removeBookmark(item.id),
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
        error: (_, __) => _buildErrorState('Error loading hadith bookmarks'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildErrorState('Error loading quran bookmarks'),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
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
            const SizedBox(height: AppConstants.spacingLG),
            FilledButton.icon(
              icon: Icon(actionLabel == 'Go to Quran' ? Icons.menu_book : Icons.library_books),
              label: Text(actionLabel),
              onPressed: onAction,
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
              ref.refresh(quranBookmarksProvider);
              ref.refresh(hadithBookmarksProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(String type, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear $type Bookmarks?'),
        content: Text('This will permanently delete all $type bookmarks. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$type bookmarks cleared')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SurahBookmarkGroup extends StatelessWidget {
  final int surahNumber;
  final List<QuranBookmark> bookmarks;
  final Function(QuranBookmark) onBookmarkTap;
  final Function(QuranBookmark) onBookmarkDelete;

  const _SurahBookmarkGroup({
    required this.surahNumber,
    required this.bookmarks,
    required this.onBookmarkTap,
    required this.onBookmarkDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                'Surah $surahNumber',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Text(
              '${bookmarks.length} bookmark${bookmarks.length > 1 ? 's' : ''}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookmarks.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingSM),
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return QuranBookmarkListItem(
              bookmark: bookmark,
              onTap: () => onBookmarkTap(bookmark),
              onDelete: () => onBookmarkDelete(bookmark),
            );
          },
        ),
      ],
    );
  }
}

class _CollectionBookmarkGroup extends StatelessWidget {
  final String collectionId;
  final List<HadithBookmark> bookmarks;
  final Function(HadithBookmark) onBookmarkTap;
  final Function(HadithBookmark) onBookmarkDelete;

  const _CollectionBookmarkGroup({
    required this.collectionId,
    required this.bookmarks,
    required this.onBookmarkTap,
    required this.onBookmarkDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collectionNames = {
      'bukhari': 'Sahih al-Bukhari',
      'muslim': 'Sahih Muslim',
      'tirmidhi': 'Sunan al-Tirmidhi',
      'abu-dawud': 'Sunan Abi Dawud',
      'nasai': 'Sunan an-Nasa\'i',
      'ibn-majah': 'Sunan Ibn Majah',
      'malik': 'Muwatta Malik',
      'ahmad': 'Musnad Ahmad',
      'daraqutni': 'Sunan al-Daraqutni',
    };

    final collectionName = collectionNames[collectionId] ?? collectionId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                collectionName,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Text(
              '${bookmarks.length} bookmark${bookmarks.length > 1 ? 's' : ''}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookmarks.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingSM),
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return HadithBookmarkListItem(
              bookmark: bookmark,
              onTap: () => onBookmarkTap(bookmark),
              onDelete: () => onBookmarkDelete(bookmark),
            );
          },
        ),
      ],
    );
  }
}