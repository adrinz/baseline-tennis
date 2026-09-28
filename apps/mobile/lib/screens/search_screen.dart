import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _hit(String query, List<String> fields) {
    if (query.isEmpty) return true;
    return fields.any((field) => field.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final lessons = baselineCatalog.lessons
        .where(
          (lesson) =>
              _hit(query, [lesson.title, lesson.summary, lesson.category]),
        )
        .toList();
    final drills = baselineCatalog.drills
        .where(
          (drill) =>
              _hit(query, [drill.name, drill.objective, drill.instructions]),
        )
        .toList();
    final videos = licensedVideos
        .where(
          (video) => _hit(query, [
            video.title,
            video.technique,
            video.category,
            video.creator,
          ]),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const ScaledText('Search')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextField(
            key: const Key('search-field'),
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: BaselineColors.ink),
            decoration: const InputDecoration(
              hintText: 'Lessons, drills, and videos',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 20),
          if (lessons.isEmpty && drills.isEmpty && videos.isEmpty)
            const ScaledText(
              'No lessons, drills, or videos match that.',
              style: TextStyle(fontSize: 16, color: BaselineColors.ink),
            ),
          if (videos.isNotEmpty) ...[
            const ScaledText('VIDEOS', style: BaselineType.eyebrow),
            const SizedBox(height: 8),
            for (final video in videos) ...[
              LineCard(
                semanticsLabel: video.title,
                onTap: () => context.push('/video/${video.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(video.title, style: BaselineType.cardTitle),
                    const SizedBox(height: 4),
                    ScaledText(
                      '${video.durationLabel} · ${video.attribution}',
                      style: BaselineType.cardBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
          ],
          if (lessons.isNotEmpty) ...[
            const ScaledText('LESSONS', style: BaselineType.eyebrow),
            const SizedBox(height: 8),
            for (final lesson in lessons) ...[
              LineCard(
                semanticsLabel: lesson.title,
                onTap: () => context.go('/learn/lesson/${lesson.slug}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(lesson.title, style: BaselineType.cardTitle),
                    const SizedBox(height: 4),
                    ScaledText(lesson.summary, style: BaselineType.cardBody),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
          if (drills.isNotEmpty) ...[
            const SizedBox(height: 8),
            const ScaledText('DRILLS', style: BaselineType.eyebrow),
            const SizedBox(height: 8),
            for (final drill in drills) ...[
              LineCard(
                semanticsLabel: drill.name,
                onTap: () => context.go('/train/drill/${drill.slug}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(drill.name, style: BaselineType.cardTitle),
                    const SizedBox(height: 4),
                    ScaledText(drill.objective, style: BaselineType.cardBody),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}
