/// Common app scaffold with consistent styling

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget child;
  final FloatingActionButton? floatingActionButton;
  final bool extendBody;

  const AppScaffold({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    required this.child,
    this.floatingActionButton,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: extendBody,
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: actions,
        elevation: 0,
        scrolledUnderElevation: AppConstants.spacingXS,
        surfaceTintColor: theme.colorScheme.surfaceTint,
      ),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Sliver App Scaffold for CustomScrollView
class SliverAppScaffold extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget sliverChild;
  final FloatingActionButton? floatingActionButton;

  const SliverAppScaffold({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    required this.sliverChild,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(title),
            leading: showBackButton
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
            actions: actions,
            elevation: 0,
            scrolledUnderElevation: AppConstants.spacingXS,
            floating: true,
            snap: true,
          ),
          sliverChild,
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Gradient App Scaffold
class GradientAppScaffold extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget child;
  final Gradient gradient;
  final FloatingActionButton? floatingActionButton;

  const GradientAppScaffold({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    required this.child,
    required this.gradient,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: actions,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(child: child),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
