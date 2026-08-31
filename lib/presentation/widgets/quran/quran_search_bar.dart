/// Quran search bar widget

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class QuranSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onFilterTap;
  final String? hintText;
  final TextEditingController? controller;

  const QuranSearchBar({
    super.key,
    required this.onSearch,
    required this.onFilterTap,
    this.hintText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText ?? 'Search Quran...',
                prefixIcon: const Icon(Icons.search),
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
              onChanged: onSearch,
              onSubmitted: onSearch,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMD),
          IconButton(
            onPressed: onFilterTap,
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

/// Search bar with history
class SearchBarWithHistory extends ConsumerStatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onFilterTap;
  final String? hintText;

  const SearchBarWithHistory({
    super.key,
    required this.onSearch,
    required this.onFilterTap,
    this.hintText,
  });

  @override
  ConsumerState<SearchBarWithHistory> createState() => _SearchBarWithHistoryState();
}

class _SearchBarWithHistoryState extends ConsumerState<SearchBarWithHistory> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

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
      _showHistory();
    } else {
      _removeOverlay();
    }
  }

  void _showHistory() {
    // TODO: Show search history overlay
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
                hintText: widget.hintText ?? 'Search Quran...',
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