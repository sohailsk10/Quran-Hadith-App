/// Settings page with comprehensive app configuration

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/settings_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/section_header.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Settings',
      showBackButton: false,
      child: Consumer(
        builder: (context, ref, _) {
          final settingsAsync = ref.watch(settingsProvider);

          return settingsAsync.when(
            data: (settings) => Column(
              children: [
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(icon: Icon(Icons.palette_outlined), text: 'Appearance'),
                    Tab(icon: Icon(Icons.menu_book_outlined), text: 'Quran'),
                    Tab(icon: Icon(Icons.library_books_outlined), text: 'Hadith'),
                    Tab(icon: Icon(Icons.graphic_eq_outlined), text: 'Audio'),
                    Tab(icon: Icon(Icons.more_horiz_outlined), text: 'More'),
                  ],
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppearanceTab(settings),
                      _buildQuranTab(settings),
                      _buildHadithTab(settings),
                      _buildAudioTab(settings),
                      _buildMoreTab(settings),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
      ),
    );
  }

  Widget _buildAppearanceTab(AppSettings settings) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme Mode
          SectionHeader(title: 'Theme'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildThemeModeSelector(settings),
          const SizedBox(height: AppConstants.spacingLG),

          // Language
          SectionHeader(title: 'Language'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildLanguageSelector(settings),
          const SizedBox(height: AppConstants.spacingLG),

          // Font Scale
          SectionHeader(title: 'Font Scale'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildFontScaleSlider(settings),
          const SizedBox(height: AppConstants.spacingLG),

          // Animations
          SectionHeader(title: 'Animations'),
          const SizedBox(height: AppConstants.spacingMD),
          SwitchListTile(
            title: const Text('Enable Animations'),
            subtitle: const Text('Toggle UI animations'),
            value: settings.animationsEnabled,
            onChanged: (value) => ref.read(settingsProvider.notifier).updateAnimationsEnabled(value),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeSelector(AppSettings settings) {
    final theme = Theme.of(context);
    final modes = [
      (ThemeMode.system, 'System', Icons.brightness_auto),
      (ThemeMode.light, 'Light', Icons.light_mode),
      (ThemeMode.dark, 'Dark', Icons.dark_mode),
    ];

    return Wrap(
      spacing: AppConstants.spacingMD,
      runSpacing: AppConstants.spacingMD,
      children: modes.map((mode) {
        final isSelected = settings.themeMode == mode.$1;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(mode.$3, size: 18),
              const SizedBox(width: 8),
              Text(mode.$2),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => ref.read(settingsProvider.notifier).updateThemeMode(mode.$1),
          selectedColor: theme.colorScheme.primaryContainer,
          checkmarkColor: theme.colorScheme.onPrimaryContainer,
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSelector(AppSettings settings) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppConstants.spacingSM,
      runSpacing: AppConstants.spacingSM,
      children: AppLanguage.values.map((lang) {
        final isSelected = settings.language == lang;
        return FilterChip(
          label: Text(lang.name),
          selected: isSelected,
          onSelected: (_) => ref.read(settingsProvider.notifier).updateLanguage(lang),
          selectedColor: theme.colorScheme.primaryContainer,
          checkmarkColor: theme.colorScheme.onPrimaryContainer,
        );
      }).toList(),
    );
  }

  Widget _buildFontScaleSlider(AppSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('UI Font Scale'),
            Text('${settings.fontScale.toStringAsFixed(1)}x'),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Slider(
          value: settings.fontScale,
          min: 0.8,
          max: 1.5,
          divisions: 7,
          label: '${settings.fontScale.toStringAsFixed(1)}x',
          onChanged: (value) => ref.read(settingsProvider.notifier).updateFontScale(value),
        ),
      ],
    );
  }

  Widget _buildQuranTab(AppSettings settings) {
    final quranSettings = settings.quranDisplay;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arabic Font Size
          SectionHeader(title: 'Arabic Font Size'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildFontSizeSlider(
            'Arabic Text',
            quranSettings.fontSize,
            12,
            36,
            (value) => ref.read(settingsProvider.notifier).updateQuranDisplay(
              quranSettings.copyWith(fontSize: value),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Translation Font Size
          SectionHeader(title: 'Translation Font Size'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildFontSizeSlider(
            'Translation Text',
            quranSettings.translationFontSize,
            10,
            24,
            (value) => ref.read(settingsProvider.notifier).updateQuranDisplay(
              quranSettings.copyWith(translationFontSize: value),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Display Options
          SectionHeader(title: 'Display Options'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildDisplayOption(
            'Show Verse Numbers',
            'Display ayah numbers in the text',
            quranSettings.showVerseNumbers,
            (value) => ref.read(settingsProvider.notifier).updateQuranDisplay(
              quranSettings.copyWith(showVerseNumbers: value),
            ),
          ),
          _buildDisplayOption(
            'Show Sajdah Markers',
            'Highlight verses requiring prostration',
            quranSettings.showSajdahMarkers,
            (value) => ref.read(settingsProvider.notifier).updateQuranDisplay(
              quranSettings.copyWith(showSajdahMarkers: value),
            ),
          ),
          _buildDisplayOption(
            'Show Bismillah',
            'Display Bismillah at start of each surah',
            quranSettings.showBismillah,
            (value) => ref.read(settingsProvider.notifier).updateQuranDisplay(
              quranSettings.copyWith(showBismillah: value),
            ),
          ),
          _buildDisplayOption(
            'Show Page Numbers',
            'Display Quran page numbers',
            quranSettings.showPageNumbers,
            (value) => ref.read(settingsProvider.notifier).updateQuranDisplay(
              quranSettings.copyWith(showPageNumbers: value),
            ),
          ),
          _buildDisplayOption(
            'Show Juz Markers',
            'Display Juz boundaries',
            quranSettings.showJuzMarkers,
            (value) => ref.read(settingsProvider.notifier).updateQuranDisplay(
              quranSettings.copyWith(showJuzMarkers: value),
            ),
          ),
          _buildDisplayOption(
            'Highlight Tajweed',
            'Color-code tajweed rules',
            quranSettings.highlightTajweed,
            (value) => ref.read(settingsProvider.notifier).updateQuranDisplay(
              quranSettings.copyWith(highlightTajweed: value),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Default Translation
          SectionHeader(title: 'Default Translation'),
          const SizedBox(height: AppConstants.spacingMD),
          Consumer(
            builder: (context, ref, _) {
              final translationsAsync = ref.watch(translationsProvider);
              return translationsAsync.when(
                data: (translations) => Wrap(
                  spacing: AppConstants.spacingSM,
                  runSpacing: AppConstants.spacingSM,
                  children: translations.map((t) {
                    final isSelected = t.id == settings.selectedTranslationId;
                    return FilterChip(
                      label: Text(t.name),
                      selected: isSelected,
                      onSelected: (_) => ref.read(settingsProvider.notifier).updateTranslation(t.id),
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.onPrimaryContainer,
                    );
                  }).toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading translations'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHadithTab(AppSettings settings) {
    final hadithSettings = settings.hadithDisplay;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Font Size
          SectionHeader(title: 'Font Size'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildFontSizeSlider(
            'Hadith Text',
            hadithSettings.fontSize,
            10,
            24,
            (value) => ref.read(settingsProvider.notifier).updateHadithDisplay(
              hadithSettings.copyWith(fontSize: value),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Minimum Grade
          SectionHeader(title: 'Minimum Grade Filter'),
          const SizedBox(height: AppConstants.spacingMD),
          Wrap(
            spacing: AppConstants.spacingSM,
            runSpacing: AppConstants.spacingSM,
            children: HadithGrade.values.where((g) => g != HadithGrade.unknown).map((grade) {
              final isSelected = hadithSettings.minGrade.index <= grade.index;
              return FilterChip(
                label: Text(grade.arabicName),
                selected: isSelected,
                onSelected: (_) => ref.read(settingsProvider.notifier).updateHadithDisplay(
                  hadithSettings.copyWith(minGrade: grade),
                ),
                selectedColor: theme.colorScheme.primaryContainer,
                checkmarkColor: theme.colorScheme.onPrimaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Display Options
          SectionHeader(title: 'Display Options'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildDisplayOption(
            'Show Arabic Text',
            'Display original Arabic alongside translation',
            hadithSettings.showArabic,
            (value) => ref.read(settingsProvider.notifier).updateHadithDisplay(
              hadithSettings.copyWith(showArabic: value),
            ),
          ),
          _buildDisplayOption(
            'Show Grade Badges',
            'Display authenticity grade for each hadith',
            hadithSettings.showGrade,
            (value) => ref.read(settingsProvider.notifier).updateHadithDisplay(
              hadithSettings.copyWith(showGrade: value),
            ),
          ),
          _buildDisplayOption(
            'Show Narrator Chain',
            'Display isnad (chain of narrators)',
            hadithSettings.showNarratorChain,
            (value) => ref.read(settingsProvider.notifier).updateHadithDisplay(
              hadithSettings.copyWith(showNarratorChain: value),
            ),
          ),
          _buildDisplayOption(
            'Show Reference',
            'Display book/chapter/hadith numbers',
            hadithSettings.showReference,
            (value) => ref.read(settingsProvider.notifier).updateHadithDisplay(
              hadithSettings.copyWith(showReference: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioTab(AppSettings settings) {
    final audioSettings = settings.audio;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Default Reciter
          SectionHeader(title: 'Default Reciter'),
          const SizedBox(height: AppConstants.spacingMD),
          Consumer(
            builder: (context, ref, _) {
              final recitersAsync = ref.watch(recitersProvider);
              return recitersAsync.when(
                data: (reciters) => Wrap(
                  spacing: AppConstants.spacingSM,
                  runSpacing: AppConstants.spacingSM,
                  children: reciters.map((r) {
                    final isSelected = r.id == audioSettings.selectedReciterId;
                    return FilterChip(
                      label: Text(r.name),
                      selected: isSelected,
                      onSelected: (_) => ref.read(settingsProvider.notifier).updateAudioSettings(
                        audioSettings.copyWith(selectedReciterId: r.id),
                      ),
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.onPrimaryContainer,
                    );
                  }).toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading reciters'),
              );
            },
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Audio Options
          SectionHeader(title: 'Playback Options'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildDisplayOption(
            'Auto Play Next',
            'Automatically play next ayah/hadith',
            audioSettings.autoPlayNext,
            (value) => ref.read(settingsProvider.notifier).updateAudioSettings(
              audioSettings.copyWith(autoPlayNext: value),
            ),
          ),
          _buildDisplayOption(
            'Repeat Mode',
            'Repeat current ayah/surah',
            audioSettings.repeatMode != RepeatMode.off,
            (value) => ref.read(settingsProvider.notifier).updateAudioSettings(
              audioSettings.copyWith(repeatMode: value ? RepeatMode.one : RepeatMode.off),
            ),
          ),
          _buildDisplayOption(
            'Background Playback',
            'Continue playback when app is backgrounded',
            audioSettings.backgroundPlayback,
            (value) => ref.read(settingsProvider.notifier).updateAudioSettings(
              audioSettings.copyWith(backgroundPlayback: value),
            ),
          ),
          _buildDisplayOption(
            'Show Notification',
            'Show media controls in notification shade',
            audioSettings.showNotification,
            (value) => ref.read(settingsProvider.notifier).updateAudioSettings(
              audioSettings.copyWith(showNotification: value),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Playback Speed
          SectionHeader(title: 'Default Playback Speed'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildFontSizeSlider(
            'Speed',
            audioSettings.playbackSpeed,
            0.5,
            2.0,
            (value) => ref.read(settingsProvider.notifier).updateAudioSettings(
              audioSettings.copyWith(playbackSpeed: value),
            ),
            isDouble: true,
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Gapless Playback
          SectionHeader(title: 'Gapless Playback'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildDisplayOption(
            'Enable Gapless',
            'Seamless transitions between tracks',
            audioSettings.gaplessPlayback,
            (value) => ref.read(settingsProvider.notifier).updateAudioSettings(
              audioSettings.copyWith(gaplessPlayback: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTab(AppSettings settings) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notifications
          SectionHeader(title: 'Notifications'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildDisplayOption(
            'Daily Hadith',
            'Receive a random hadith each day',
            settings.notifications.dailyHadith,
            (value) => ref.read(settingsProvider.notifier).updateNotificationSettings(
              settings.notifications.copyWith(dailyHadith: value),
            ),
          ),
          _buildDisplayOption(
            'Prayer Times',
            'Get notified for prayer times',
            settings.notifications.prayerTimes,
            (value) => ref.read(settingsProvider.notifier).updateNotificationSettings(
              settings.notifications.copyWith(prayerTimes: value),
            ),
          ),
          _buildDisplayOption(
            'Quran Reminder',
            'Daily reminder to read Quran',
            settings.notifications.quranReminder,
            (value) => ref.read(settingsProvider.notifier).updateNotificationSettings(
              settings.notifications.copyWith(quranReminder: value),
            ),
          ),
          _buildDisplayOption(
            'Reminder Time',
            'Set time for daily reminders',
            true,
            (value) {},
            trailing: Text(
              settings.notifications.reminderTime,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTapTrailing: () => _showTimePicker(settings),
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Privacy
          SectionHeader(title: 'Privacy & Data'),
          const SizedBox(height: AppConstants.spacingMD),
          _buildDisplayOption(
            'Analytics',
            'Help improve the app with anonymous usage data',
            settings.privacy.analytics,
            (value) => ref.read(settingsProvider.notifier).updatePrivacySettings(
              settings.privacy.copyWith(analytics: value),
            ),
          ),
          _buildDisplayOption(
            'Crash Reporting',
            'Automatically send crash reports',
            settings.privacy.crashReporting,
            (value) => ref.read(settingsProvider.notifier).updatePrivacySettings(
              settings.privacy.copyWith(crashReporting: value),
            ),
          ),
          _buildDisplayOption(
            'Auto Download',
            'Download content for offline use on WiFi',
            settings.privacy.autoDownloadOnWifi,
            (value) => ref.read(settingsProvider.notifier).updatePrivacySettings(
              settings.privacy.copyWith(autoDownloadOnWifi: value),
            ),
          ),
          _buildDisplayOption(
            'Sync Bookmarks',
            'Sync bookmarks across devices',
            settings.privacy.syncBookmarks,
            (value) => ref.read(settingsProvider.notifier).updatePrivacySettings(
              settings.privacy.copyWith(syncBookmarks: value),
            ),
          ),
          _buildDisplayOption(
            'Share Progress',
            'Share reading progress with community',
            settings.privacy.shareProgress,
            (value) => ref.read(settingsProvider.notifier).updatePrivacySettings(
              settings.privacy.copyWith(shareProgress: value),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Storage
          SectionHeader(title: 'Storage'),
          const SizedBox(height: AppConstants.spacingMD),
          Consumer(
            builder: (context, ref, _) {
              return FutureBuilder<int>(
                future: _getStorageSize(),
                builder: (context, snapshot) => ListTile(
                  leading: Icon(Icons.storage_outlined, color: theme.colorScheme.primary),
                  title: const Text('Storage Used'),
                  subtitle: Text('${_formatBytes(snapshot.data ?? 0)}'),
                  trailing: TextButton(
                    onPressed: _clearCache,
                    child: const Text('Clear Cache'),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // About
          SectionHeader(title: 'About'),
          const SizedBox(height: AppConstants.spacingMD),
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
            title: const Text('Version'),
            subtitle: Text(AppConstants.appVersion),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
            title: const Text('Licenses'),
            onTap: () => showLicensePage(context: context),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: theme.colorScheme.primary),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.article_outlined, color: theme.colorScheme.primary),
            title: const Text('Terms of Service'),
            onTap: () {},
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Reset
          SectionHeader(title: 'Reset'),
          const SizedBox(height: AppConstants.spacingMD),
          OutlinedButton.icon(
            icon: const Icon(Icons.restore_outlined),
            label: const Text('Reset All Settings'),
            onPressed: _showResetDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    bool isDouble = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(isDouble ? value.toStringAsFixed(1) : '${value.toInt()}'),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * (isDouble ? 10 : 1)).toInt(),
          label: isDouble ? value.toStringAsFixed(1) : '${value.toInt()}',
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDisplayOption(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    Widget? trailing,
    VoidCallback? onTapTrailing,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      trailing: trailing != null
          ? InkWell(
              onTap: onTapTrailing,
              child: trailing,
            )
          : null,
    );
  }

  void _showTimePicker(AppSettings settings) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(settings.notifications.reminderTime.split(':')[0]),
        minute: int.parse(settings.notifications.reminderTime.split(':')[1]),
      ),
    ).then((time) {
      if (time != null) {
        final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        ref.read(settingsProvider.notifier).updateNotificationSettings(
          settings.notifications.copyWith(reminderTime: formatted),
        );
      }
    });
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings?'),
        content: const Text('This will restore all settings to their default values. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<int> _getStorageSize() async {
    // TODO: Calculate actual storage size
    return 50 * 1024 * 1024; // 50 MB placeholder
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _clearCache() {
    // TODO: Implement cache clearing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared')),
    );
  }
}