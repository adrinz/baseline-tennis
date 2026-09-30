import 'package:baseline/data/nearby_places.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/hero_card.dart';
import 'package:baseline/widgets/pill.dart';
import 'package:baseline/widgets/pressable.dart';
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

    final radius = BorderRadius.circular(24);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: BaselineShadows.card,
      ),
      child: Material(
        color: BaselineColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: BaselineColors.ink.withValues(alpha: 0.08)),
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
                onTap: () {
                  tapFeedback();
                  _toggle();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: aspect,
                      child: ColoredBox(
                        color: BaselineColors.nightCourt,
                        child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.expand,
                          children: [
                            if (ready)
                              FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: controller.value.size.width,
                                  height: controller.value.size.height,
                                  child: VideoPlayer(controller),
                                ),
                              )
                            else
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      BaselineColors.nightGlow,
                                      BaselineColors.nightCourt,
                                    ],
                                  ),
                                ),
                              ),
                            if (!ready)
                              const Positioned(
                                right: -10,
                                top: -30,
                                width: 90,
                                height: 200,
                                child: CourtLines(opacity: 0.1),
                              ),
                            Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: playing
                                    ? const SizedBox.shrink(key: ValueKey('p'))
                                    : const _PlayBadge(key: ValueKey('i')),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              top: 12,
                              child: const Pill(
                                'DEMONSTRATION',
                                tone: PillTone.night,
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  child: ScaledText(
                                    video.durationLabel,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: BaselineColors.line,
                                    ),
                                  ),
                                ),
                              ),
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
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: ScaledText(
                        video.title,
                        style: BaselineType.cardTitle.copyWith(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ColoredBox(
              color: BaselineColors.line,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScaledText(
                      'CREDIT',
                      style: BaselineType.eyebrowFairway,
                    ),
                    const SizedBox(height: 2),
                    ScaledText(
                      video.creator,
                      style: BaselineType.cardTitle.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    ScaledText(
                      '${video.source} · ${video.license}',
                      style: BaselineType.cardMuted.copyWith(fontSize: 13.5),
                    ),
                    if (video.narration.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: ScaledText(
                          'Narration: ${video.narration}.',
                          style: BaselineType.cardMuted,
                        ),
                      ),
                    if (video.adaptation.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: ScaledText(
                          video.adaptation,
                          style: BaselineType.cardMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ColoredBox(
              color: BaselineColors.line,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
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
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _showTranscript
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: ScaledText(
                        video.transcript,
                        style: BaselineType.cardBody,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: BaselineColors.ball,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Icon(
          Icons.play_arrow_rounded,
          size: 40,
          color: BaselineColors.nightCourt,
        ),
      ),
    );
  }
}
