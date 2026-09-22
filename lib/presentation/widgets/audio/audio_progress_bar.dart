/// Audio progress bar widget

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AudioProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<double> onSeek;
  final double? bufferedPosition;
  final Color? progressColor;
  final Color? bufferColor;
  final Color? thumbColor;
  final double height;
  final double thumbRadius;
  final bool showThumb;

  const AudioProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.bufferedPosition,
    this.progressColor,
    this.bufferColor,
    this.thumbColor,
    this.height = 4,
    this.thumbRadius = 8,
    this.showThumb = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = duration.inMilliseconds.toDouble();
    final current = position.inMilliseconds.toDouble();
    final buffered = bufferedPosition ?? 0;

    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final bufferProgress = total > 0 ? (buffered / total).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          final dx = localPosition.dx.clamp(0.0, renderBox.size.width);
          final value = (dx / renderBox.size.width) * total;
          onSeek(value);
        }
      },
      onTapDown: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          final dx = localPosition.dx.clamp(0.0, renderBox.size.width);
          final value = (dx / renderBox.size.width) * total;
          onSeek(value);
        }
      },
      child: SizedBox(
        height: thumbRadius * 2,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Track
            Container(
              height: height,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),

            // Buffer progress
            if (bufferProgress > 0)
              FractionallySizedBox(
                widthFactor: bufferProgress,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: bufferColor ??
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),

            // Progress
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: progressColor != null
                        ? [
                            progressColor!,
                            progressColor!.withValues(alpha: 0.7)
                          ]
                        : [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.7),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),

            // Thumb
            if (showThumb && progress > 0 && progress < 1)
              FractionallySizedBox(
                widthFactor: progress,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: thumbRadius * 2,
                    height: thumbRadius * 2,
                    decoration: BoxDecoration(
                      color: thumbColor ?? theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Thumb hit area (invisible, for better touch target)
            if (showThumb)
              FractionallySizedBox(
                widthFactor: progress,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: thumbRadius * 4,
                    height: thumbRadius * 4,
                    color: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Circular audio progress indicator
class CircularAudioProgress extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;

  const CircularAudioProgress({
    super.key,
    required this.position,
    required this.duration,
    this.strokeWidth = 4,
    this.progressColor,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = duration.inMilliseconds.toDouble();
    final current = position.inMilliseconds.toDouble();
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            backgroundColor:
                backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? theme.colorScheme.primary,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// Waveform visualization (placeholder for future implementation)
class AudioWaveform extends StatelessWidget {
  final List<double> samples;
  final Duration position;
  final Duration duration;
  final Color? waveColor;
  final Color? playedColor;
  final double height;

  const AudioWaveform({
    super.key,
    required this.samples,
    required this.position,
    required this.duration,
    this.waveColor,
    this.playedColor,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = duration.inMilliseconds.toDouble();
    final current = position.inMilliseconds.toDouble();
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final playedIndex = (samples.length * progress).floor();

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _WaveformPainter(
          samples: samples,
          playedIndex: playedIndex,
          waveColor: waveColor ?? theme.colorScheme.outlineVariant,
          playedColor: playedColor ?? theme.colorScheme.primary,
        ),
        size: Size(double.infinity, height),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> samples;
  final int playedIndex;
  final Color waveColor;
  final Color playedColor;

  _WaveformPainter({
    required this.samples,
    required this.playedIndex,
    required this.waveColor,
    required this.playedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final barWidth = size.width / samples.length;
    final centerY = size.height / 2;
    final maxHeight = size.height * 0.4;

    for (int i = 0; i < samples.length; i++) {
      final sample = samples[i].clamp(0.0, 1.0);
      final barHeight = sample * maxHeight;
      final x = i * barWidth + barWidth / 2;

      final color = i <= playedIndex ? playedColor : waveColor;

      final paint = Paint()
        ..color = color
        ..strokeWidth = barWidth * 0.8
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _WaveformPainter &&
        oldDelegate.playedIndex != playedIndex;
  }
}
