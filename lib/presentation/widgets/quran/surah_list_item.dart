/// Surah list item widget

import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/quran_models.dart';

class SurahListItem extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const SurahListItem({
    super.key,
    required this.surah,
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
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            // Surah Number Circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: quranHadithTheme.quranGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),

            // Surah Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Names
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          surah.nameEnglish,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (surah.nameArabic.isNotEmpty) ...[
                        const SizedBox(width: AppConstants.spacingSM),
                        Text(
                          surah.nameArabic,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Uthmani',
                            fontSize: 18,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingXS),

                  // Details
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.format_list_numbered_rtl,
                        label: '${surah.totalAyahs} Ayahs',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppConstants.spacingSM),
                      _InfoChip(
                        icon: surah.revelationPlace == 'Makkah'
                            ? Icons.location_city
                            : Icons.mosque,
                        label: surah.revelationPlace,
                        color: surah.revelationPlace == 'Makkah'
                            ? Colors.deepOrange
                            : Colors.green,
                      ),
                      const SizedBox(width: AppConstants.spacingSM),
                      _InfoChip(
                        icon: Icons.auto_stories,
                        label: 'Juz ${surah.juzNumber}',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),

                  // Meaning
                  if (surah.meaning.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      surah.meaning,
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

            // Chevron
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact surah list item for horizontal lists
class CompactSurahListItem extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const CompactSurahListItem({
    super.key,
    required this.surah,
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
        width: 140,
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: quranHadithTheme.quranGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              surah.nameEnglish,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              '${surah.totalAyahs} Ayahs',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
