/// Related hadiths card widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/hadith_models.dart';
import '../../../shared/models/settings_models.dart';
import '../../widgets/hadith/hadith_list_item.dart';
import '../../../presentation/providers/app_providers.dart';

class RelatedHadithsCard extends StatelessWidget {
  final List<Hadith> hadiths;
  final Function(Hadith)? onHadithTap;

  const RelatedHadithsCard({
    super.key,
    required this.hadiths,
    this.onHadithTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (hadiths.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
          child: Row(
            children: [
              Icon(
                Icons.link_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingSM),
              Text(
                'Related Hadiths',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (hadiths.length > 3)
                TextButton(
                  onPressed: () {
                    // Navigate to full related hadiths list
                  },
                  child: Text('View All (${hadiths.length})'),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hadiths.length > 3 ? 3 : hadiths.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: AppConstants.spacingMD,
            endIndent: AppConstants.spacingMD,
            color: theme.colorScheme.outlineVariant,
          ),
          itemBuilder: (context, index) {
            final hadith = hadiths[index];
            return _RelatedHadithItem(
              hadith: hadith,
              onTap: () => onHadithTap?.call(hadith),
            );
          },
        ),
        if (hadiths.length > 3) ...[
          Divider(
            height: 1,
            indent: AppConstants.spacingMD,
            endIndent: AppConstants.spacingMD,
            color: theme.colorScheme.outlineVariant,
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Center(
              child: Text(
                'And ${hadiths.length - 3} more...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RelatedHadithItem extends ConsumerWidget {
  final Hadith hadith;
  final VoidCallback? onTap;

  const _RelatedHadithItem({
    required this.hadith,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reference badge
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingXS,
                vertical: AppConstants.spacingXS,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: Text(
                hadith.shortReference,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(width: AppConstants.spacingMD),

            // Hadith content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic text (first line)
                  if (hadith.textArabic.isNotEmpty) ...[
                    Text(
                      hadith.textArabic,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: settings.valueOrNull?.hadithDisplay
                                    .arabicFontSize !=
                                null
                            ? 'Amiri'
                            : 'Amiri',
                        fontSize: (settings.valueOrNull?.hadithDisplay
                                    .arabicFontSize ??
                                18) *
                            0.9,
                        height: 1.8,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                  ],

                  // Translation
                  Text(
                    hadith.displayTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: (settings.valueOrNull?.hadithDisplay
                                  .translationFontSize ??
                              14) *
                          0.9,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppConstants.spacingXS),

                  // Grade and topics
                  Row(
                    children: [
                      _GradeBadge(grade: hadith.grade),
                      const SizedBox(width: AppConstants.spacingSM),
                      if (hadith.topics.isNotEmpty)
                        Expanded(
                          child: Text(
                            hadith.topics.take(3).join(', '),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone related hadiths list for full page
class RelatedHadithsList extends ConsumerWidget {
  final List<Hadith> hadiths;
  final Function(Hadith)? onHadithTap;

  const RelatedHadithsList({
    super.key,
    required this.hadiths,
    this.onHadithTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (hadiths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'No Related Hadiths',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Related hadiths will appear here based on shared topics, narrators, or themes.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      itemCount: hadiths.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppConstants.spacingSM),
      itemBuilder: (context, index) {
        final hadith = hadiths[index];
        final settings =
            ref.watch(settingsProvider).valueOrNull?.hadithDisplay ??
                const HadithDisplaySettings();
        return HadithListItem(
          hadith: hadith,
          settings: settings,
          onTap: () => onHadithTap?.call(hadith),
        );
      },
    );
  }
}

/// Grade badge for related hadiths
class _GradeBadge extends StatelessWidget {
  final HadithGrade grade;

  const _GradeBadge({required this.grade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (grade == HadithGrade.unknown) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getGradeColor(grade).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        grade.shortName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getGradeColor(grade),
          fontWeight: FontWeight.w700,
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
        return Colors.deepOrange;
      case HadithGrade.mudtarib:
        return Colors.purple;
      case HadithGrade.muallal:
        return Colors.brown;
      case HadithGrade.unknown:
        return Colors.grey;
    }
  }
}
