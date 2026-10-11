import 'dart:io';

import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/screens/video_credits_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every demonstration has a license record and a file', () {
    expect(licensedVideos.length, 81);
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

  test('new technique lessons lead with focused demonstrations', () {
    const expectedTechniques = <String, String>{
      'serve-plus-one': 'serve-plus-one',
      'inside-out-forehand': 'inside-out-forehand',
      'crossover-step': 'crossover-step',
      'kick-serve': 'kick-serve',
      'angle-shot': 'angle-shot',
      'neutral-ball': 'neutral-ball',
    };

    for (final entry in expectedTechniques.entries) {
      final videos = videosForLesson(entry.key);
      expect(videos, isNotEmpty, reason: entry.key);
      expect(videos.first.technique, entry.value, reason: entry.key);
      expect(videos.first.source, 'Baseline', reason: entry.key);
      expect(File(videos.first.asset).existsSync(), isTrue, reason: entry.key);
    }
  });

  test('the demonstration batch contains 18 original diagrams', () {
    const newDiagramIds = <String>[
      'flat-serve-diagram',
      'slice-serve-diagram',
      'return-positioning-diagram',
      'backhand-slice-diagram',
      'forehand-down-the-line-diagram',
      'cross-court-forehand-diagram',
      'swing-volley-diagram',
      'drop-volley-diagram',
      'serve-and-volley-diagram',
      'doubles-formation-diagram',
      'poaching-diagram',
      'tiebreak-strategy-diagram',
      'serve-phases-diagram',
      'return-footwork-diagram',
      'net-positioning-diagram',
      'doubles-signals-diagram',
      'defensive-net-diagram',
      'tiebreak-scoreboard-diagram',
    ];

    expect(newDiagramIds, hasLength(18));
    for (final id in newDiagramIds) {
      final video = videoById(id);
      expect(video, isNotNull, reason: id);
      expect(video!.source, 'Baseline', reason: id);
      expect(video.license, 'Baseline original', reason: id);
      expect(video.asset, 'assets/videos/$id.mp4', reason: id);
      expect(File(video.asset).existsSync(), isTrue, reason: id);
      expect(video.transcript, isNotEmpty, reason: id);
    }
  });

  test('focused lessons lead with their matching diagram', () {
    const focused = <String, String>{
      'flat-serve': 'flat-serve-diagram',
      'slice-serve': 'slice-serve-diagram',
      'return-positioning': 'return-positioning-diagram',
      'backhand-slice': 'backhand-slice-diagram',
      'forehand-down-the-line': 'forehand-down-the-line-diagram',
      'cross-court-forehand': 'cross-court-forehand-diagram',
      'swing-volley': 'swing-volley-diagram',
      'drop-volley': 'drop-volley-diagram',
      'serve-and-volley': 'serve-and-volley-diagram',
      'doubles-formation': 'doubles-formation-diagram',
      'poaching': 'poaching-diagram',
      'tiebreak-strategy': 'tiebreak-strategy-diagram',
    };

    for (final entry in focused.entries) {
      expect(
        videosForLesson(entry.key).first.id,
        entry.value,
        reason: entry.key,
      );
    }
  });

  test('supplemental diagrams are attached to their useful lessons', () {
    const supplemental = <String, String>{
      'basic-serve': 'serve-phases-diagram',
      'return-of-serve': 'return-footwork-diagram',
      'basic-volley': 'net-positioning-diagram',
      'doubles-formation': 'doubles-signals-diagram',
      'serve-and-volley': 'defensive-net-diagram',
      'tiebreak-strategy': 'tiebreak-scoreboard-diagram',
    };

    for (final entry in supplemental.entries) {
      expect(
        videosForLesson(entry.key).map((video) => video.id),
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
      'Grips on the handle',
    ]) {
      await tester.scrollUntilVisible(find.text(label), 400);
      expect(find.text(label), findsOneWidget);
    }
  });
}
