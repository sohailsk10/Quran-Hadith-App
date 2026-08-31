/// Bookmark list items for Quran and Hadith

import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/quran_models.dart';
import '../../../shared/models/hadith_models.dart';
import '../../../shared/models/settings_models.dart';

/// Quran bookmark list item
class QuranBookmarkListItem extends StatelessWidget {
  final QuranBookmark bookmark;
  final QuranDisplaySettings settings;
  final String? translationText;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const QuranBookmarkListItem({
    super.key,
    required this.bookmark,
    required this.settings,
    this.translationText,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('quran_bookmark_${bookmark.surahNumber}_${bookmark.ayahNumber}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spacingLG),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: InkWell(
        onTap: onTap,
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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      '${bookmark.surahNumber}:${bookmark.ayahNumber}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSM),
                  Expanded(
                    child: Text(
                      quran.getSurahNameEnglish(bookmark.surahNumber),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(bookmark.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingMD),

              // Arabic Text
              Text(
                quran.getVerse(bookmark.surahNumber, bookmark.ayahNumber, verseEndSymbol: true),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Uthmani',
                  fontSize: settings.fontSize,
                  height: 2.0,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),

              // Translation
              if (translationText != null && translationText!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingSM),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  ),
                  child: Text(
                    translationText!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: settings.translationFontSize,
                      height: 1.6,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],

              // Note
              if (bookmark.note != null && bookmark.note!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingSM),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 16,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: AppConstants.spacingSM),
                      Expanded(
                        child: Text(
                          bookmark.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Hadith bookmark list item
class HadithBookmarkListItem extends StatelessWidget {
  final HadithBookmark bookmark;
  final Hadith hadith;
  final String? translation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HadithBookmarkListItem({
    super.key,
    required this.bookmark,
    required this.hadith,
    this.translation,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    return Dismissible(
      key: Key('hadith_bookmark_${bookmark.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spacingLG),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: InkWell(
        onTap: onTap,
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
              // Header
              Row(
                children: [
                  _AuthenticityBadge(authenticity: hadith.authenticity),
                  const SizedBox(width: AppConstants.spacingSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hadith.collectionName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Book: ${hadith.bookName} • #${hadith.numberInBook}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(bookmark.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingMD),

              // Arabic Text
              if (hadith.arabicText.isNotEmpty)
                Text(
                  hadith.arabicText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    height: 1.8,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),

              // Translation
              if (translation != null && translation!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingSM),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  ),
                  child: Text(
                    translation!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],

              // Note
              if (bookmark.note != null && bookmark.note!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingSM),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 16,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: AppConstants.spacingSM),
                      Expanded(
                        child: Text(
                          bookmark.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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

/// Favorite item (can be either Quran or Hadith)
class FavoriteItem extends StatelessWidget {
  final bool isQuran;
  final QuranBookmark? quranBookmark;
  final HadithBookmark? hadithBookmark;
  final String? translationText;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FavoriteItem({
    super.key,
    required this.isQuran,
    this.quranBookmark,
    this.hadithBookmark,
    this.translationText,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isQuran && quranBookmark != null) {
      return QuranBookmarkListItem(
        bookmark: quranBookmark!,
        settings: const QuranDisplaySettings(),
        translationText: translationText,
        onTap: onTap,
        onDelete: onDelete,
      );
    } else if (!isQuran && hadithBookmark != null) {
      // For favorites, we'd need the hadith data
      // This is a simplified version
      return HadithBookmarkListItem(
        bookmark: hadithBookmark!,
        hadith: Hadith(
          id: '',
          collectionId: '',
          bookId: '',
          chapterId: '',
          numberInBook: 0,
          arabicText: '',
          grade: HadithGrade.unknown,
          authenticity: HadithAuthenticity.unknown,
          narrators: [],
          topics: [],
        ),
        translation: translationText,
        onTap: onTap,
        onDelete: onDelete,
      );
    }

    return const SizedBox.shrink();
  }
}