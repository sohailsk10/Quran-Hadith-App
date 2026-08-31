/// Narrator chain (Isnad) card widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/hadith_models.dart';

class NarratorChainCard extends StatelessWidget {
  final List<Narrator> narrators;

  const NarratorChainCard({super.key, required this.narrators});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (narrators.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Chain of Narrators (Isnād)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),

            // Visual chain
            _buildChain(context),

            const SizedBox(height: AppConstants.spacingMD),

            // Summary
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingSM),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    context,
                    Icons.person_outline,
                    narrators.length.toString(),
                    'Narrators',
                  ),
                  _buildStat(
                    context,
                    Icons.verified_outlined,
                    narrators.where((n) => n.reliability == NarratorReliability.thiqa).length.toString(),
                    'Thiqa',
                  ),
                  _buildStat(
                    context,
                    Icons.history,
                    narrators.where((n) => n.deathYear != null).length.toString(),
                    'Dated',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChain(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: narrators.asMap().entries.map((entry) {
        final index = entry.key;
        final narrator = entry.value;
        final isLast = index == narrators.length - 1;

        return Column(
          children: [
            _NarratorNode(
              narrator: narrator,
              index: index + 1,
              total: narrators.length,
            ),
            if (!isLast)
              _buildConnector(context),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildConnector(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 16,
            color: theme.colorScheme.outlineVariant,
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: theme.colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NarratorNode extends StatelessWidget {
  final Narrator narrator;
  final int index;
  final int total;

  const _NarratorNode({
    required this.narrator,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = index == total;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number indicator
        Container(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _getReliabilityColor(narrator.reliability).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getReliabilityColor(narrator.reliability),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _getReliabilityColor(narrator.reliability),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppConstants.spacingMD),

        // Narrator info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      narrator.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (narrator.kunya.isNotEmpty) ...[
                    const SizedBox(width: AppConstants.spacingSM),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      ),
                      child: Text(
                        narrator.kunya,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              if (narrator.nameArabic.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  narrator.nameArabic,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'Amiri',
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],

              const SizedBox(height: AppConstants.spacingXS),

              Row(
                children: [
                  // Reliability badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getReliabilityColor(narrator.reliability).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      narrator.reliability.arabicName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getReliabilityColor(narrator.reliability),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  if (narrator.deathYear != null) ...[
                    const SizedBox(width: AppConstants.spacingSM),
                    Text(
                      'd. ${narrator.deathYear} CE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Position in chain
                  Text(
                    _getPositionText(index, total),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              if (narrator.biography.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingSM),
                Text(
                  narrator.biography,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getPositionText(int index, int total) {
    if (index == 1) return 'Narrator';
    if (index == total) return 'Companion/Prophet';
    return 'Narrator ${index - 1}';
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