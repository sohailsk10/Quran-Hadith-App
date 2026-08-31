import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'presentation/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/router/app_router.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/quran/quran_page.dart';
import 'presentation/pages/hadith/hadith_page.dart'
import 'presentation/pages/search/search_page.dart';
import 'presentation/pages/settings/settings_page.dart';
import 'presentation/pages/audio/audio_player_page.dart';
import 'presentation/widgets/common/app_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Just Audio Background
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.flutter.hadith.app.audio',
    androidNotificationChannelName: 'Quran Audio',
    androidNotificationOngoing: true,
  );

  // Run app with ProviderScope
  runApp(const ProviderScope(child: QuranHadithApp()));
}

/// Main App Widget
class QuranHadithApp extends ConsumerWidget {
  const QuranHadithApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          locale: Locale(settings.language.code),
          supportedLocales: AppLanguage.values.map((l) => Locale(l.code)).toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(settings.quranDisplay.fontSize / 14.0),
              ),
              child: child!,
            );
          },
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to initialize app: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(settingsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}