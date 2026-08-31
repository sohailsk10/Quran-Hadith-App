/// Full-screen audio player page

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../shared/models/quran_models.dart';
import '../../../shared/models/hadith_models.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/audio/audio_controls.dart';
import '../../widgets/audio/audio_progress_bar.dart';
import '../../widgets/audio/reciter_selector.dart';

class AudioPlayerPage extends ConsumerStatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  ConsumerState<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends ConsumerState<AudioPlayerPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quranHadithTheme = theme.quranHadith;
    final audioState = ref.watch(audioPlayerProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: quranHadithTheme.quranGradient,
        ),
        child: SafeArea(
          child: audioState.when(
            data: (state) => _buildPlayerContent(context, state),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerContent(BuildContext context, AudioPlayerState state) {
    final theme = Theme.of(context);
    final currentItem = state.currentItem;

    if (currentItem == null) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Album Art / Surah Info
                Expanded(
                  flex: 3,
                  child: _buildAlbumArt(currentItem),
                ),

                // Progress Bar
                _buildProgressSection(state),

                // Main Controls
                _buildMainControls(state),

                // Additional Controls
                _buildAdditionalControls(state),

                const SizedBox(height: AppConstants.spacingLG),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const Text(
            'Now Playing',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(AudioItem currentItem) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art / Surah Circle
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    currentItem.type == AudioType.quran
                        ? Icons.menu_book_rounded
                        : Icons.library_books_rounded,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  Text(
                    currentItem.type == AudioType.quran
                        ? 'Surah ${currentItem.surahNumber}'
                        : currentItem.collectionId,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (currentItem.type == AudioType.quran) ...[
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      'Ayah ${currentItem.ayahNumber}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingLG),

          // Reciter Info
          Consumer(
            builder: (context, ref, _) {
              final recitersAsync = ref.watch(recitersProvider);
              return recitersAsync.when(
                data: (reciters) {
                  final reciter = reciters.firstWhere(
                    (r) => r.id == currentItem.reciterId,
                    orElse: () => reciters.first,
                  );
                  return Column(
                    children: [
                      Text(
                        reciter.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXS),
                      Text(
                        reciter.style,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(AudioPlayerState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLG, vertical: AppConstants.spacingMD),
      child: Column(
        children: [
          AudioProgressBar(
            progress: state.progress,
            buffered: state.buffered,
            onSeek: (position) => ref.read(audioPlayerProvider.notifier).seek(position),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(state.position),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              Text(
                _formatDuration(state.duration),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainControls(AudioPlayerState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL, vertical: AppConstants.spacingMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          _ControlButton(
            icon: Icons.shuffle_rounded,
            isActive: state.shuffleMode,
            onTap: () => ref.read(audioPlayerProvider.notifier).toggleShuffle(),
          ),

          // Previous
          _ControlButton(
            icon: Icons.skip_previous_rounded,
            size: 48,
            onTap: () => ref.read(audioPlayerProvider.notifier).previous(),
          ),

          // Play/Pause
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: theme.quranHadith.quranGradient.colors.first,
                size: 32,
              ),
              iconSize: 32,
              padding: const EdgeInsets.all(24),
              onPressed: () {
                if (state.isPlaying) {
                  ref.read(audioPlayerProvider.notifier).pause();
                } else {
                  ref.read(audioPlayerProvider.notifier).play();
                }
              },
            ),
          ),

          // Next
          _ControlButton(
            icon: Icons.skip_next_rounded,
            size: 48,
            onTap: () => ref.read(audioPlayerProvider.notifier).next(),
          ),

          // Repeat
          _ControlButton(
            icon: _getRepeatIcon(state.repeatMode),
            isActive: state.repeatMode != RepeatMode.off,
            onTap: () => _cycleRepeatMode(state.repeatMode),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalControls(AudioPlayerState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLG),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Speed
          _SecondaryControl(
            icon: Icons.speed_rounded,
            label: '${state.playbackSpeed.toStringAsFixed(1)}x',
            onTap: _showSpeedSelector,
          ),

          // Sleep Timer
          _SecondaryControl(
            icon: Icons.bedtime_rounded,
            label: state.sleepTimer > 0 ? _formatDuration(state.sleepTimer) : 'Sleep Timer',
            isActive: state.sleepTimer > 0,
            onTap: _showSleepTimerDialog,
          ),

          // Queue
          _SecondaryControl(
            icon: Icons.queue_music_rounded,
            label: 'Queue (${state.queue.length})',
            onTap: _showQueue,
          ),

          // Reciter
          _SecondaryControl(
            icon: Icons.person_rounded,
            label: 'Reciter',
            onTap: _showReciterSelector,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            'Nothing Playing',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'Start playing from Quran or Hadith',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          FilledButton.icon(
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Go to Quran'),
            onPressed: () => context.go('/quran'),
          ),
        ],
      ),
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return Icons.repeat_rounded;
      case RepeatMode.one:
        return Icons.repeat_one_rounded;
      case RepeatMode.all:
        return Icons.repeat_rounded;
      case RepeatMode.ayah:
        return Icons.repeat_one_rounded;
      case RepeatMode.surah:
        return Icons.repeat_rounded;
    }
  }

  void _cycleRepeatMode(RepeatMode current) {
    final modes = [RepeatMode.off, RepeatMode.one, RepeatMode.all, RepeatMode.surah];
    final currentIndex = modes.indexOf(current);
    final nextIndex = (currentIndex + 1) % modes.length;
    ref.read(audioPlayerProvider.notifier).setRepeatMode(modes[nextIndex]);
  }

  void _showSpeedSelector() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final currentSpeed = ref.read(audioPlayerProvider).value?.playbackSpeed ?? 1.0;

    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) => Container(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Playback Speed',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLG),
              Wrap(
                spacing: AppConstants.spacingSM,
                runSpacing: AppConstants.spacingSM,
                alignment: WrapAlignment.center,
                children: speeds.map((speed) {
                  final isSelected = currentSpeed == speed;
                  return FilterChip(
                    label: Text('${speed}x'),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(audioPlayerProvider.notifier).setPlaybackSpeed(speed);
                      Navigator.pop(context);
                    },
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingLG),
            ],
          ),
        ),
      ),
    );
  }

  void _showSleepTimerDialog() {
    final currentTimer = ref.read(audioPlayerProvider).value?.sleepTimer ?? 0;
    final options = [
      (0, 'Off'),
      (5 * 60, '5 minutes'),
      (10 * 60, '10 minutes'),
      (15 * 60, '15 minutes'),
      (30 * 60, '30 minutes'),
      (60 * 60, '1 hour'),
      (90 * 60, '1.5 hours'),
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) => Container(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sleep Timer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLG),
              ...options.map((option) => ListTile(
                title: Text(option.$2),
                trailing: currentTimer == option.$1
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(audioPlayerProvider.notifier).setSleepTimer(option.$1);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: AppConstants.spacingLG),
            ],
          ),
        ),
      ),
    );
  }

  void _showQueue() {
    final queue = ref.read(audioPlayerProvider).value?.queue ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Up Next (${queue.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(audioPlayerProvider.notifier).clearQueue(),
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMD),
              Expanded(
                child: queue.isEmpty
                    ? Center(
                        child: Text(
                          'Queue is empty',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: queue.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingSM),
                        itemBuilder: (context, index) {
                          final item = queue[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                '${index + 1}',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            title: Text(
                              item.type == AudioType.quran
                                  ? 'Surah ${item.surahNumber}, Ayah ${item.ayahNumber}'
                                  : 'Hadith ${item.hadithNumber}',
                            ),
                            subtitle: Text(item.type == AudioType.quran ? 'Quran' : 'Hadith'),
                            trailing: index == 0
                                ? Icon(Icons.play_circle_fill, color: Theme.of(context).colorScheme.primary)
                                : null,
                            onTap: () => ref.read(audioPlayerProvider.notifier).playFromQueue(index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReciterSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ReciterSelector(
        onReciterSelected: (reciterId) {
          ref.read(audioPlayerProvider.notifier).setReciter(reciterId);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Download for Offline'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Sleep Timer'),
              onTap: () {
                Navigator.pop(context);
                _showSleepTimerDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.equalizer_outlined),
              title: const Text('Equalizer'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Equalizer feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds < 0) return '0:00';
    final seconds = (milliseconds / 1000).round();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    this.size = 40,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
        ),
        child: Icon(
          icon,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _SecondaryControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SecondaryControl({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? theme.colorScheme.primary : Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive ? theme.colorScheme.primary : Colors.white,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}