import 'package:baseline/data/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('techniques list the course skills by family', () {
    final groups = techniqueGroups();
    final skills = groups.expand((group) => group.skills).toList();
    final slugs = skills.map((skill) => skill.slug).toSet();

    expect(
      slugs,
      containsAll(const [
        'ready-position',
        'grip',
        'forehand',
        'backhand',
        'rally',
        'serve',
        'volley',
        'footwork',
        'slice',
        'topspin',
        'contact-point',
        'one-handed-backhand',
        'return',
        'smash',
        'recovery',
        'lob',
        'drop',
        'approach',
        'passing-shot',
        'second-serve',
      ]),
    );
    expect(groups.map((group) => group.id), const [
      'ready',
      'grip',
      'footwork',
      'groundstroke',
      'net',
      'serve',
      'return',
      'rally',
      'specialty',
    ]);

    final drop = skills.firstWhere((skill) => skill.slug == 'drop');
    expect(drop.title, 'Drop shot');
    expect(drop.lessonSlug, 'drop-shot');
    expect(drop.level, 3);

    final contact = skills.firstWhere((skill) => skill.slug == 'contact-point');
    expect(contact.title, 'Contact point');
    expect(contact.family, 'groundstroke');

    expect(
      groups
          .firstWhere((group) => group.id == 'specialty')
          .skills
          .map((skill) => skill.slug),
      ['approach', 'drop', 'lob', 'passing-shot'],
    );
  });
}
