import 'dart:io';

import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/screens/video_credits_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every demonstration has a license record and a file', () {
    expect(licensedVideos.length, 101);
    final ids = <String>{};
    for (final video in licensedVideos) {
      expect(ids.add(video.id), isTrue, reason: video.id);
      expect(video.title, isNotEmpty);
      expect(video.asset, 'assets/videos/${video.id}.mp4');
      expect(File(video.asset).existsSync(), isTrue, reason: video.asset);
      expect(video.creator, isNotEmpty);
      expect(video.license, isNotEmpty);
      expect(video.attribution, isNotEmpty);
      expect(video.durationSeconds, greaterThan(0));
      expect(video.technique, isNotEmpty);
      expect(video.narration, startsWith('English'));
      expect(video.transcript, isNotEmpty, reason: video.id);
      if (video.source != 'Baseline') {
        expect(video.licenseUrl, startsWith('https://'), reason: video.id);
        expect(video.pageUrl, startsWith('https://'), reason: video.id);
      }
    }
  });

  test('every lesson and drill has a demonstration', () {
    for (final lesson in baselineCatalog.lessons) {
      expect(videosForLesson(lesson.slug), isNotEmpty, reason: lesson.slug);
    }
    for (final drill in baselineCatalog.drills) {
      expect(videosForDrill(drill.slug), isNotEmpty, reason: drill.slug);
    }
  });

  test('topic lessons lead with a clip about that topic', () {
    expect(videosForLesson('grips').first.technique, 'grip');
    expect(videosForLesson('equipment').first.technique, 'equipment');
    expect(videosForLesson('etiquette').first.technique, 'etiquette');
    expect(videosForLesson('ready-position').first.technique, 'ready-position');
    expect(videosForLesson('the-court').first.technique, 'court');
    expect(videosForLesson('scoring').first.technique, 'scoring');
  });

  test('focused lessons lead with human demonstrations', () {
    const focused = <String, String>{
      'serve-plus-one': 'serve-plus-one-coverr',
      'inside-out-forehand': 'inside-out-forehand-coverr',
      'crossover-step': 'crossover-step-coverr',
      'kick-serve': 'kick-serve-pexels',
      'angle-shot': 'angle-shot-coverr',
      'neutral-ball': 'neutral-ball-pexels',
      'flat-serve': 'flat-serve-pexels',
      'slice-serve': 'slice-serve-pexels',
      'forehand-down-the-line': 'forehand-down-the-line-pexels',
      'cross-court-forehand': 'cross-court-forehand-pexels',
      'swing-volley': 'swing-volley-coverr',
      'drop-volley': 'drop-volley-coverr',
      'serve-and-volley': 'serve-and-volley-coverr',
      'doubles-formation': 'doubles-formation-coverr',
      'poaching': 'poaching-pexels',
      'tiebreak-strategy': 'tiebreak-strategy-coverr',
      'approach-shot': 'approach-live-pexels',
      'passing-shot': 'passing-shot-pexels',
    };

    for (final entry in focused.entries) {
      final videos = videosForLesson(entry.key);
      expect(videos, isNotEmpty, reason: entry.key);
      expect(videos.first.id, entry.value, reason: entry.key);
      expect(videos.first.source, isNot('Baseline'), reason: entry.key);
      expect(File(videos.first.asset).existsSync(), isTrue, reason: entry.key);
    }
  });

  test('the visible catalog contains no diagram videos', () {
    expect(
      licensedVideos.where((video) => video.id.endsWith('-diagram')),
      isEmpty,
    );
    expect(
      licensedVideos.where((video) => video.source == 'Baseline'),
      isEmpty,
    );
  });

  test('supplemental human clips are attached to their useful lessons', () {
    const supplemental = <String, String>{
      'doubles-formation': 'doubles-signals-pexels',
      'serve-and-volley': 'defensive-net-pexels',
      'tiebreak-strategy': 'tiebreak-scoreboard-pexels',
    };

    for (final entry in supplemental.entries) {
      expect(
        videosForLesson(entry.key).map((video) => video.id),
        contains(entry.value),
        reason: entry.key,
      );
    }
  });

  test('human footage replaces the five removed diagram lessons', () {
    const replacements = <String, List<String>>{
      'basic-serve': ['serve-trophy', 'serve-toss', 'serve-side'],
      'return-positioning': ['return-stance', 'ready-live', 'split-step-feet'],
      'return-of-serve': [
        'return-stance',
        'split-step-feet',
        'footwork-baseline',
      ],
      'backhand-slice': ['slice-shadow', 'backhand-one-shadow'],
      'basic-volley': ['volley-shadow'],
    };

    for (final entry in replacements.entries) {
      final ids = videosForLesson(entry.key).map((video) => video.id).toList();
      for (final id in entry.value) {
        expect(ids, contains(id), reason: entry.key);
      }
    }
  });

  test('expanded human catalog contains the 31 new Pexels alternatives', () {
    const newIds = <String>[
      'wall-rally-pexels',
      'basket-setup-pexels',
      'serve-toss-pexels',
      'serve-to-volley-pexels',
      'serve-close-pexels',
      'serve-baseline-pexels',
      'serve-routine-pexels',
      'serve-clay-pexels',
      'serve-prep-pexels',
      'serve-practice-pexels',
      'serve-repeat-pexels',
      'serve-game-pexels',
      'ball-control-pexels',
      'racket-handling-pexels',
      'player-practice-pexels',
      'match-aerial-pexels',
      'court-aerial-pexels',
      'girls-practice-pexels',
      'rally-live-pexels',
      'match-rally-pexels',
      'ball-bounce-pexels',
      'clay-rally-pexels',
      'racket-bounce-pexels',
      'racket-ball-setup-pexels',
      'racket-control-pexels',
      'vertical-toss-pexels',
      'vertical-court-practice-pexels',
      'junior-practice-pexels',
      'grip-close-pexels',
      'grip-tape-pexels',
      'racket-hold-pexels',
    ];

    expect(newIds, hasLength(31));
    for (final id in newIds) {
      final video = videoById(id);
      expect(video, isNotNull, reason: id);
      expect(video!.source, 'Pexels', reason: id);
      expect(video.pageUrl, startsWith('https://www.pexels.com/'), reason: id);
      expect(File(video.asset).existsSync(), isTrue, reason: id);
      expect(video.transcript, isNotEmpty, reason: id);
    }
  });

  test('restricted replacements have useful local alternatives', () {
    const lessonAlternatives = <String, String>{
      'basic-serve': 'serve-toss-pexels',
      'grips': 'racket-hold-pexels',
      'basic-volley': 'rally-live-pexels',
      'neutral-ball': 'match-aerial-pexels',
    };
    const drillAlternatives = <String, String>{
      'wall-rally': 'wall-rally-pexels',
      'serve-target': 'basket-setup-pexels',
    };

    for (final entry in lessonAlternatives.entries) {
      expect(
        videosForLesson(entry.key).map((video) => video.id),
        contains(entry.value),
        reason: entry.key,
      );
    }
    for (final entry in drillAlternatives.entries) {
      expect(
        videosForDrill(entry.key).map((video) => video.id),
        contains(entry.value),
        reason: entry.key,
      );
    }
  });

  testWidgets('video credits name every creator and license', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VideoCreditsScreen()));

    expect(find.text('Video credits'), findsOneWidget);
    expect(find.text('Dardo 86 7'), findsWidgets);
    expect(find.text('CC BY-SA 3.0 license'), findsOneWidget);

    for (final label in [
      'Mixkit video license',
      'Coverr license',
      'Pexels license',
      'Holding a tennis ball and racket',
    ]) {
      await tester.scrollUntilVisible(find.text(label), 400);
      expect(find.text(label), findsOneWidget);
    }
  });
}
