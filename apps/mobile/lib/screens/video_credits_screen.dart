import 'package:baseline/data/nearby_places.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';

class _SourceCredit {
  const _SourceCredit({
    required this.source,
    required this.heading,
    required this.body,
    this.licenseLabel,
    this.licenseUrl,
  });

  final String source;
  final String heading;
  final String body;
  final String? licenseLabel;
  final String? licenseUrl;
}

const _sources = [
  _SourceCredit(
    source: 'Wikimedia Commons',
    heading: 'Dardo 86 7',
    body: 'Stroke demonstrations filmed by Dardo 86 7 and published on Wikimedia Commons under Creative Commons Attribution-ShareAlike 3.0. Baseline replaced the Spanish narration with an English voiceover, removed the Spanish title cards, and converted the files to H.264. The ready-position clip is built from two of these films with held frames and slowed playback. These adapted versions are shared under CC BY-SA 3.0.',
    licenseLabel: 'CC BY-SA 3.0 license',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0',
  ),
  _SourceCredit(
    source: 'Mixkit',
    heading: 'Mixkit',
    body: 'Practice and court clips in 4K under the Mixkit Stock Video Free License. Baseline added the English voiceover.',
    licenseLabel: 'Mixkit video license',
    licenseUrl: 'https://mixkit.co/license/#videoFree',
  ),
  _SourceCredit(
    source: 'Coverr',
    heading: 'Coverr',
    body: 'Equipment, etiquette, rally, serve, and footwork clips under the Coverr License. Baseline added the English voiceover.',
    licenseLabel: 'Coverr license',
    licenseUrl: 'https://coverr.co/license',
  ),
  _SourceCredit(
    source: 'Pexels',
    heading: 'Pexels creators',
    body: 'Clips by cottonbro studio, Antoni Shkraba Studio, RDNE Stock project, Riaj Sohel, and melbourne ross under the Pexels License. Baseline added the English voiceover.',
    licenseLabel: 'Pexels license',
    licenseUrl: 'https://www.pexels.com/license/',
  ),
  _SourceCredit(
    source: 'Baseline',
    heading: 'Baseline',
    body: 'The grip, court, scoring, approach shot, and passing shot diagrams are original Baseline animations with Baseline narration.',
  ),
];

class VideoCreditsScreen extends StatelessWidget {
  const VideoCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Video credits')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const ScaledText(
            'Most of this footage was filmed by other people and studios. The credit stays with them. Every English voiceover is Baseline’s own.',
            style: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: BaselineColors.ink,
            ),
          ),
          for (final source in _sources) ...[
            const SizedBox(height: 20),
            ScaledText(
              source.source.toUpperCase(),
              style: BaselineType.eyebrow,
            ),
            const SizedBox(height: 8),
            LineCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(source.heading, style: BaselineType.cardTitle),
                  const SizedBox(height: 6),
                  ScaledText(source.body, style: BaselineType.cardBody),
                  if (source.licenseUrl != null)
                    TextButton(
                      onPressed: () => openExternal(source.licenseUrl!),
                      child: ScaledText(source.licenseLabel!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            for (final video in licensedVideos)
              if (video.source == source.source) ...[
                _CreditRow(video: video),
                const SizedBox(height: 8),
              ],
          ],
        ],
      ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.video});

  final LicensedVideo video;

  @override
  Widget build(BuildContext context) {
    return LineCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText(video.title, style: BaselineType.cardTitle),
          const SizedBox(height: 4),
          ScaledText(
            '${video.durationLabel} · ${video.creator}',
            style: BaselineType.cardBody,
          ),
          const SizedBox(height: 4),
          ScaledText(
            '${video.license} · ${video.source}',
            style: BaselineType.cardMuted,
          ),
          if (video.pageUrl.isNotEmpty)
            TextButton(
              onPressed: () => openExternal(video.pageUrl),
              child: const ScaledText('Open the original'),
            ),
        ],
      ),
    );
  }
}
