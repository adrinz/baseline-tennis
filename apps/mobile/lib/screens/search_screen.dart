import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/pill.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:baseline/widgets/section_header.dart';
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextField(
            key: const Key('search-field'),
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: BaselineColors.ink, fontSize: 17),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Lessons, drills, and videos',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: BaselineColors.muted,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          if (lessons.isEmpty && drills.isEmpty && videos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LineCard(
                tone: LineCardTone.tint,
                child: Row(
                  children: [
                    Icon(Icons.search_off_rounded, color: BaselineColors.fairway),
                    SizedBox(width: 12),
                    Expanded(
                      child: ScaledText(
                        'No lessons, drills, or videos match that.',
                        style: BaselineType.cardBody,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (videos.isNotEmpty) ...[
            const SectionHeader('VIDEOS'),
            for (final video in videos) ...[
              _ResultTile(
                icon: Icons.play_arrow_rounded,
                tone: PillTone.night,
                title: video.title,
                subtitle: '${video.durationLabel} · ${video.attribution}',
                semantics: video.title,
                onTap: () => context.push('/video/${video.id}'),
              ),
              const SizedBox(height: 8),
            ],
          ],
          if (lessons.isNotEmpty) ...[
            const SectionHeader('LESSONS'),
            for (final lesson in lessons) ...[
              _ResultTile(
                icon: Icons.menu_book_rounded,
                tone: PillTone.fairway,
                title: lesson.title,
                subtitle: lesson.summary,
                semantics: lesson.title,
                onTap: () => context.go('/learn/lesson/${lesson.slug}'),
              ),
              const SizedBox(height: 8),
            ],
          ],
          if (drills.isNotEmpty) ...[
            const SectionHeader('DRILLS'),
            for (final drill in drills) ...[
              _ResultTile(
                icon: Icons.sports_tennis_rounded,
                tone: PillTone.ball,
                title: drill.name,
                subtitle: drill.objective,
                semantics: drill.name,
                onTap: () => context.go('/train/drill/${drill.slug}'),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.semantics,
    required this.onTap,
  });

  final IconData icon;
  final PillTone tone;
  final String title;
  final String subtitle;
  final String semantics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LineCard(
      semanticsLabel: semantics,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconBadge(icon, tone: tone, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(title, style: BaselineType.cardTitle),
                const SizedBox(height: 2),
                ScaledText(
                  subtitle,
                  maxLines: 2,
                  style: BaselineType.cardMuted.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: BaselineColors.muted),
        ],
      ),
    );
  }
}
