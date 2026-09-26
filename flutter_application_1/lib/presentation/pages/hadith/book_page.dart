/// Book page with hadith list

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/hadith_models.dart';
import '../../../shared/models/settings_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/reading_settings_sheet.dart';
import '../../widgets/hadith/hadith_list_item.dart';

class BookPage extends ConsumerStatefulWidget {
  final String collectionId;
  final int bookNumber;

  const BookPage(
      {super.key, required this.collectionId, required this.bookNumber});

  @override
  ConsumerState<BookPage> createState() => _BookPageState();
}

class _BookPageState extends ConsumerState<BookPage>
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
      title: 'Book ${widget.bookNumber}',
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'Reading Settings',
          onPressed: () => showReadingSettingsSheet(
            context,
            ReadingSettingsMode.hadith,
          ),
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final booksAsync =
              ref.watch(hadithBooksProvider(widget.collectionId));
          final hadithsByBookAsync = ref.watch(hadithsByBookProvider((
            collectionId: widget.collectionId,
            bookNumber: widget.bookNumber,
            page: 1,
          )));
          final settings = ref.watch(settingsProvider);

          return booksAsync.when(
            data: (books) {
              final book = books.firstWhere(
                (b) => b.bookNumber == widget.bookNumber,
                orElse: () => throw Exception('Book not found'),
              );
              return Column(
                children: [
                  // Book Header
                  _buildBookHeader(book),

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Hadiths'),
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
                        hadithsByBookAsync.when(
                          data: (hadithBookDetail) =>
                              _buildHadithsTab(hadithBookDetail, settings),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stack) =>
                              Center(child: Text('Error: $error')),
                        ),
                        _buildChaptersTab(settings),
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

  Widget _buildBookHeader(HadithBook book) {
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
                  Icons.book_outlined,
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
                      'Book ${book.number}: ${book.name}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      '${book.totalHadiths} Hadiths • ${book.chapters.length} Chapters',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (book.bookDescription != null &&
              book.bookDescription!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              book.bookDescription!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHadithsTab(HadithBookDetail hadithBookDetail,
      AsyncValue<AppSettings> settingsAsync) {
    return settingsAsync.when(
      data: (settings) => RefreshIndicator(
        onRefresh: () async => ref.refresh(hadithsByBookProvider((
          collectionId: widget.collectionId,
          bookNumber: widget.bookNumber,
          page: 1,
        ))),
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          itemCount: hadithBookDetail.hadiths.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppConstants.spacingSM),
          itemBuilder: (context, index) {
            final hadith = hadithBookDetail.hadiths[index];
            return HadithListItem(
              hadith: hadith,
              settings: settings.hadithDisplay,
              onTap: () => context.go(
                  '/hadith/collection/${widget.collectionId}/book/${widget.bookNumber}/hadith/${hadith.hadithNumber}'),
              onLongPress: () => _showHadithActions(context, hadith),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error')),
    );
  }

  Widget _buildChaptersTab(AsyncValue<AppSettings> settingsAsync) {
    return settingsAsync.when(
      data: (settings) => Consumer(
        builder: (context, ref, _) {
          final bookId = '${widget.collectionId}_${widget.bookNumber}';
          final chaptersAsync = ref.watch(hadithChaptersProvider(bookId));
          return chaptersAsync.when(
            data: (chapters) => RefreshIndicator(
              onRefresh: () async =>
                  ref.refresh(hadithChaptersProvider(bookId)),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                itemCount: chapters.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppConstants.spacingMD),
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  return _ChapterCard(
                    chapter: chapter,
                    onTap: () {
                      context.go(
                          '/hadith/collection/${widget.collectionId}/book/${widget.bookNumber}/hadith/${chapter.startHadithNumber}');
                    },
                  );
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error')),
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

  void _showHadithActions(BuildContext context, Hadith hadith) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _HadithActionsSheet(
          hadith: hadith,
          collectionId: widget.collectionId,
          bookNumber: widget.bookNumber),
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
                    chapter.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    'Hadiths ${chapter.startHadithNumber} - ${chapter.endHadithNumber} (${chapter.totalHadiths} hadiths)',
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

class _HadithActionsSheet extends ConsumerWidget {
  final Hadith hadith;
  final String collectionId;
  final int bookNumber;

  const _HadithActionsSheet(
      {required this.hadith,
      required this.collectionId,
      required this.bookNumber});

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

            // Hadith Reference
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getGradeColor(hadith.grade).withValues(alpha: 0.15),
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
                  const SizedBox(height: AppConstants.spacingLG),
                  Text(
                    hadith.getTranslation(settings.language.code),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: _getTextDirection(settings.language.code),
                  ),
                  const SizedBox(height: AppConstants.spacingLG),

                  // Actions
                  _ActionTile(
                    icon: Icons.bookmark_add_outlined,
                    label: 'Bookmark',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(hadithBookmarksProvider.notifier).addBookmark(
                            HadithBookmark(
                              id: 'hadith_${collectionId}_${hadith.hadithNumber}_${DateTime.now().millisecondsSinceEpoch}',
                              hadithId:
                                  'hadith_${collectionId}_${hadith.hadithNumber}',
                              collectionId: collectionId,
                              bookNumber: bookNumber,
                              hadithNumber: hadith.hadithNumber,
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
                        const SnackBar(
                            content: Text('Share feature coming soon')),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.topic_outlined,
                    label: 'Related Topics',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to topics
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

  TextDirection _getTextDirection(String languageCode) {
    const rtlLanguages = ['ar', 'ur', 'fa', 'ps', 'sd'];
    return rtlLanguages.contains(languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
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
