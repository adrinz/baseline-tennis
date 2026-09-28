import 'package:baseline/data/nearby_places.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Pauses whichever demonstration is playing when another one starts.
class DemonstrationPlayback {
  static final _pauses = <String, Future<void> Function()>{};

  static void register(String id, Future<void> Function() pause) {
    _pauses[id] = pause;
  }

  static void unregister(String id) {
    _pauses.remove(id);
  }

  static Future<void> pauseOthers(String id) async {
    for (final entry in _pauses.entries) {
      if (entry.key != id) await entry.value();
    }
  }
}

class DemonstrationCard extends StatefulWidget {
  const DemonstrationCard({super.key, required this.video});

  final LicensedVideo video;

  @override
  State<DemonstrationCard> createState() => _DemonstrationCardState();
}

class _DemonstrationCardState extends State<DemonstrationCard> {
  VideoPlayerController? _controller;
  var _failed = false;
  var _showTranscript = false;

  @override
  void initState() {
    super.initState();
    DemonstrationPlayback.register(widget.video.id, _pause);
  }

  @override
  void dispose() {
    DemonstrationPlayback.unregister(widget.video.id);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _pause() async {
    final controller = _controller;
    if (controller != null && controller.value.isPlaying) {
      await controller.pause();
      if (mounted) setState(() {});
    }
  }

  Future<void> _toggle() async {
    final existing = _controller;
    if (existing != null && existing.value.isInitialized) {
      if (existing.value.isPlaying) {
        await existing.pause();
      } else {
        await DemonstrationPlayback.pauseOthers(widget.video.id);
        await existing.play();
      }
      if (mounted) setState(() {});
      return;
    }

    final controller = VideoPlayerController.asset(widget.video.asset);
    _controller = controller;
    controller.addListener(() {
      if (mounted) setState(() {});
    });
    setState(() => _failed = false);
    try {
      await controller.initialize();
      await DemonstrationPlayback.pauseOthers(widget.video.id);
      await controller.play();
      if (mounted) setState(() {});
    } catch (_) {
      await controller.dispose();
      _controller = null;
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    final playing = ready && controller.value.isPlaying;
    final aspect = ready && controller.value.aspectRatio > 0
        ? controller.value.aspectRatio
        : 16 / 9;
    final progress = ready && controller.value.duration.inMilliseconds > 0
        ? controller.value.position.inMilliseconds /
              controller.value.duration.inMilliseconds
        : 0.0;

    return Material(
      color: BaselineColors.card,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BaselineColors.ink.withValues(alpha: 0.16)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              button: true,
              label:
                  '${playing ? 'Pause' : 'Play'} ${video.title}, ${video.durationLabel}. Credit ${video.creator}.',
              child: InkWell(
                onTap: _toggle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: aspect,
                      child: ColoredBox(
                        color: BaselineColors.nightCourt,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (ready)
                              FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: controller.value.size.width,
                                  height: controller.value.size.height,
                                  child: VideoPlayer(controller),
                                ),
                              ),
                            Icon(
                              playing
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: BaselineColors.ball,
                              size: playing ? 36 : 56,
                            ),
                            if (_failed)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: ScaledText(
                                  'This clip could not be played.',
                                  style: TextStyle(color: BaselineColors.line),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (ready)
                      LinearProgressIndicator(
                        value: progress.clamp(0, 1),
                        minHeight: 3,
                        color: BaselineColors.ball,
                        backgroundColor: BaselineColors.nightCourt,
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScaledText(
                            'DEMONSTRATION',
                            style: BaselineType.eyebrowFairway,
                          ),
                          const SizedBox(height: 4),
                          ScaledText(
                            video.title,
                            style: BaselineType.cardTitle,
                          ),
                          const SizedBox(height: 4),
                          ScaledText(
                            video.durationLabel,
                            style: BaselineType.cardBody,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: ScaledText('CREDIT', style: BaselineType.eyebrowFairway),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: ScaledText(video.creator, style: BaselineType.cardTitle),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: ScaledText(
                '${video.source} · ${video.license}',
                style: BaselineType.cardBody,
              ),
            ),
            if (video.narration.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                child: ScaledText(
                  'Narration: ${video.narration}.',
                  style: BaselineType.cardMuted,
                ),
              ),
            if (video.adaptation.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                child: ScaledText(
                  video.adaptation,
                  style: BaselineType.cardMuted,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
              child: Wrap(
                children: [
                  if (video.pageUrl.isNotEmpty)
                    TextButton(
                      onPressed: () => openExternal(video.pageUrl),
                      child: const ScaledText('Original'),
                    ),
                  if (video.licenseUrl.isNotEmpty)
                    TextButton(
                      onPressed: () => openExternal(video.licenseUrl),
                      child: const ScaledText('License'),
                    ),
                  if (video.transcript.isNotEmpty)
                    TextButton(
                      onPressed: () =>
                          setState(() => _showTranscript = !_showTranscript),
                      child: ScaledText(
                        _showTranscript ? 'Hide transcript' : 'Transcript',
                      ),
                    ),
                ],
              ),
            ),
            if (_showTranscript)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: ScaledText(
                  video.transcript,
                  style: BaselineType.cardBody,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
