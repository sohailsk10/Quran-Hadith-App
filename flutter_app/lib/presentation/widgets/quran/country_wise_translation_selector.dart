/// Country-wise Quran Translation Selector Widget
/// Groups translations by country of origin with search, country filter chips, and expandable lists.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/translation_country_mapper.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/quran_models.dart';

class CountryWiseTranslationSelector extends ConsumerStatefulWidget {
  final String? selectedTranslationId;
  final ValueChanged<TranslationInfo>? onTranslationSelected;
  final bool showSearch;

  const CountryWiseTranslationSelector({
    super.key,
    this.selectedTranslationId,
    this.onTranslationSelected,
    this.showSearch = true,
  });

  @override
  ConsumerState<CountryWiseTranslationSelector> createState() =>
      _CountryWiseTranslationSelectorState();
}

class _CountryWiseTranslationSelectorState
    extends ConsumerState<CountryWiseTranslationSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCountryFilter; // null = all countries

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translationsAsync = ref.watch(translationsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currentSelectedId = widget.selectedTranslationId ??
        settingsAsync.valueOrNull?.selectedTranslationId ??
        'en.sahih';

    return translationsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacingLG),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          child: Text('Error loading translations: $e'),
        ),
      ),
      data: (translations) {
        if (translations.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingLG),
              child: Text('No translations available'),
            ),
          );
        }

        // Filter by search query
        final filtered = translations.where((t) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          final matchesName = t.name.toLowerCase().contains(q);
          final matchesAuthor = t.author.toLowerCase().contains(q);
          final matchesLang = t.languageName.toLowerCase().contains(q);
          final matchesCountry = t.countryName.toLowerCase().contains(q);
          return matchesName || matchesAuthor || matchesLang || matchesCountry;
        }).toList();

        // Group by country
        final Map<TranslationCountry, List<TranslationInfo>> grouped = {};
        for (final t in filtered) {
          final country = t.countryObj;
          grouped.putIfAbsent(country, () => []).add(t);
        }

        // Sort countries: priority first, then alphabetical
        final sortedCountries = grouped.keys.toList()
          ..sort((a, b) {
            if (a.priority != b.priority) {
              return a.priority.compareTo(b.priority);
            }
            return a.name.compareTo(b.name);
          });

        // Filter by selected country chip
        final displayCountries = _selectedCountryFilter == null
            ? sortedCountries
            : sortedCountries
                .where((c) => c.name == _selectedCountryFilter)
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Bar
            if (widget.showSearch) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingMD),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search translator, scholar, country...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMD,
                      vertical: AppConstants.spacingSM,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMD),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],

            // Quick Country Filter Chips
            if (_searchQuery.isEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: AppConstants.spacingSM,
                          bottom: AppConstants.spacingSM),
                      child: FilterChip(
                        label: const Text('All Countries'),
                        selected: _selectedCountryFilter == null,
                        onSelected: (_) =>
                            setState(() => _selectedCountryFilter = null),
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    ...sortedCountries.map((c) {
                      final isSelected = _selectedCountryFilter == c.name;
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: AppConstants.spacingSM,
                            bottom: AppConstants.spacingSM),
                        child: FilterChip(
                          label: Text('${c.flag} ${c.name}'),
                          selected: isSelected,
                          onSelected: (_) => setState(() {
                            _selectedCountryFilter =
                                isSelected ? null : c.name;
                          }),
                          selectedColor: theme.colorScheme.primaryContainer,
                          checkmarkColor: theme.colorScheme.onPrimaryContainer,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXS),
            ],

            // List of countries with translations
            if (displayCountries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLG),
                child: Center(
                  child: Text(
                    'No translations found for "$_searchQuery"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...displayCountries.map((country) {
                final countryTranslations = grouped[country] ?? [];
                final hasSelectedTranslation = countryTranslations
                    .any((t) => t.id == currentSelectedId);

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMD),
                    border: Border.all(
                      color: hasSelectedTranslation
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMD),
                    child: ExpansionTile(
                      key: PageStorageKey('country_${country.name}'),
                      initiallyExpanded: hasSelectedTranslation ||
                          _searchQuery.isNotEmpty ||
                          _selectedCountryFilter != null ||
                          country.name == 'Pakistan', // Open Pakistan by default
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMD,
                        vertical: 2,
                      ),
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        country.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${countryTranslations.length} translation${countryTranslations.length == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: hasSelectedTranslation
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusFull),
                              ),
                              child: Text(
                                'Selected',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : null,
                      children: countryTranslations.map((translation) {
                        final isSelected =
                            translation.id == currentSelectedId;
                        return InkWell(
                          onTap: () {
                            ref
                                .read(settingsProvider.notifier)
                                .updateTranslation(translation.id);
                            widget.onTranslationSelected?.call(translation);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingMD,
                              vertical: AppConstants.spacingSM,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.4)
                                  : Colors.transparent,
                              border: Border(
                                top: BorderSide(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outlineVariant,
                                  size: 22,
                                ),
                                const SizedBox(
                                    width: AppConstants.spacingMD),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        translation.name,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      if (translation.author.isNotEmpty &&
                                          translation.author !=
                                              translation.name) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          translation.author,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                    width: AppConstants.spacingSM),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusSM,
                                    ),
                                  ),
                                  child: Text(
                                    translation.languageName.toUpperCase(),
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: theme
                                          .colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
