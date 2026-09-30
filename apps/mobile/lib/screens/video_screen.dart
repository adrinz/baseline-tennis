import 'package:baseline/data/videos.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/clip_player.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/pill.dart';
import 'package:baseline/widgets/pressable.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

String _categoryLabel(String category) {
  if (category.isEmpty) return category;
  return '${category[0].toUpperCase()}${category.substring(1)}';
}

class VideoLibraryScreen extends StatefulWidget {
  const VideoLibraryScreen({super.key});

  @override
  State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    final categories = <String>{
      for (final video in licensedVideos) video.category,
    }.toList()..sort();
    final shown = [
      for (final video in licensedVideos)
        if (_category == null || video.category == _category) video,
    ];
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Demonstrations')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const ScaledText(
            'Licensed clips you can play inside Baseline. The written lesson is still the coaching.',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: BaselineColors.muted,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final category in categories) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _categoryLabel(category),
                    selected: _category == category,
                    onTap: () => setState(() => _category = category),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final video in shown) ...[
            LineCard(
              semanticsLabel: '${video.title}, ${video.durationLabel}',
              onTap: () => context.push('/video/${video.id}'),
              child: Row(
                children: [
                  const IconBadge(
                    Icons.play_arrow_rounded,
                    tone: PillTone.night,
                    size: 48,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScaledText(
                          video.category.toUpperCase(),
                          style: BaselineType.eyebrowFairway,
                        ),
                        const SizedBox(height: 2),
                        ScaledText(video.title, style: BaselineType.cardTitle),
                        const SizedBox(height: 2),
                        ScaledText(
                          '${video.durationLabel} · ${video.attribution}',
                          maxLines: 2,
                          style: BaselineType.cardMuted,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: BaselineColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.push('/credits'),
              icon: const Icon(Icons.movie_outlined, size: 18),
              label: const ScaledText('Video credits'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label videos',
      child: ExcludeSemantics(
        child: PressScale(
          scale: 0.94,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: ShapeDecoration(
              color: selected ? BaselineColors.nightCourt : BaselineColors.card,
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected
                      ? BaselineColors.nightCourt
                      : BaselineColors.ink.withValues(alpha: 0.14),
                ),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () {
                  if (!selected) tapFeedback();
                  onTap();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: ScaledText(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? BaselineColors.ball
                            : BaselineColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final video = videoById(id);
    return Scaffold(
      appBar: AppBar(title: ScaledText(video?.title ?? 'Demonstration')),
      body: video == null
          ? const Center(child: ScaledText('Clip not found.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                DemonstrationCard(video: video),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.push('/credits'),
                    child: const ScaledText('All video credits'),
                  ),
                ),
              ],
            ),
    );
  }
}
