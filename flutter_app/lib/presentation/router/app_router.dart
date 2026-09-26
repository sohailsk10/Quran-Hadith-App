/// App Router configuration using GoRouter

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/quran/quran_page.dart';
import '../../presentation/pages/quran/surah_page.dart';
import '../../presentation/pages/quran/ayah_detail_page.dart';
import '../../presentation/pages/hadith/hadith_page.dart';
import '../../presentation/pages/hadith/collection_page.dart';
import '../../presentation/pages/hadith/book_page.dart';
import '../../presentation/pages/hadith/hadith_detail_page.dart';
import '../../presentation/pages/search/search_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/audio/audio_player_page.dart';
import '../../presentation/pages/bookmarks/bookmarks_page.dart';
import '../../presentation/pages/topic/hadith_topic_page.dart';
import '../../presentation/pages/namaz/namaz_timings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),

          // Quran
          GoRoute(
            path: '/quran',
            name: 'quran',
            builder: (context, state) => const QuranPage(),
            routes: [
              GoRoute(
                path: 'surah/:surahNumber',
                name: 'surah',
                builder: (context, state) {
                  final surahNumber =
                      int.parse(state.pathParameters['surahNumber']!);
                  return SurahPage(surahNumber: surahNumber);
                },
                routes: [
                  GoRoute(
                    path: 'ayah/:ayahNumber',
                    name: 'ayah',
                    builder: (context, state) {
                      final surahNumber =
                          int.parse(state.pathParameters['surahNumber']!);
                      final ayahNumber =
                          int.parse(state.pathParameters['ayahNumber']!);
                      return AyahDetailPage(
                          surahNumber: surahNumber, ayahNumber: ayahNumber);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'juz/:juzNumber',
                name: 'juz',
                builder: (context, state) {
                  final juzNumber =
                      int.parse(state.pathParameters['juzNumber']!);
                  return QuranPage(initialJuz: juzNumber);
                },
              ),
              GoRoute(
                path: 'page/:pageNumber',
                name: 'page',
                builder: (context, state) {
                  final pageNumber =
                      int.parse(state.pathParameters['pageNumber']!);
                  return QuranPage(initialPage: pageNumber);
                },
              ),
            ],
          ),

          // Hadith
          GoRoute(
            path: '/hadith',
            name: 'hadith',
            builder: (context, state) => const HadithPage(),
            routes: [
              GoRoute(
                path: 'collection/:collectionId',
                name: 'collection',
                builder: (context, state) {
                  final collectionId = state.pathParameters['collectionId']!;
                  return CollectionPage(collectionId: collectionId);
                },
                routes: [
                  GoRoute(
                    path: 'hadith/:hadithNumber',
                    name: 'collection-hadith-detail',
                    builder: (context, state) {
                      final collectionId =
                          state.pathParameters['collectionId']!;
                      final hadithNumber =
                          int.parse(state.pathParameters['hadithNumber']!);
                      return HadithDetailPage(
                          collectionId: collectionId,
                          hadithNumber: hadithNumber);
                    },
                  ),
                  GoRoute(
                    path: 'book/:bookNumber',
                    name: 'book',
                    builder: (context, state) {
                      final collectionId =
                          state.pathParameters['collectionId']!;
                      final bookNumber =
                          int.parse(state.pathParameters['bookNumber']!);
                      return BookPage(
                          collectionId: collectionId, bookNumber: bookNumber);
                    },
                    routes: [
                      GoRoute(
                        path: 'hadith/:hadithNumber',
                        name: 'hadith-detail',
                        builder: (context, state) {
                          final collectionId =
                              state.pathParameters['collectionId']!;
                          final hadithNumber =
                              int.parse(state.pathParameters['hadithNumber']!);
                          return HadithDetailPage(
                              collectionId: collectionId,
                              hadithNumber: hadithNumber);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'topic/:topicId',
                name: 'topic',
                builder: (context, state) {
                  final topicId = state.pathParameters['topicId']!;
                  return HadithTopicPage(topicId: topicId);
                },
              ),
              GoRoute(
                path: 'random',
                name: 'random-hadith',
                builder: (context, state) => const HadithDetailPage(
                    collectionId: 'bukhari', hadithNumber: 1),
              ),
            ],
          ),

          // Search
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),

          // Bookmarks
          GoRoute(
            path: '/bookmarks',
            name: 'bookmarks',
            builder: (context, state) => const BookmarksPage(),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),

          // Namaz Timings
          GoRoute(
            path: '/namaz-timings',
            name: 'namaz-timings',
            builder: (context, state) => const NamazTimingsPage(),
          ),
        ],
      ),

      // Full-screen pages (no bottom nav)
      GoRoute(
        path: '/audio-player',
        name: 'audio-player',
        builder: (context, state) => const AudioPlayerPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Main shell with hamburger menu drawer
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const _AppDrawer(),
      body: child,
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.toString();

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 48,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Quran & Hadith',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Learn • Read • Reflect',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                  isSelected: location == '/home' || location == '/',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/home');
                  },
                ),
                _DrawerItem(
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book,
                  label: 'Quran',
                  isSelected: location.startsWith('/quran'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/quran');
                  },
                ),
                _DrawerItem(
                  icon: Icons.library_books_outlined,
                  selectedIcon: Icons.library_books,
                  label: 'Hadith',
                  isSelected: location.startsWith('/hadith'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/hadith');
                  },
                ),
                _DrawerItem(
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search,
                  label: 'Search',
                  isSelected: location.startsWith('/search'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/search');
                  },
                ),
                _DrawerItem(
                  icon: Icons.bookmark_outline,
                  selectedIcon: Icons.bookmark,
                  label: 'Bookmarks',
                  isSelected: location.startsWith('/bookmarks'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/bookmarks');
                  },
                ),
                _DrawerItem(
                  icon: Icons.access_time_outlined,
                  selectedIcon: Icons.access_time,
                  label: 'Namaz Timings',
                  isSelected: location.startsWith('/namaz-timings'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/namaz-timings');
                  },
                ),
                const Divider(),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Settings',
                  isSelected: location.startsWith('/settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/settings');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}
