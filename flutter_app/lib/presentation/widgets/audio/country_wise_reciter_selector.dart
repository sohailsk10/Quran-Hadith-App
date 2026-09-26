/// Country-wise Quran Reciter Selector Widget
/// Groups reciters by country of origin with search, country filter chips, and expandable lists.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/quran_audio_api_service.dart';
import '../../../presentation/providers/app_providers.dart';

class CountryWiseReciterSelector extends ConsumerStatefulWidget {
  final String? selectedReciterId;
  final ValueChanged<ReciterInfo>? onReciterSelected;
  final bool showSearch;

  const CountryWiseReciterSelector({
    super.key,
    this.selectedReciterId,
    this.onReciterSelected,
    this.showSearch = true,
  });

  @override
  ConsumerState<CountryWiseReciterSelector> createState() =>
      _CountryWiseReciterSelectorState();
}

class _CountryWiseReciterSelectorState
    extends ConsumerState<CountryWiseReciterSelector> {
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
    final recitersAsync = ref.watch(quranAudioRecitersProvider);
    final audioState = ref.watch(quranAudioApiProvider);
    final currentSelectedId = widget.selectedReciterId ??
        audioState.currentReciterId;

    return recitersAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacingLG),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => _buildWithReciterList(
        const [],
        currentSelectedId,
        theme,
      ),
      data: (reciters) {
        final list = reciters.isNotEmpty ? reciters : <ReciterInfo>[];
        return _buildWithReciterList(list, currentSelectedId, theme);
      },
    );
  }

  Widget _buildWithReciterList(
    List<ReciterInfo> reciters,
    String currentSelectedId,
    ThemeData theme,
  ) {
    // Filter by search query
    final filtered = reciters.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final matchesName = r.name.toLowerCase().contains(q);
      final matchesCountry = r.country.toLowerCase().contains(q);
      final matchesStyle = r.style.toLowerCase().contains(q);
      return matchesName || matchesCountry || matchesStyle;
    }).toList();

    // Group by country
    final Map<String, List<ReciterInfo>> grouped = {};
    for (final r in filtered) {
      grouped.putIfAbsent(r.country, () => []).add(r);
    }

    // Sort countries with priority
    final countryPriority = {
      'Kuwait': 1,
      'Saudi Arabia': 2,
      'Egypt': 3,
      'Yemen': 4,
      'United Arab Emirates': 5,
      'Other': 99,
    };
    final sortedCountries = grouped.keys.toList()
      ..sort((a, b) {
        final pa = countryPriority[a] ?? 99;
        final pb = countryPriority[b] ?? 99;
        if (pa != pb) return pa.compareTo(pb);
        return a.compareTo(b);
      });

    // Filter by selected country chip
    final displayCountries = _selectedCountryFilter == null
        ? sortedCountries
        : sortedCountries
            .where((c) => c == _selectedCountryFilter)
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
                hintText: 'Search reciter, style, or country...',
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
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
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
                    bottom: AppConstants.spacingSM,
                  ),
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
                  final isSelected = _selectedCountryFilter == c;
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: AppConstants.spacingSM,
                      bottom: AppConstants.spacingSM,
                    ),
                    child: FilterChip(
                      label: Text(c),
                      selected: isSelected,
                      onSelected: (_) => setState(() {
                        _selectedCountryFilter = isSelected ? null : c;
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

        // List of countries with reciters
        if (displayCountries.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLG),
            child: Center(
              child: Text(
                'No reciters found for "$_searchQuery"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...displayCountries.map((country) {
            final countryReciters = grouped[country] ?? [];
            final hasSelectedReciter = countryReciters.any((r) =>
                r.id == currentSelectedId);

            // Country flag mapping
            final countryFlags = {
              'Kuwait': '🇰🇼',
              'Saudi Arabia': '🇸🇦',
              'Egypt': '🇪🇬',
              'Yemen': '🇾🇪',
              'United Arab Emirates': '🇦🇪',
              'Other': '🌐',
            };
            final flag = countryFlags[country] ?? '🌐';

            return Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(
                  color: hasSelectedReciter
                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                child: ExpansionTile(
                  key: PageStorageKey('reciter_country_$country'),
                  initiallyExpanded: hasSelectedReciter ||
                      _searchQuery.isNotEmpty ||
                      _selectedCountryFilter != null ||
                      country == 'Kuwait',
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMD,
                    vertical: 2,
                  ),
                  leading: Text(
                    flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${countryReciters.length} reciter${countryReciters.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: hasSelectedReciter
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusFull,
                            ),
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
                  children: countryReciters.map((reciter) {
                    final isSelected = reciter.id == currentSelectedId;

                    return InkWell(
                      onTap: () {
                        // Switch active reciter in audio service & settings
                        ref.read(quranAudioApiProvider.notifier).changeReciter(
                              reciterId: reciter.id,
                              reciterName: reciter.name,
                            );
                        widget.onReciterSelected?.call(reciter);
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
                            const SizedBox(width: AppConstants.spacingMD),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reciter.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (reciter.nameArabic != null && reciter.nameArabic!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      reciter.nameArabic!,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontFamily: 'Amiri',
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingSM),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: theme
                                    .colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusSM,
                                ),
                              ),
                              child: Text(
                                reciter.style.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurfaceVariant,
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
  }
}
