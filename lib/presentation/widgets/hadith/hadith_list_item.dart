/// Hadith list item widget

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/hadith_models.dart';

class HadithListItem extends StatelessWidget {
  final Hadith hadith;
  final HadithDisplaySettings settings;
  final String? translation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onBookmarkToggle;
  final bool showBookmarkButton;

  const HadithListItem({
    super.key,
    required this.hadith,
    required this.settings,
    this.translation,
    this.onTap,
    this.onLongPress,
    this.onBookmarkToggle,
    this.showBookmarkButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with reference and authenticity
            Row(
              children: [
                // Authenticity Badge
                _AuthenticityBadge(authenticity: hadith.authenticity),
                const Spacer(),

                // Bookmark
                if (showBookmarkButton)
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
                    tooltip: hadith.isBookmarked
                        ? 'Remove bookmark'
                        : 'Add bookmark',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),

                // Reference
                if (hadith.collectionName.isNotEmpty)
                  Text(
                    '#${hadith.numberInBook}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingSM),

            // Arabic Text
            if (hadith.arabicText.isNotEmpty) ...[
              Text(
                hadith.arabicText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Amiri',
                  fontSize: settings.arabicFontSize,
                  height: 1.8,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: settings.showFullText ? null : 3,
                overflow: settings.showFullText ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.spacingSM),
            ],

            // Translation
            if (translation != null && translation!.isNotEmpty) ...[
              Text(
                translation!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: settings.translationFontSize,
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: settings.showFullText ? null : 2,
                overflow: settings.showFullText ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.spacingSM),
            ],

            // Footer with narrators count and topics
            Row(
              children: [
                if (hadith.narrators.isNotEmpty) ...[
                  Icon(
                    Icons.account_tree_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${hadith.narrators.length} narrators',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const Spacer(),
                if (hadith.topics.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: hadith.topics.take(3).map((topic) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: quranHadithTheme.hadithGradient.colors!.first.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        ),
                        child: Text(
                          topic,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: quranHadithTheme.hadithGradient.colors!.first,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        ),
      ),
    );
  }
}

/// Compact hadith item for horizontal lists
class CompactHadithListItem extends StatelessWidget {
  final Hadith hadith;
  final String? translation;
  final VoidCallback onTap;

  const CompactHadithListItem({
    super.key,
    required this.hadith,
    this.translation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AuthenticityBadge(authenticity: hadith.authenticity),
                const Spacer(),
                Text(
                  '#${hadith.numberInBook}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSM),
            if (hadith.arabicText.isNotEmpty)
              Text(
                hadith.arabicText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  height: 1.8,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (translation != null && translation!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacingSM),
              Text(
                translation!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}