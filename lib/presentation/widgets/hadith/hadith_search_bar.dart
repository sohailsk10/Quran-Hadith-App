/// Hadith search bar widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';

class HadithSearchBar extends ConsumerStatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onFilterTap;
  final String? hintText;

  const HadithSearchBar({
    super.key,
    required this.onSearch,
    required this.onFilterTap,
    this.hintText,
  });

  @override
  ConsumerState<HadithSearchBar> createState() => _HadithSearchBarState();
}

class _HadithSearchBarState extends ConsumerState<HadithSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showSuggestions();
    } else {
      _removeOverlay();
    }
  }

  void _showSuggestions() {
    // TODO: Fetch search suggestions from provider
    _suggestions = [
      'Sahih Bukhari',
      'Sahih Muslim',
      'Prayer',
      'Fasting',
      'Zakat',
      'Hajj',
      'Faith',
      'Knowledge',
    ];

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => _SuggestionsOverlay(
          suggestions: _suggestions,
          onSuggestionTap: (suggestion) {
            _controller.text = suggestion;
            widget.onSearch(suggestion);
            _focusNode.unfocus();
          },
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search Hadith...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          widget.onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMD,
                  vertical: AppConstants.spacingSM,
                ),
              ),
              onChanged: widget.onSearch,
              onSubmitted: widget.onSearch,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMD),
          IconButton(
            onPressed: widget.onFilterTap,
            icon: const Icon(Icons.tune_rounded),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              padding: const EdgeInsets.all(AppConstants.spacingMD),
            ),
            tooltip: 'Filters',
          ),
        ],
      ),
    );
  }
}

class _SuggestionsOverlay extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const _SuggestionsOverlay({
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 100, // Will be positioned relative to the search bar
      left: AppConstants.spacingMD,
      right: AppConstants.spacingMD,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSM),
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: AppConstants.spacingMD,
              endIndent: AppConstants.spacingMD,
              color: theme.colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return ListTile(
                leading: const Icon(Icons.history_rounded),
                title: Text(suggestion),
                onTap: () => onSuggestionTap(suggestion),
                dense: true,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Hadith filter bottom sheet
class HadithFilterBottomSheet extends ConsumerWidget {
  final HadithFilter currentFilter;
  final ValueChanged<HadithFilter> onFilterChanged;

  const HadithFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collectionsAsync = ref.watch(hadithCollectionsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: AppConstants.spacingSM),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                child: Row(
                  children: [
                    Text(
                      'Filters',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        onFilterChanged(const HadithFilter());
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Filters content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  children: [
                    // Collections
                    _buildSectionHeader(context, 'Collections'),
                    collectionsAsync.when(
                      data: (collections) => Wrap(
                        spacing: AppConstants.spacingSM,
                        runSpacing: AppConstants.spacingSM,
                        children: collections.map((collection) {
                          final isSelected = currentFilter.collections
                              .contains(collection.id);
                          return FilterChip(
                            label: Text(collection.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              final newCollections = Set<String>.from(
                                currentFilter.collections);
                              if (selected) {
                                newCollections.add(collection.id);
                              } else {
                                newCollections.remove(collection.id);
                              }
                              onFilterChanged(currentFilter.copyWith(
                                collections: newCollections,
                              ));
                            },
                          );
                        }).toList(),
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.spacingLG),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: AppConstants.spacingLG),

                    // Authenticity
                    _buildSectionHeader(context, 'Authenticity'),
                    Wrap(
                      spacing: AppConstants.spacingSM,
                      runSpacing: AppConstants.spacingSM,
                      children: HadithAuthenticity.values
                          .where((a) => a != HadithAuthenticity.unknown)
                          .map((authenticity) {
                        final isSelected = currentFilter.authenticities
                            .contains(authenticity);
                        return FilterChip(
                          label: Text(authenticity.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            final newAuths = Set<HadithAuthenticity>.from(
                              currentFilter.authenticities);
                            if (selected) {
                              newAuths.add(authenticity);
                            } else {
                              newAuths.remove(authenticity);
                            }
                            onFilterChanged(currentFilter.copyWith(
                              authenticities: newAuths,
                            ));
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppConstants.spacingLG),

                    // Grade
                    _buildSectionHeader(context, 'Grade'),
                    Wrap(
                      spacing: AppConstants.spacingSM,
                      runSpacing: AppConstants.spacingSM,
                      children: HadithGrade.values
                          .where((g) => g != HadithGrade.unknown)
                          .map((grade) {
                        final isSelected = currentFilter.grades.contains(grade);
                        return FilterChip(
                          label: Text(grade.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            final newGrades = Set<HadithGrade>.from(
                              currentFilter.grades);
                            if (selected) {
                              newGrades.add(grade);
                            } else {
                              newGrades.remove(grade);
                            }
                            onFilterChanged(currentFilter.copyWith(
                              grades: newGrades,
                            ));
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppConstants.spacingLG),

                    // Topics
                    _buildSectionHeader(context, 'Topics'),
                    _buildTopicsFilter(context),

                    const SizedBox(height: AppConstants.spacingLG),

                    // Bookmarked only
                    SwitchListTile(
                      title: const Text('Bookmarked Only'),
                      subtitle: const Text('Show only bookmarked hadiths'),
                      value: currentFilter.bookmarkedOnly,
                      onChanged: (value) {
                        onFilterChanged(currentFilter.copyWith(
                          bookmarkedOnly: value,
                        ));
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingLG),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTopicsFilter(BuildContext context) {
    final theme = Theme.of(context);
    final commonTopics = [
      'Prayer (Salah)',
      'Fasting (Sawm)',
      'Zakat',
      'Hajj',
      'Faith (Iman)',
      'Knowledge (Ilm)',
      'Purification (Taharah)',
      'Marriage (Nikah)',
      'Business (Buyu)',
      'Jihad',
      'Manners (Akhlaq)',
      'Supplication (Dua)',
      'Quran',
      'Prophet Muhammad',
      'Companions (Sahaba)',
    ];

    return Wrap(
      spacing: AppConstants.spacingSM,
      runSpacing: AppConstants.spacingSM,
      children: commonTopics.map((topic) {
        final isSelected = currentFilter.topics.contains(topic);
        return FilterChip(
          label: Text(topic),
          selected: isSelected,
          onSelected: (selected) {
            final newTopics = Set<String>.from(currentFilter.topics);
            if (selected) {
              newTopics.add(topic);
            } else {
              newTopics.remove(topic);
            }
            onFilterChanged(currentFilter.copyWith(topics: newTopics));
          },
        );
      }).toList(),
    );
  }
}