import 'package:baseline/data/videos.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/clip_player.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VideoLibraryScreen extends StatelessWidget {
  const VideoLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              color: BaselineColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          LineCard(
            semanticsLabel: 'Video credits',
            onTap: () => context.push('/credits'),
            child: const Row(
              children: [
                Expanded(
                  child: ScaledText(
                    'Video credits',
                    style: BaselineType.cardTitle,
                  ),
                ),
                Icon(Icons.chevron_right, color: BaselineColors.ink),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final video in licensedVideos) ...[
            LineCard(
              semanticsLabel: '${video.title}, ${video.durationLabel}',
              onTap: () => context.push('/video/${video.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    video.category.toUpperCase(),
                    style: BaselineType.eyebrowFairway,
                  ),
                  const SizedBox(height: 4),
                  ScaledText(video.title, style: BaselineType.cardTitle),
                  const SizedBox(height: 4),
                  ScaledText(
                    '${video.durationLabel} · ${video.attribution}',
                    style: BaselineType.cardBody,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
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
