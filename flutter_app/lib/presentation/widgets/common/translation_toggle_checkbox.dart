import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../../shared/models/settings_models.dart';

class TranslationToggleCheckbox extends ConsumerWidget {
  final TextStyle? textStyle;

  const TranslationToggleCheckbox({super.key, this.textStyle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull ?? const AppSettings();
    final isChecked =
        settings.hadithDisplay.showTranslation && settings.quranDisplay.showTranslation;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(settingsProvider.notifier).toggleTranslation(!isChecked);
        },
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (val) {
                  ref
                      .read(settingsProvider.notifier)
                      .toggleTranslation(val ?? true);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                activeColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Translation',
                style: textStyle ??
                    theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
