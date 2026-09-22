/// Hadith detail page with full text, narrators, grade, and actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/hadith_models.dart';
import '../../../shared/models/settings_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/hadith/hadith_detail_card.dart' hide NarratorChainCard;
import '../../widgets/hadith/narrator_chain_card.dart';
import '../../widgets/hadith/related_hadiths_card.dart';

class HadithDetailPage extends ConsumerStatefulWidget {
  final String collectionId;
  final int hadithNumber;

  const HadithDetailPage(
      {super.key, required this.collectionId, required this.hadithNumber});

  @override
  ConsumerState<HadithDetailPage> createState() => _HadithDetailPageState();
}

class _HadithDetailPageState extends ConsumerState<HadithDetailPage>
    with SingleTickerProviderStateMixin {
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
    return AppScaffold(
      title: 'Hadith Detail',
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () => _shareHadith(),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined),
          onPressed: () => _bookmarkHadith(),
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final hadithAsync = ref.watch(
              hadithDetailProvider((widget.collectionId, widget.hadithNumber)));
          final narratorsAsync = ref.watch(
              hadithNarratorsProvider(hadithAsync.value?.narrators ?? []));
          final relatedHadithsAsync = ref.watch(relatedHadithsProvider((
            collectionId: widget.collectionId,
            hadithNumber: widget.hadithNumber,
            limit: 10,
          )));
          final settings = ref.watch(settingsProvider);

          return settings.when(
            data: (settings) => hadithAsync.when(
              data: (hadith) {
                if (hadith == null) return _buildErrorState('Hadith not found');
                return narratorsAsync.when(
                  data: (narrators) => relatedHadithsAsync.when(
                    data: (relatedHadiths) => _buildDetailContent(
                      context,
                      hadith,
                      narrators,
                      relatedHadiths,
                      settings,
                    ),
                    loading: () => _buildDetailContent(
                      context,
                      hadith,
                      narrators,
                      [],
                      settings,
                    ),
                    error: (_, __) => _buildDetailContent(
                      context,
                      hadith,
                      narrators,
                      [],
                      settings,
                    ),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                      _buildErrorState('Failed to load narrators'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error.toString()),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    Hadith hadith,
    List<Narrator> narrators,
    List<Hadith> relatedHadiths,
    AppSettings settings,
  ) {
    return Column(
      children: [
        // Hadith Detail Card
        HadithDetailCard(
          hadith: hadith,
          settings: settings.hadithDisplay,
          onBookmarkToggle: _bookmarkHadith,
          onShare: _shareHadith,
        ),

        // Tab Bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.account_tree), text: 'Narrators'),
            Tab(icon: Icon(Icons.link), text: 'Related'),
            Tab(icon: Icon(Icons.info_outline), text: 'Details'),
          ],
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNarratorsTab(narrators, settings),
              _buildRelatedTab(relatedHadiths, settings),
              _buildDetailsTab(hadith, settings),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarratorsTab(List<Narrator> narrators, AppSettings settings) {
    if (narrators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No narrator chain available'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      children: [
        NarratorChainCard(narrators: narrators),
        const SizedBox(height: AppConstants.spacingLG),
        // Individual narrator details
        ...narrators.map((narrator) => _NarratorDetailCard(narrator: narrator)),
      ],
    );
  }

  Widget _buildRelatedTab(List<Hadith> relatedHadiths, AppSettings settings) {
    if (relatedHadiths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No related hadiths found'),
          ],
        ),
      );
    }

    return RelatedHadithsCard(
      hadiths: relatedHadiths,
      onHadithTap: (hadith) {
        context.go(
            '/hadith/collection/${hadith.collectionId}/hadith/${hadith.hadithNumber}');
      },
    );
  }

  Widget _buildDetailsTab(Hadith hadith, AppSettings settings) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailSection(
            title: 'Classification',
            children: [
              _DetailRow('Grade', hadith.grade.arabicName,
                  color: _getGradeColor(hadith.grade)),
              _DetailRow('Authenticity', hadith.authenticity.arabicName),
              _DetailRow('Reliability', hadith.reliability.arabicName),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLG),
          _DetailSection(
            title: 'Source Information',
            children: [
              _DetailRow('Collection', hadith.collectionId),
              _DetailRow('Book Number', hadith.bookNumber.toString()),
              _DetailRow('Hadith Number', hadith.hadithNumber.toString()),
              if (hadith.chapterId != null)
                _DetailRow('Chapter', hadith.chapterId!),
              if (hadith.volumeNumber != null)
                _DetailRow('Volume', hadith.volumeNumber.toString()),
              if (hadith.pageNumber != null)
                _DetailRow('Page', hadith.pageNumber.toString()),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLG),
          if (hadith.topics.isNotEmpty) ...[
            _DetailSection(
              title: 'Topics',
              children:
                  hadith.topics.map((topic) => _DetailRow('', topic)).toList(),
            ),
            const SizedBox(height: AppConstants.spacingLG),
          ],
          if (hadith.referenceUrl != null) ...[
            _DetailSection(
              title: 'Reference',
              children: [
                _DetailRow('URL', hadith.referenceUrl!),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLG),
          ],
          if (hadith.notes != null && hadith.notes!.isNotEmpty) ...[
            _DetailSection(
              title: 'Notes',
              children: [
                Text(
                  hadith.notes!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(hadithDetailProvider(
                (widget.collectionId, widget.hadithNumber))),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _bookmarkHadith() {
    ref.read(hadithBookmarksProvider.notifier).addBookmark(
          HadithBookmark(
            id: 'hadith_${widget.collectionId}_${widget.hadithNumber}_${DateTime.now().millisecondsSinceEpoch}',
            hadithId: 'hadith_${widget.collectionId}_${widget.hadithNumber}',
            collectionId: widget.collectionId,
            bookNumber: 0,
            hadithNumber: widget.hadithNumber,
            createdAt: DateTime.now(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Hadith ${widget.collectionId}:${widget.hadithNumber} bookmarked')),
    );
  }

  void _shareHadith() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon')),
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

class _NarratorDetailCard extends StatelessWidget {
  final Narrator narrator;

  const _NarratorDetailCard({required this.narrator});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    narrator.name.isNotEmpty ? narrator.name[0] : '?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        narrator.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (narrator.kunya.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spacingXS),
                        Text(
                          'Kunya: ${narrator.kunya}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getReliabilityColor(narrator.reliability)
                        .withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(
                    narrator.reliability.arabicName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getReliabilityColor(narrator.reliability),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (narrator.birthYear != null || narrator.deathYear != null) ...[
              const SizedBox(height: AppConstants.spacingMD),
              Row(
                children: [
                  if (narrator.birthYear != null) ...[
                    Icon(Icons.calendar_today,
                        size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Born: ${narrator.birthYear}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (narrator.birthYear != null && narrator.deathYear != null)
                    const SizedBox(width: AppConstants.spacingMD),
                  if (narrator.deathYear != null) ...[
                    Icon(Icons.event_busy,
                        size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Died: ${narrator.deathYear}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (narrator.biography.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacingMD),
              Text(
                narrator.biography,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getReliabilityColor(NarratorReliability reliability) {
    switch (reliability) {
      case NarratorReliability.thiqa:
        return const Color(0xFF006D4C);
      case NarratorReliability.saduq:
        return const Color(0xFFD4A843);
      case NarratorReliability.hasan:
        return Colors.lightGreen;
      case NarratorReliability.daif:
        return Colors.orange;
      case NarratorReliability.majhul:
        return Colors.grey;
      case NarratorReliability.matruk:
        return Colors.red;
      case NarratorReliability.kadhdhab:
        return Colors.deepOrange;
      case NarratorReliability.unknown:
        return Colors.grey;
    }
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        ...children,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _DetailRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),
          ],
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color ?? theme.colorScheme.onSurface,
                fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
