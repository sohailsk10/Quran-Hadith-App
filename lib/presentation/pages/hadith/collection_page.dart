/// Collection page with books/chapters list

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
import '../../widgets/hadith/book_card.dart';

class CollectionPage extends ConsumerStatefulWidget {
  final String collectionId;

  const CollectionPage({super.key, required this.collectionId});

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> with SingleTickerProviderStateMixin {
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
      title: 'Collection',
      child: Consumer(
        builder: (context, ref, _) {
          final collectionsAsync = ref.watch(hadithCollectionsProvider);
          final booksAsync = ref.watch(hadithBooksProvider(widget.collectionId));
          final chaptersAsync = ref.watch(hadithChaptersProvider(widget.collectionId));

          return collectionsAsync.when(
            data: (collections) {
              final collection = collections.firstWhere(
                (c) => c.id == widget.collectionId,
                orElse: () => throw Exception('Collection not found'),
              );
              return Column(
                children: [
                  // Collection Header
                  _buildCollectionHeader(collection),

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Books'),
                      Tab(text: 'Chapters'),
                    ],
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBooksTab(booksAsync),
                        _buildChaptersTab(chaptersAsync),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error),
          );
        },
      ),
    );
  }

  Widget _buildCollectionHeader(HadithCollection collection) {
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
                child: const Icon(
                  Icons.library_books_rounded,
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
                      collection.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      collection.author,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            children: [
              _StatChip(
                icon: Icons.article_outlined,
                label: '${collection.totalHadiths} Hadiths',
              ),
              const SizedBox(width: AppConstants.spacingMD),
              _StatChip(
                icon: Icons.book_outlined,
                label: '${collection.totalBooks} Books',
              ),
              const SizedBox(width: AppConstants.spacingMD),
              _StatChip(
                icon: Icons.topic_outlined,
                label: '${collection.totalChapters} Chapters',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBooksTab(AsyncValue<List<HadithBook>> booksAsync) {
    return booksAsync.when(
      data: (books) => RefreshIndicator(
        onRefresh: () async => ref.refresh(booksProvider(widget.collectionId)),
        child: AnimationLimiter(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMD),
            itemBuilder: (context, index) {
              final book = books[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: BookCard(
                      book: book,
                      onTap: () => context.go('/hadith/collection/${widget.collectionId}/book/${book.number}'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildChaptersTab(AsyncValue<List<HadithChapter>> chaptersAsync) {
    return chaptersAsync.when(
      data: (chapters) => RefreshIndicator(
        onRefresh: () async => ref.refresh(chaptersProvider(widget.collectionId)),
        child: AnimationLimiter(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            itemCount: chapters.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMD),
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: AppConstants.mediumAnimation,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _ChapterCard(
                      chapter: chapter,
                      onTap: () {
                        // Navigate to first hadith in chapter
                        context.go('/hadith/collection/${widget.collectionId}/book/${chapter.bookNumber}/hadith/${chapter.startHadithNumber}');
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
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
            onPressed: () => ref.refresh(hadithCollectionProvider(widget.collectionId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
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

class _ChapterCard extends StatelessWidget {
  final HadithChapter chapter;
  final VoidCallback onTap;

  const _ChapterCard({required this.chapter, required this.onTap});

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
                    chapter.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    'Book ${chapter.bookNumber} • ${chapter.hadithCount} hadiths',
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
}