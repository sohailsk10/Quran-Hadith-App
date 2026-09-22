/// Collection page with books/chapters list

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/hadith_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/hadith/book_card.dart';

class CollectionPage extends ConsumerStatefulWidget {
  final String collectionId;

  const CollectionPage({super.key, required this.collectionId});

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage>
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
    return AppScaffold(
      title: 'Collection',
      child: Consumer(
        builder: (context, ref, _) {
          final collectionsAsync = ref.watch(hadithCollectionsProvider);
          final booksAsync =
              ref.watch(hadithBooksProvider(widget.collectionId));

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
                        _buildChaptersTab(),
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
            color: quranHadithTheme.hadithGradient.colors.first
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
          if (collection.description.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              collection.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingMD),
          Wrap(
            spacing: AppConstants.spacingSM,
            runSpacing: AppConstants.spacingXS,
            children: [
              _StatChip(
                icon: Icons.article_outlined,
                label: '${collection.totalHadiths} Hadiths',
              ),
              _StatChip(
                icon: Icons.book_outlined,
                label: '${collection.totalBooks} Books',
              ),
              _StatChip(
                icon: Icons.translate_rounded,
                label: 'Translations: English & Urdu',
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
        onRefresh: () async =>
            ref.refresh(hadithBooksProvider(widget.collectionId)),
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          itemCount: books.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppConstants.spacingMD),
          itemBuilder: (context, index) {
            final book = books[index];
            return BookCard(
              book: book,
              onTap: () => context.go(
                  '/hadith/collection/${widget.collectionId}/book/${book.number}'),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildChaptersTab() {
    // This is a placeholder - chapters are per book, not per collection
    // In a real app, this might show a summary or redirect
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.topic_outlined,
              size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Select a Book to view its Chapters'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _tabController.animateTo(0),
            child: const Text('View Books'),
          ),
        ],
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
            onPressed: () => ref
                .refresh(hadithCollectionDetailProvider(widget.collectionId)),
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
