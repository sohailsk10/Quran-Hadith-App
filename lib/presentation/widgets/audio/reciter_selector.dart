/// Reciter selector widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/quran_models.dart';
import '../../../presentation/providers/app_providers.dart';

class ReciterSelector extends ConsumerWidget {
  final ReciterInfo? selectedReciter;
  final ValueChanged<ReciterInfo> onReciterSelected;
  final bool showCompact;

  const ReciterSelector({
    super.key,
    this.selectedReciter,
    required this.onReciterSelected,
    this.showCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;
    final recitersAsync = ref.watch(recitersProvider);

    return recitersAsync.when(
      data: (reciters) {
        if (reciters.isEmpty) return const SizedBox.shrink();

        if (showCompact) {
          return _CompactReciterSelector(
            reciters: reciters,
            selectedReciter: selectedReciter,
            onReciterSelected: onReciterSelected,
          );
        }

        return _FullReciterSelector(
          reciters: reciters,
          selectedReciter: selectedReciter,
          onReciterSelected: onReciterSelected,
        );
      },
      loading: () => _buildLoadingState(context),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Failed to load reciters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullReciterSelector extends StatelessWidget {
  final List<ReciterInfo> reciters;
  final ReciterInfo? selectedReciter;
  final ValueChanged<ReciterInfo> onReciterSelected;

  const _FullReciterSelector({
    required this.reciters,
    this.selectedReciter,
    required this.onReciterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reciter',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reciters.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppConstants.spacingSM),
          itemBuilder: (context, index) {
            final reciter = reciters[index];
            final isSelected = selectedReciter?.id == reciter.id;

            return _ReciterTile(
              reciter: reciter,
              isSelected: isSelected,
              onTap: () => onReciterSelected(reciter),
            );
          },
        ),
      ],
    );
  }
}

class _CompactReciterSelector extends StatelessWidget {
  final List<ReciterInfo> reciters;
  final ReciterInfo? selectedReciter;
  final ValueChanged<ReciterInfo> onReciterSelected;

  const _CompactReciterSelector({
    required this.reciters,
    this.selectedReciter,
    required this.onReciterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<ReciterInfo>(
      initialValue: selectedReciter,
      onSelected: onReciterSelected,
      tooltip: 'Select reciter',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMD,
          vertical: AppConstants.spacingSM,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.headphones_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppConstants.spacingSM),
            if (selectedReciter != null) ...[
              Text(
                selectedReciter!.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                'Select Reciter',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(width: AppConstants.spacingSM),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => reciters.map((reciter) {
        final isSelected = selectedReciter?.id == reciter.id;
        return PopupMenuItem<ReciterInfo>(
          value: reciter,
          child: _ReciterMenuItem(
            reciter: reciter,
            isSelected: isSelected,
          ),
        );
      }).toList(),
    );
  }
}

class _ReciterTile extends StatelessWidget {
  final ReciterInfo reciter;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReciterTile({
    required this.reciter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: isSelected
              ? quranHadithTheme.quranGradient.colors!.first.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: isSelected
                ? quranHadithTheme.quranGradient.colors!.first
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected
                  ? quranHadithTheme.quranGradient.colors!.first
                  : theme.colorScheme.primaryContainer,
              child: Text(
                reciter.name.isNotEmpty ? reciter.name[0].toUpperCase() : '?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reciter.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? quranHadithTheme.quranGradient.colors!.first
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (reciter.style.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      reciter.style,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (reciter.language.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingXS),
                    Row(
                      children: [
                        Icon(
                          Icons.language_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reciter.language,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: quranHadithTheme.quranGradient.colors!.first,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _ReciterMenuItem extends StatelessWidget {
  final ReciterInfo reciter;
  final bool isSelected;

  const _ReciterMenuItem({
    required this.reciter,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            reciter.name.isNotEmpty ? reciter.name[0].toUpperCase() : '?',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reciter.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (reciter.style.isNotEmpty)
                Text(
                  reciter.style,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
      ],
    );
  }
}

/// Reciter list item for settings page
class ReciterListItem extends ConsumerWidget {
  final ReciterInfo reciter;
  final bool isSelected;
  final VoidCallback onTap;

  const ReciterListItem({
    super.key,
    required this.reciter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          border: Border.all(
            color: isSelected
                ? quranHadithTheme.quranGradient.colors!.first
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected
                  ? quranHadithTheme.quranGradient.colors!.first
                  : theme.colorScheme.primaryContainer,
              child: Text(
                reciter.name.isNotEmpty ? reciter.name[0].toUpperCase() : '?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reciter.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? quranHadithTheme.quranGradient.colors!.first
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  if (reciter.style.isNotEmpty)
                    Text(
                      reciter.style,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (reciter.language.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.language_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reciter.language,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Radio button
            Radio<ReciterInfo>(
              value: reciter,
              groupValue: isSelected ? reciter : null,
              onChanged: (_) => onTap(),
              activeColor: quranHadithTheme.quranGradient.colors!.first,
            ),
          ],
        ),
      ),
    );
  }
}