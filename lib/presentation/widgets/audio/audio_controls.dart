/// Audio controls widgets

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

/// Main audio controls (play/pause, next, previous, speed, sleep timer)
class AudioControls extends StatelessWidget {
  final AudioPlayer player;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double speed;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onSleepTimer;
  final Duration? sleepTimerDuration;
  final bool hasNext;
  final bool hasPrevious;

  const AudioControls({
    super.key,
    required this.player,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.speed,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onSpeedChanged,
    required this.onSleepTimer,
    this.sleepTimerDuration,
    this.hasNext = true,
    this.hasPrevious = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLG,
        vertical: AppConstants.spacingMD,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Bar
          AudioProgressBar(
            position: position,
            duration: duration,
            onSeek: (value) {
              player.seek(Duration(milliseconds: value.toInt()));
            },
          ),

          const SizedBox(height: AppConstants.spacingMD),

          // Time Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                _formatDuration(duration),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMD),

          // Main Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                onPressed: hasPrevious ? onPrevious : null,
                tooltip: 'Previous',
              ),

              // Play/Pause
              _ControlButton(
                icon: isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                onPressed: onPlayPause,
                isPrimary: true,
                tooltip: isPlaying ? 'Pause' : 'Play',
              ),

              // Next
              _ControlButton(
                icon: Icons.skip_next_rounded,
                onPressed: hasNext ? onNext : null,
                tooltip: 'Next',
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMD),

          // Secondary Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed
              _SpeedControl(
                speed: speed,
                onChanged: onSpeedChanged,
              ),

              // Sleep Timer
              _SleepTimerButton(
                duration: sleepTimerDuration,
                onPressed: onSleepTimer,
              ),

              // Queue/Repeat/Shuffle
              _QueueButton(
                player: player,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    this.onPressed,
    this.isPrimary = false,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isPrimary) {
      return Tooltip(
        message: tooltip,
        child: IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon, size: 48),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.all(12),
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 32),
        color: onPressed != null
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}

class _SpeedControl extends StatelessWidget {
  final double speed;
  final ValueChanged<double> onChanged;

  static const List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  const _SpeedControl({
    required this.speed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<double>(
      initialValue: speed,
      onSelected: onChanged,
      tooltip: 'Playback speed',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.speed_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${speed}x',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => _speeds.map((s) {
        return PopupMenuItem<double>(
          value: s,
          child: Row(
            children: [
              if (s == speed)
                Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
              if (s == speed) const SizedBox(width: 8),
              Text('${s}x'),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SleepTimerButton extends StatelessWidget {
  final Duration? duration;
  final VoidCallback onPressed;

  static const List<Duration> _durations = [
    Duration(minutes: 10),
    Duration(minutes: 20),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(minutes: 60),
    Duration(minutes: 90),
    Duration(hours: 2),
  ];

  const _SleepTimerButton({
    this.duration,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = duration != null;

    return PopupMenuButton<Duration?>(
      initialValue: duration,
      onSelected: (value) {
        if (value == null) {
          onPressed(); // Cancel timer
        } else {
          onPressed(); // Set timer (we'll handle the specific duration differently)
        }
      },
      tooltip: 'Sleep timer',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bedtime_rounded,
              size: 18,
              color: isActive
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Text(
                _formatSleepDuration(duration!),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<Duration?>(
          value: null,
          child: Row(
            children: [
              Icon(
                Icons.close_rounded,
                size: 18,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text('Cancel timer'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        ..._durations.map((d) => PopupMenuItem<Duration?>(
          value: d,
          child: Row(
            children: [
              if (d == duration)
                Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
              if (d == duration) const SizedBox(width: 8),
              Text(_formatSleepDuration(d)),
            ],
          ),
        )),
      ],
    );
  }

  String _formatSleepDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }
}

class _QueueButton extends StatelessWidget {
  final AudioPlayer player;

  const _QueueButton({required this.player});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<LoopMode>(
      stream: player.loopModeStream,
      initialData: player.loopMode,
      builder: (context, snapshot) {
        final loopMode = snapshot.data ?? LoopMode.off;
        IconData icon;
        Color color;
        String tooltip;

        switch (loopMode) {
          case LoopMode.one:
            icon = Icons.repeat_one_rounded;
            color = theme.colorScheme.primary;
            tooltip = 'Repeat one (tap for repeat all)';
            break;
          case LoopMode.all:
            icon = Icons.repeat_rounded;
            color = theme.colorScheme.primary;
            tooltip = 'Repeat all (tap for off)';
            break;
          case LoopMode.off:
          default:
            icon = Icons.repeat_rounded;
            color = theme.colorScheme.onSurfaceVariant;
            tooltip = 'Repeat off (tap for repeat all)';
        }

        return Tooltip(
          message: tooltip,
          child: IconButton(
            onPressed: () {
              switch (loopMode) {
                case LoopMode.off:
                  player.setLoopMode(LoopMode.all);
                  break;
                case LoopMode.all:
                  player.setLoopMode(LoopMode.one);
                  break;
                case LoopMode.one:
                  player.setLoopMode(LoopMode.off);
                  break;
              }
            },
            icon: Icon(icon, color: color, size: 24),
          ),
        );
      },
    );
  }
}

/// Compact audio controls for mini player
class CompactAudioControls extends StatelessWidget {
  final AudioPlayer player;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const CompactAudioControls({
    super.key,
    required this.player,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(
          icon: Icons.skip_previous_rounded,
          onPressed: onPrevious,
          tooltip: 'Previous',
        ),
        const SizedBox(width: AppConstants.spacingSM),
        _ControlButton(
          icon: isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
          onPressed: onPlayPause,
          isPrimary: true,
          tooltip: isPlaying ? 'Pause' : 'Play',
        ),
        const SizedBox(width: AppConstants.spacingSM),
        _ControlButton(
          icon: Icons.skip_next_rounded,
          onPressed: onNext,
          tooltip: 'Next',
        ),
      ],
    );
  }
}