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

/// Main shell with bottom navigation
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final theme = Theme.of(context);

    int currentIndex = 0;
    if (location.startsWith('/quran'))
      currentIndex = 1;
    else if (location.startsWith('/hadith'))
      currentIndex = 2;
    else if (location.startsWith('/search'))
      currentIndex = 3;
    else if (location.startsWith('/bookmarks'))
      currentIndex = 4;
    else if (location.startsWith('/settings')) currentIndex = 5;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/quran');
            break;
          case 2:
            context.go('/hadith');
            break;
          case 3:
            context.go('/search');
            break;
          case 4:
            context.go('/bookmarks');
            break;
          case 5:
            context.go('/settings');
            break;
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: const Icon(Icons.menu_book),
          label: 'Quran',
        ),
        NavigationDestination(
          icon: const Icon(Icons.library_books_outlined),
          selectedIcon: const Icon(Icons.library_books),
          label: 'Hadith',
        ),
        NavigationDestination(
          icon: const Icon(Icons.search_outlined),
          selectedIcon: const Icon(Icons.search),
          label: 'Search',
        ),
        NavigationDestination(
          icon: const Icon(Icons.bookmark_outline),
          selectedIcon: const Icon(Icons.bookmark),
          label: 'Bookmarks',
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
