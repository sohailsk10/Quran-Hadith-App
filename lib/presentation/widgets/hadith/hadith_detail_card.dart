/// Hadith detail card widget

import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/hadith_models.dart';
import 'related_hadiths_card.dart';

class HadithDetailCard extends StatelessWidget {
  final Hadith hadith;
  final HadithDisplaySettings settings;
  final String? translation;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onShare;
  final VoidCallback? onAudioPlay;

  const HadithDetailCard({
    super.key,
    required this.hadith,
    required this.settings,
    this.translation,
    this.onBookmarkToggle,
    this.onShare,
    this.onAudioPlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with bookmark and actions
          Row(
            children: [
              // Authenticity Badge
              _AuthenticityBadge(authenticity: hadith.authenticity),
              const Spacer(),
              // Actions
              IconButton(
                onPressed: onBookmarkToggle,
                icon: Icon(
                  hadith.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: hadith.isBookmarked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: hadith.isBookmarked ? 'Remove bookmark' : 'Add bookmark',
              ),
              IconButton(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded),
                tooltip: 'Share hadith',
              ),
              if (onAudioPlay != null)
                IconButton(
                  onPressed: onAudioPlay,
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  tooltip: 'Play audio',
                ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMD),

          // Reference
          if (hadith.collectionName.isNotEmpty || hadith.bookName.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              decoration: BoxDecoration(
                color: quranHadithTheme.hadithGradient.colors!.first.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: quranHadithTheme.hadithGradient.colors!.first,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  if (hadith.collectionName.isNotEmpty)
                    Text(
                      hadith.collectionName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (hadith.bookName.isNotEmpty)
                    Text(
                      'Book: ${hadith.bookName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (hadith.chapterName.isNotEmpty)
                    Text(
                      'Chapter: ${hadith.chapterName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    'Hadith #${hadith.numberInBook}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppConstants.spacingLG),

          // Arabic Text
          if (hadith.arabicText.isNotEmpty) ...[
            Text(
              hadith.arabicText,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'Amiri',
                fontSize: settings.arabicFontSize,
                height: 2.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: AppConstants.spacingLG),
          ],

          // Translation
          if (translation != null && translation!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Text(
                translation!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: settings.translationFontSize,
                  height: 1.6,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLG),
          ],

          // Narrator Chain
          if (settings.showNarratorChain && hadith.narrators.isNotEmpty) ...[
            NarratorChainCard(narrators: hadith.narrators),
            const SizedBox(height: AppConstants.spacingLG),
          ],

          // Grades and Details
          if (hadith.grade != HadithGrade.unknown ||
              hadith.gradeDetails.isNotEmpty ||
              hadith.reference != null) ...[
            _DetailsSection(
              grade: hadith.grade,
              arabicGrade: hadith.gradeDetails.isNotEmpty ? hadith.gradeDetails : null,
              reference: hadith.reference,
              topics: hadith.topics,
            ),
          ],
        ],
      ),
    );
  }
}

class _AuthenticityBadge extends StatelessWidget {
  final HadithAuthenticity authenticity;

  const _AuthenticityBadge({required this.authenticity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (label, color) = switch (authenticity) {
      HadithAuthenticity.sahih => ('Sahih', Colors.green),
      HadithAuthenticity.hasan => ('Hasan', Colors.blue),
      HadithAuthenticity.daif => ('Da\'if', Colors.orange),
      HadithAuthenticity.mawdu => ('Mawdu\'', Colors.red),
      HadithAuthenticity.unknown => ('Unknown', theme.colorScheme.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final HadithGrade grade;
  final String? arabicGrade;
  final String? reference;
  final List<String> topics;

  const _DetailsSection({
    required this.grade,
    this.arabicGrade,
    this.reference,
    required this.topics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Details',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            if (grade != HadithGrade.unknown)
              _DetailChip(
                icon: Icons.grade_outlined,
                label: grade.displayName,
                color: _gradeColor(grade),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),

        if (arabicGrade != null && arabicGrade!.isNotEmpty) ...[
          _DetailRow(
            label: 'Arabic Grade',
            value: arabicGrade!,
          ),
          const SizedBox(height: AppConstants.spacingSM),
        ],

        if (reference != null && reference!.isNotEmpty) ...[
          _DetailRow(
            label: 'Reference',
            value: reference!,
          ),
          const SizedBox(height: AppConstants.spacingSM),
        ],

        if (topics.isNotEmpty) ...[
          _DetailRow(
            label: 'Topics',
            value: topics.join(', '),
          ),
        ],
      ],
    );
  }

  Color _gradeColor(HadithGrade grade) {
    return switch (grade) {
      HadithGrade.sahih => Colors.green,
      HadithGrade.hasan => Colors.blue,
      HadithGrade.daif => Colors.orange,
      HadithGrade.mawdu => Colors.red,
      HadithGrade.unknown => Colors.grey,
    };
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Narrator chain card
class NarratorChainCard extends StatelessWidget {
  final List<Narrator> narrators;

  const NarratorChainCard({
    super.key,
    required this.narrators,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (narrators.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chain of Narrators (Sanad)',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: narrators.length,
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXS),
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          itemBuilder: (context, index) {
            final narrator = narrators[index];
            return _NarratorItem(narrator: narrator, isLast: index == narrators.length - 1);
          },
        ),
      ],
    );
  }
}

class _NarratorItem extends StatelessWidget {
  final Narrator narrator;
  final bool isLast;

  const _NarratorItem({
    required this.narrator,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${narrator.order}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMD),

          // Narrator Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  narrator.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (narrator.kunya != null && narrator.kunya!.isNotEmpty)
                  Text(
                    narrator.kunya!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (narrator.birthDeath != null && narrator.birthDeath!.isNotEmpty)
                  Text(
                    narrator.birthDeath!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Reliability
          if (narrator.reliability != NarratorReliability.unknown)
            _ReliabilityBadge(reliability: narrator.reliability),
        ],
      ),
    );
  }
}

class _ReliabilityBadge extends StatelessWidget {
  final NarratorReliability reliability;

  const _ReliabilityBadge({required this.reliability});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (label, color) = switch (reliability) {
      NarratorReliability.thiqah => ('Thiqah', Colors.green),
      NarratorReliability.saduq => ('Saduq', Colors.blue),
      NarratorReliability.saqr => ('Saqr', Colors.amber),
      NarratorReliability.majhul => ('Majhul', Colors.orange),
      NarratorReliability.daif => ('Da\'if', Colors.red),
      NarratorReliability.unknown => ('Unknown', theme.colorScheme.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

