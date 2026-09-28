import 'dart:io';

import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/screens/video_credits_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every demonstration has a license record and a file', () {
    expect(licensedVideos.length, greaterThanOrEqualTo(45));
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
