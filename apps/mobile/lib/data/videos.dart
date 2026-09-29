/// Licensed demonstration clips bundled with the app.
///
/// Commons files are CC BY-SA 3.0 by Dardo 86 7. Their Spanish narration and
/// Spanish title cards are replaced or removed, so each adapted file stays
/// under CC BY-SA 3.0. Mixkit, Coverr, and Pexels clips carry their own free
/// licenses. Diagram clips are Baseline originals. Every clip has Baseline's
/// English voiceover.
library;

class LicensedVideo {
  const LicensedVideo({
    required this.id,
    required this.title,
    required this.asset,
    required this.source,
    required this.creator,
    required this.license,
    required this.licenseUrl,
    required this.pageUrl,
    required this.attribution,
    required this.category,
    required this.level,
    required this.technique,
    required this.durationSeconds,
    this.adaptation = '',
    this.narration = '',
  });

  final String id;
  final String title;
  final String asset;
  final String source;
  final String creator;
  final String license;
  final String licenseUrl;
  final String pageUrl;
  final String attribution;
  final String category;
  final int level;
  final String technique;
  final int durationSeconds;
  final String adaptation;
  final String narration;

  String get transcript => videoTranscripts[id] ?? '';

  String get durationLabel {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

const _narration = 'English, voiced by Baseline';

const _commonsLicense = 'CC BY-SA 3.0';
const _commonsLicenseUrl = 'https://creativecommons.org/licenses/by-sa/3.0';
const _commonsAdaptation =
    'Baseline replaced the original Spanish narration with an English voiceover, removed the Spanish title card, and converted the file to H.264. This version is shared under CC BY-SA 3.0.';
const _commonsCredit = 'Dardo 86 7 · CC BY-SA 3.0 · Wikimedia Commons';

const _mixkitLicense = 'Mixkit Stock Video Free License';
const _mixkitLicenseUrl = 'https://mixkit.co/license/#videoFree';
const _mixkitCredit = 'Mixkit · free to use in this app';
const _mixkitAdaptation =
    'Baseline added an English voiceover and re-encoded the 4K master as HEVC.';

const _coverrLicense = 'Coverr License';
const _coverrLicenseUrl = 'https://coverr.co/license';
const _coverrAdaptation = 'Baseline added an English voiceover.';

const _pexelsLicense = 'Pexels License';
const _pexelsLicenseUrl = 'https://www.pexels.com/license/';
const _pexelsAdaptation = 'Baseline added an English voiceover.';

const _originalLicense = 'Baseline original';

const videoTranscripts = <String, String>{
  'forehand-shadow': 'Forehand. Start in the ready position, knees soft, racket in front. As the ball comes to your forehand side, turn your shoulders and take the racket back early. Step in with your opposite foot. Swing from low to high, and meet the ball out in front of your body, about waist height. Keep your eyes on the contact point. Finish with the racket over your opposite shoulder. Then recover to the middle, and get ready for the next ball.',
  'backhand-one-shadow': 'One-handed backhand. Turn your shoulders early, and bring the racket back with your free hand on the throat of the racket. Step across with your front foot. Let go with the free hand as you swing. Meet the ball in front of your front foot, with a firm wrist. Swing up and out toward the target, and keep your chest sideways through contact. Hold the finish, then recover.',
  'backhand-two-shadow': 'Two-handed backhand. Both hands on the grip. Turn your shoulders and take the racket back as one unit. Step toward the ball. Swing from low to high, and make contact in front of your body. Finish high over your shoulder, with both hands still on the racket. Then recover to the middle.',
  'serve-shadow': 'Serve. Stand sideways to the net, front foot pointing toward the net post. Use a continental grip. Hold the ball in your fingers, not your palm. Toss the ball up, slightly in front of your hitting shoulder. As you toss, bring the racket up behind you. Reach up, and hit the ball at the top of your reach. Let the racket follow through across your body. A good toss makes a good serve. If the toss is off, catch it, and start again.',
  'volley-shadow': 'Volley. At the net, stay low, and keep the racket up in front of you. Use a continental grip. Make a short shoulder turn, with no big backswing. Step toward the ball, and punch through it, meeting it in front of your body. Keep the racket head above your wrist. Stop the racket short after contact, and get ready for the next ball.',
  'slice-shadow': 'Slice. Take the racket back high, with the face slightly open. Swing from high to low, and brush under the back of the ball. Meet it in front of your body, and keep your wrist firm. The ball should stay low after the bounce. Finish out toward the target.',
  'drop-shadow': 'Drop shot. Prepare the same way as a normal groundstroke, so your opponent cannot read it. At the last moment, soften your grip. Open the racket face, and slice gently under the ball. Land it just over the net, with very little forward speed. Use it when your opponent is deep behind the baseline.',
  'lob-shadow': "Lob. Use the lob when your opponent is close to the net, or when you need time. Prepare early, and get low. Open the racket face, and lift the ball with a low to high swing. Aim high over your opponent's reach, and deep toward the baseline. Finish with the racket high, then recover.",
  'smash-shadow': 'Overhead smash. When you see a high ball, turn sideways, and move back with small steps. Point at the ball with your free hand to track it. Bring the racket up behind your head, like a short serve. Reach up, and hit the ball in front of you, at the highest point you can. Follow through across your body, and aim for the open court. Then recover quickly.',
  'ready-position': 'Ready position. This is the stance you return to before every shot. Face the net, with your feet wider than your shoulders. Bend your knees, and keep your weight on the balls of your feet. Hold the racket up in front of you, with your other hand on the throat of the racket. From here, you can turn quickly to either side. Watch him turn into a forehand. And from the same position into a backhand. After every shot, recover to the middle, and get back into your ready position.',
  'grips-diagram': 'How to hold the racket. Picture the bottom of the handle. It has eight flat sides, called bevels. Number them one to eight, starting on top and going clockwise. Continental grip. Put the base knuckle of your index finger on bevel two. It feels like holding a hammer. Use it for serves, volleys, and overheads. Eastern forehand grip. Move the knuckle to bevel three, as if you were shaking hands with the racket. It is a great first forehand grip. Semi-western grip. Knuckle on bevel four. The palm sits more under the handle, which helps you brush up for topspin. For a one-handed backhand, turn the knuckle to bevel one, on top of the handle. For a two-handed backhand, the bottom hand holds a continental grip, and the top hand holds an eastern forehand grip, just above it. Hold the handle firmly at contact, but keep your hand relaxed between shots.',
  'court-diagram': 'Understanding the court. Here is a tennis court, seen from above. The net divides the court in half. The baseline is the back line at each end. Rallies and serves start behind it. A small center mark splits each baseline. Serve from one side of it, then the other. The inner sidelines are the singles lines. The outer strips are the doubles alleys. They count in doubles, and are out in singles. Near the net are the service lines and the center service line. Together they make four service boxes. A ball that touches any part of the line is in.',
  'scoring-diagram': "Scoring. A game starts at love, love. Love means zero. Win a point, and your score is fifteen. Two points is thirty. Three points is forty. Win the next point, and you win the game. If both players reach forty, the score is deuce. Win the next point, and you have the advantage. Win again, and you win the game. Lose it, and the score goes back to deuce. Games add up to a set. The first player to six games wins the set, but you must win by two. At six games all, most sets are decided by a tiebreak: first to seven points, by two. Before each point, the server calls the score, with the server's score first.",
  'rally-practice': 'Rally practice. Stay on the balls of your feet. Prepare early, swing through, and recover to the middle after every shot. Aim for depth and consistency before power.',
  'serve-practice': 'Serve practice. Stand sideways, toss in front of your hitting shoulder, reach up, and follow through. Use the same routine every time.',
  'serve-toss': 'The toss. Lift the ball with a straight arm, and let go at eye level. It should rise just above your reach.',
  'split-step-feet': 'Footwork. Stay light, on the balls of your feet. Hop as your opponent hits, land balanced, then take your first step to the ball.',
  'match-rally': 'Between points, walk back to the baseline, breathe, and plan the next point. Take your time, but keep a steady pace.',
  'serve-aerial': 'From above, watch the toss go up and slightly into the court. That lets you move forward into the ball.',
  'rally-aerial': 'From above, see how both players recover toward the center after each shot. Good position covers the court. Hit deep, and give yourself time.',
  'court-practice': 'A serve from the baseline. Bounce the ball to settle, stand sideways, toss, and swing up. Then get ready for the return.',
  'courts-overhead': 'A tennis court. The baseline is at the back. The service boxes sit in front of the net. Singles uses the inner sidelines, and doubles uses the outer lines.',
  'equipment-bag': 'What to bring. A racket, a can of tennis balls, and a bag to carry them. Wear court shoes, not running shoes, and bring water.',
  'equipment-balls': 'Tennis balls come in a sealed can. Fresh balls bounce better. Put them back in the can after you play, and replace them when they go flat.',
  'equipment-rackets': 'Keep your rackets in a bag, out of the heat. Choose a light racket with a large face when you start. Many players carry a spare in case a string breaks.',
  'etiquette-handshake': 'After the match, meet at the net and shake hands, win or lose. Thank your opponent for the game.',
  'etiquette-collect': 'Between points, collect the balls on your side. Keep spare balls in your pocket, or off the court, so nobody trips on them.',
  'etiquette-return': 'Pick up balls near the net between points. Send them back to the server so they can catch them easily. Never hit a ball at someone.',
  'intro-group-lesson': 'Tennis is easy to start. In a beginner lesson, a coach feeds easy balls and players take turns. Start slowly, keep the ball in play, and have fun.',
  'rally-friends': 'A first rally has one goal: keep the ball going. Aim high over the net, toward the middle of the court, and count how many shots you can share.',
  'serve-behind': 'The serve, seen from behind. Toss the ball up in front of your hitting shoulder, reach up, and hit it diagonally into the service box.',
  'footwork-baseline': 'Footwork at the baseline. Take small steps to adjust before each shot. Keep a wide base, stay low, and move your feet to the ball, not just your arm.',
  'ready-live': 'Watch him drop into the ready position. Feet wide, knees bent, racket up in front, weight forward on the balls of the feet. From here he can move either way.',
  'return-stance': 'Waiting to return a serve. Stay low, with the racket in front and both hands ready. Watch the server\'s toss, and move as soon as you read the ball.',
  'grip-closeup': 'Hand on the handle, up close. The fingers wrap around the grip, and the palm stays relaxed. Bouncing the ball on the strings builds feel for the racket face.',
  'ball-control': 'Ball control on the strings. Keep the racket face flat, and bounce the ball at a steady height. Count how many you can do in a row. It trains your eye and your touch.',
  'serve-trophy': 'The toss and the trophy position. The tossing arm reaches straight up, the racket drops behind the back, and the eyes stay on the ball.',
  'serve-side': 'A full serve from the side. Bounce the ball to settle, then toss, bend the knees, and reach up to hit. The body drives up and into the court.',
  'serve-wide': 'A serve across the court. Stand behind the baseline, toss, and hit up and out, so the ball clears the net and drops into the service box.',
  'serve-routine': 'A pre-serve routine. Bounce the ball a few times, breathe, and picture where you want the serve to go. The same routine every time builds a steady serve.',
  'serve-basket': 'Serve practice with a basket of balls. Take a ball, serve, and repeat. Aim for one target at a time, and count how many land in.',
  'serve-junior': 'A junior player\'s serve. Sideways stance, a smooth toss, and a full reach up to the ball. Keep it relaxed, and let the racket do the work.',
  'forehand-live': 'A forehand with recovery. Turn, swing through, and finish high. Then he steps back to the middle, and gets ready for the next ball.',
  'groundstrokes-close': 'Groundstrokes up close. Watch the early preparation, the racket back before the bounce, and the balanced finish after each shot.',
  'rally-baseline': 'A rally from behind the baseline. Hit through the middle with good height over the net. Recover after each shot, and read the next ball early.',
  'etiquette-net-handshake': 'At the end of a match, walk to the net and shake hands. A friendly word and a thank you are part of the game.',
  'equipment-court': 'A racket, fresh balls, and water on the court. Everything you need for a practice session.',
  'approach-diagram': 'Approach shot. When your opponent hits a short ball, move in to take it. Meet the ball in front, and hit it deep, cross-court or down the line. Keep moving forward through the shot. Do not stop to watch it. Split step just inside the service line, then volley the reply.',
  'passing-diagram': 'Passing shot. Your opponent has come to the net. Choose your target before you swing: cross-court, or down the line. Keep the ball low over the net, so it is hard to volley. Change direction only after they commit. If there is no gap, lift a lob over their head instead.',
  'wall-rally-live': 'Wall rally. Stand back from the wall and hit the ball so it comes back on one bounce. Meet it in front of you, then get ready for the next contact.',
  'warmup-shoulder': 'Shoulder stretch. Pull one arm gently across your chest and hold. Then switch arms. Keep it easy. This loosens the shoulders before you swing.',
  'warmup-arms': 'Open the chest. Lift both arms, press the palms forward, and breathe. A short stretch on court is enough before you start hitting.',
  'ball-over-net': 'Clear the net with height. A rally ball should pass well above the tape, then drop inside the court.',
  'rally-contact': 'Contact. Keep the racket up and meet the ball in front. A short punch is enough when you are close to the net.',
  'grip-on-court': 'The grip. Wrap the fingers around the handle and keep the hand relaxed between shots. Firm only at contact.',
  'serve-bounce': 'Before you serve, bounce the ball and settle. The same routine every time makes the toss steadier.',
  'basket-balls': 'Serve practice. Take one ball from the basket, serve, then take the next. Aim for one target at a time.',
};

LicensedVideo _commons({
  required String id,
  required String title,
  required String pageUrl,
  required String category,
  required int level,
  required String technique,
  required int durationSeconds,
  String adaptation = _commonsAdaptation,
}) {
  return LicensedVideo(
    id: id,
    title: title,
    asset: 'assets/videos/$id.mp4',
    source: 'Wikimedia Commons',
    creator: 'Dardo 86 7',
    license: _commonsLicense,
    licenseUrl: _commonsLicenseUrl,
    pageUrl: pageUrl,
    attribution: _commonsCredit,
    category: category,
    level: level,
    technique: technique,
    durationSeconds: durationSeconds,
    adaptation: adaptation,
    narration: _narration,
  );
}

LicensedVideo _mixkit({
  required String id,
  required String title,
  required String pageUrl,
  required String category,
  required int level,
  required String technique,
  required int durationSeconds,
}) {
  return LicensedVideo(
    id: id,
    title: title,
    asset: 'assets/videos/$id.mp4',
    source: 'Mixkit',
    creator: 'Mixkit',
    license: _mixkitLicense,
    licenseUrl: _mixkitLicenseUrl,
    pageUrl: pageUrl,
    attribution: _mixkitCredit,
    category: category,
    level: level,
    technique: technique,
    durationSeconds: durationSeconds,
    adaptation: _mixkitAdaptation,
    narration: _narration,
  );
}

LicensedVideo _coverr({
  required String id,
  required String title,
  required String pageUrl,
  required String category,
  required int level,
  required String technique,
  required int durationSeconds,
}) {
  return LicensedVideo(
    id: id,
    title: title,
    asset: 'assets/videos/$id.mp4',
    source: 'Coverr',
    creator: 'Coverr',
    license: _coverrLicense,
    licenseUrl: _coverrLicenseUrl,
    pageUrl: pageUrl,
    attribution: 'Coverr · free to use in this app',
    category: category,
    level: level,
    technique: technique,
    durationSeconds: durationSeconds,
    adaptation: _coverrAdaptation,
    narration: _narration,
  );
}

LicensedVideo _pexels({
  required String id,
  required String title,
  required String creator,
  required String pageUrl,
  required String category,
  required int level,
  required String technique,
  required int durationSeconds,
}) {
  return LicensedVideo(
    id: id,
    title: title,
    asset: 'assets/videos/$id.mp4',
    source: 'Pexels',
    creator: creator,
    license: _pexelsLicense,
    licenseUrl: _pexelsLicenseUrl,
    pageUrl: pageUrl,
    attribution: '$creator · Pexels',
    category: category,
    level: level,
    technique: technique,
    durationSeconds: durationSeconds,
    adaptation: _pexelsAdaptation,
    narration: _narration,
  );
}

LicensedVideo _original({
  required String id,
  required String title,
  required String category,
  required int level,
  required String technique,
  required int durationSeconds,
}) {
  return LicensedVideo(
    id: id,
    title: title,
    asset: 'assets/videos/$id.mp4',
    source: 'Baseline',
    creator: 'Baseline',
    license: _originalLicense,
    licenseUrl: '',
    pageUrl: '',
    attribution: 'Baseline original diagram',
    category: category,
    level: level,
    technique: technique,
    durationSeconds: durationSeconds,
    narration: _narration,
  );
}

final licensedVideos = <LicensedVideo>[
  _original(
    id: 'grips-diagram',
    title: 'Grips on the handle',
    category: 'grip',
    level: 1,
    technique: 'grip',
    durationSeconds: 56,
  ),
  _commons(
    id: 'ready-position',
    title: 'The ready position',
    pageUrl: 'https://commons.wikimedia.org/wiki/File:0REVES_2_MANOS.ogv',
    category: 'stance',
    level: 1,
    technique: 'ready-position',
    durationSeconds: 31,
    adaptation: 'Baseline built this clip from two CC BY-SA 3.0 films by Dardo 86 7 (0DRIVE.ogv and 0REVES_2_MANOS.ogv): held frames, slowed playback, and an English voiceover. This version is shared under CC BY-SA 3.0.',
  ),
  _original(
    id: 'court-diagram',
    title: 'Lines of the court',
    category: 'court',
    level: 1,
    technique: 'court',
    durationSeconds: 36,
  ),
  _original(
    id: 'scoring-diagram',
    title: 'How scoring works',
    category: 'rules',
    level: 1,
    technique: 'scoring',
    durationSeconds: 45,
  ),
  _commons(
    id: 'forehand-shadow',
    title: 'Forehand drive',
    pageUrl: 'https://commons.wikimedia.org/wiki/File:0DRIVE.ogv',
    category: 'stroke',
    level: 1,
    technique: 'forehand',
    durationSeconds: 42,
  ),
  _commons(
    id: 'backhand-one-shadow',
    title: 'One-handed backhand',
    pageUrl: 'https://commons.wikimedia.org/wiki/File:0REVES_1_MANO.ogv',
    category: 'stroke',
    level: 1,
    technique: 'backhand',
    durationSeconds: 36,
  ),
  _commons(
    id: 'backhand-two-shadow',
    title: 'Two-handed backhand',
    pageUrl: 'https://commons.wikimedia.org/wiki/File:0REVES_2_MANOS.ogv',
    category: 'stroke',
    level: 1,
    technique: 'backhand',
    durationSeconds: 32,
  ),
  _commons(
    id: 'serve-shadow',
    title: 'Serve',
    pageUrl: 'https://commons.wikimedia.org/wiki/File:0SAQUE.ogv',
    category: 'stroke',
    level: 1,
    technique: 'serve',
    durationSeconds: 43,
  ),
  _commons(
    id: 'volley-shadow',
    title: 'Volley',
    pageUrl: 'https://commons.wikimedia.org/wiki/File:0VOLEA.ogv',
    category: 'stroke',
    level: 2,
    technique: 'volley',
    durationSeconds: 33,
  ),
  _commons(
    id: 'slice-shadow',
    title: 'Slice',
    pageUrl: 'https://commons.wikimedia.org/wiki/File:0SLICE.ogv',
    category: 'stroke',
    level: 2,
    technique: 'slice',
    durationSeconds: 28,
  ),
  _commons(
    id: 'drop-shadow',
    title: 'Drop shot',
    pageUrl: 'https://commons.wikimedia.org/wiki/File:0DROP.ogv',
    category: 'stroke',
    level: 3,
    technique: 'drop',
    durationSeconds: 30,
  ),
  _commons(
    id: 'lob-shadow',
    title: 'Lob',
    pageUrl: 'https://commons.wikimedia.org/wiki/File:0GLOBO.ogv',
    category: 'stroke',
    level: 3,
    technique: 'lob',
    durationSeconds: 32,
  ),
  _commons(
    id: 'smash-shadow',
    title: 'Overhead smash',
    pageUrl: 'https://commons.wikimedia.org/wiki/File:0SMASH.ogv',
    category: 'stroke',
    level: 2,
    technique: 'smash',
    durationSeconds: 38,
  ),
  _coverr(
    id: 'equipment-bag',
    title: 'Racket, balls, and bag',
    pageUrl: 'https://coverr.co/videos/taking-tennis-equipment-out-of-a-bag-dxzo3sdnpf',
    category: 'equipment',
    level: 1,
    technique: 'equipment',
    durationSeconds: 27,
  ),
  _coverr(
    id: 'equipment-balls',
    title: 'A can of tennis balls',
    pageUrl:
        'https://coverr.co/videos/closing-a-tube-of-tennis-balls-knfmftglm8',
    category: 'equipment',
    level: 1,
    technique: 'equipment',
    durationSeconds: 12,
  ),
  _coverr(
    id: 'equipment-rackets',
    title: 'Rackets in the bag',
    pageUrl: 'https://coverr.co/videos/taking-tennis-rackets-out-of-a-bag-cijtwlbsrn',
    category: 'equipment',
    level: 1,
    technique: 'equipment',
    durationSeconds: 21,
  ),
  _pexels(
    id: 'etiquette-handshake',
    title: 'Shake hands at the net',
    creator: 'RDNE Stock project',
    pageUrl: 'https://www.pexels.com/video/girls-sportsmanship-after-a-tennis-match-8224588/',
    category: 'etiquette',
    level: 1,
    technique: 'etiquette',
    durationSeconds: 12,
  ),
  _coverr(
    id: 'etiquette-collect',
    title: 'Collecting balls',
    pageUrl: 'https://coverr.co/videos/man-collecting-tennis-balls-xfghc9m4cc',
    category: 'etiquette',
    level: 1,
    technique: 'etiquette',
    durationSeconds: 22,
  ),
  _coverr(
    id: 'etiquette-return',
    title: 'Returning balls to the server',
    pageUrl: 'https://coverr.co/videos/man-picking-up-a-tennis-ball-edndxxm4a6',
    category: 'etiquette',
    level: 1,
    technique: 'etiquette',
    durationSeconds: 32,
  ),
  _mixkit(
    id: 'match-rally',
    title: 'Between points',
    pageUrl:
        'https://mixkit.co/free-stock-video/tennis-player-during-a-match-876/',
    category: 'etiquette',
    level: 1,
    technique: 'etiquette',
    durationSeconds: 13,
  ),
  _pexels(
    id: 'intro-group-lesson',
    title: 'A beginner group lesson',
    creator: 'Riaj Sohel',
    pageUrl: 'https://www.pexels.com/video/a-group-of-children-practising-tennis-with-their-teachers-11154490/',
    category: 'intro',
    level: 1,
    technique: 'general',
    durationSeconds: 23,
  ),
  _coverr(
    id: 'rally-friends',
    title: 'A friendly rally',
    pageUrl: 'https://coverr.co/videos/woman-playing-tennis-with-a-friend-hg3gjpcguq',
    category: 'rally',
    level: 1,
    technique: 'rally',
    durationSeconds: 13,
  ),
  _mixkit(
    id: 'rally-practice',
    title: 'Rally practice',
    pageUrl: 'https://mixkit.co/free-stock-video/man-playing-tennis-877/',
    category: 'rally',
    level: 1,
    technique: 'rally',
    durationSeconds: 15,
  ),
  _mixkit(
    id: 'rally-aerial',
    title: 'Rally from above',
    pageUrl: 'https://mixkit.co/free-stock-video/two-people-playing-tennis-aerial-view-880/',
    category: 'rally',
    level: 1,
    technique: 'rally',
    durationSeconds: 18,
  ),
  _coverr(
    id: 'serve-behind',
    title: 'Serve from behind',
    pageUrl: 'https://coverr.co/videos/man-serving-during-tennis-frjgfj3smv',
    category: 'serve',
    level: 1,
    technique: 'serve',
    durationSeconds: 10,
  ),
  _mixkit(
    id: 'court-practice',
    title: 'Serve from the baseline',
    pageUrl: 'https://mixkit.co/free-stock-video/tennis-players-at-an-outdoor-court-869/',
    category: 'serve',
    level: 1,
    technique: 'serve',
    durationSeconds: 20,
  ),
  _mixkit(
    id: 'serve-practice',
    title: 'Serve practice',
    pageUrl: 'https://mixkit.co/free-stock-video/man-serving-tennis-ball-878/',
    category: 'serve',
    level: 1,
    technique: 'serve',
    durationSeconds: 12,
  ),
  _mixkit(
    id: 'serve-toss',
    title: 'Serve toss',
    pageUrl: 'https://mixkit.co/free-stock-video/tennis-player-serving-873/',
    category: 'serve',
    level: 1,
    technique: 'serve',
    durationSeconds: 10,
  ),
  _mixkit(
    id: 'serve-aerial',
    title: 'Serve from above',
    pageUrl: 'https://mixkit.co/free-stock-video/tennis-serve-aerial-view-879/',
    category: 'serve',
    level: 2,
    technique: 'serve',
    durationSeconds: 10,
  ),
  _mixkit(
    id: 'split-step-feet',
    title: 'Feet and the first step',
    pageUrl: 'https://mixkit.co/free-stock-video/tennis-players-feet-875/',
    category: 'footwork',
    level: 1,
    technique: 'footwork',
    durationSeconds: 11,
  ),
  _coverr(
    id: 'footwork-baseline',
    title: 'Footwork at the baseline',
    pageUrl: 'https://coverr.co/videos/two-friends-playing-tennis-a3n4yfaz53',
    category: 'footwork',
    level: 1,
    technique: 'footwork',
    durationSeconds: 17,
  ),
  _mixkit(
    id: 'courts-overhead',
    title: 'Courts from above',
    pageUrl: 'https://mixkit.co/free-stock-video/tennis-courts-filmed-from-the-air-5014/',
    category: 'court',
    level: 1,
    technique: 'court',
    durationSeconds: 11,
  ),
  _pexels(
    id: 'ready-live',
    title: 'Dropping into the ready position',
    creator: 'cottonbro studio',
    pageUrl: 'https://www.pexels.com/video/10340762/',
    category: 'stance',
    level: 1,
    technique: 'ready-position',
    durationSeconds: 13,
  ),
  _pexels(
    id: 'return-stance',
    title: 'Waiting to return a serve',
    creator: 'cottonbro studio',
    pageUrl: 'https://www.pexels.com/video/5740601/',
    category: 'stance',
    level: 2,
    technique: 'ready-position',
    durationSeconds: 13,
  ),
  _pexels(
    id: 'grip-closeup',
    title: 'Hand on the handle',
    creator: 'cottonbro studio',
    pageUrl: 'https://www.pexels.com/video/10340714/',
    category: 'grip',
    level: 1,
    technique: 'grip',
    durationSeconds: 13,
  ),
  _pexels(
    id: 'ball-control',
    title: 'Ball control on the strings',
    creator: 'RDNE Stock project',
    pageUrl: 'https://www.pexels.com/video/8224214/',
    category: 'skill',
    level: 1,
    technique: 'ball-control',
    durationSeconds: 13,
  ),
  _pexels(
    id: 'serve-trophy',
    title: 'Toss and trophy position',
    creator: 'cottonbro studio',
    pageUrl: 'https://www.pexels.com/video/10340707/',
    category: 'serve',
    level: 1,
    technique: 'serve',
    durationSeconds: 9,
  ),
  _pexels(
    id: 'serve-side',
    title: 'Full serve from the side',
    creator: 'Antoni Shkraba Studio',
    pageUrl: 'https://www.pexels.com/video/4902146/',
    category: 'serve',
    level: 1,
    technique: 'serve',
    durationSeconds: 15,
  ),
  _pexels(
    id: 'serve-wide',
    title: 'Serve across the court',
    creator: 'Antoni Shkraba Studio',
    pageUrl: 'https://www.pexels.com/video/4902165/',
    category: 'serve',
    level: 2,
    technique: 'serve',
    durationSeconds: 10,
  ),
  _pexels(
    id: 'serve-routine',
    title: 'Pre-serve routine',
    creator: 'Antoni Shkraba Studio',
    pageUrl: 'https://www.pexels.com/video/4902149/',
    category: 'serve',
    level: 1,
    technique: 'serve',
    durationSeconds: 10,
  ),
  _pexels(
    id: 'serve-basket',
    title: 'Serve practice with a basket',
    creator: 'Antoni Shkraba Studio',
    pageUrl: 'https://www.pexels.com/video/4902139/',
    category: 'serve',
    level: 2,
    technique: 'serve',
    durationSeconds: 12,
  ),
  _pexels(
    id: 'serve-junior',
    title: "A junior player's serve",
    creator: 'RDNE Stock project',
    pageUrl: 'https://www.pexels.com/video/8224291/',
    category: 'serve',
    level: 1,
    technique: 'serve',
    durationSeconds: 15,
  ),
  _pexels(
    id: 'forehand-live',
    title: 'Forehand and recovery',
    creator: 'cottonbro studio',
    pageUrl: 'https://www.pexels.com/video/5740603/',
    category: 'stroke',
    level: 1,
    technique: 'forehand',
    durationSeconds: 15,
  ),
  _pexels(
    id: 'groundstrokes-close',
    title: 'Groundstrokes up close',
    creator: 'cottonbro studio',
    pageUrl: 'https://www.pexels.com/video/5740602/',
    category: 'stroke',
    level: 2,
    technique: 'groundstroke',
    durationSeconds: 32,
  ),
  _pexels(
    id: 'rally-baseline',
    title: 'Rally from behind the baseline',
    creator: 'cottonbro studio',
    pageUrl: 'https://www.pexels.com/video/5740596/',
    category: 'rally',
    level: 2,
    technique: 'rally',
    durationSeconds: 9,
  ),
  _pexels(
    id: 'etiquette-net-handshake',
    title: 'Handshake after the match',
    creator: 'cottonbro studio',
    pageUrl: 'https://www.pexels.com/video/5740593/',
    category: 'etiquette',
    level: 1,
    technique: 'etiquette',
    durationSeconds: 11,
  ),
  _pexels(
    id: 'equipment-court',
    title: 'Ready for practice',
    creator: 'melbourne ross',
    pageUrl: 'https://www.pexels.com/video/38592216/',
    category: 'equipment',
    level: 1,
    technique: 'equipment',
    durationSeconds: 7,
  ),
  _original(
    id: 'approach-diagram',
    title: 'Approach shot pattern',
    category: 'tactics',
    level: 3,
    technique: 'approach',
    durationSeconds: 19,
  ),
  _original(
    id: 'passing-diagram',
    title: 'Passing shot choices',
    category: 'tactics',
    level: 3,
    technique: 'passing-shot',
    durationSeconds: 19,
  ),
  _mixkit(
    id: 'wall-rally-live',
    title: 'Wall rally',
    pageUrl: 'https://mixkit.co/free-stock-video/tennis-player-bouncing-the-ball-on-the-wall-13999/',
    category: 'drill',
    level: 1,
    technique: 'rally',
    durationSeconds: 13,
  ),
  _pexels(
    id: 'warmup-shoulder',
    title: 'Shoulder stretch on court',
    creator: 'Antoni Shkraba Studio',
    pageUrl: 'https://www.pexels.com/video/a-man-warming-up-for-a-tennis-practice-4902162/',
    category: 'drill',
    level: 1,
    technique: 'footwork',
    durationSeconds: 10,
  ),
  _pexels(
    id: 'warmup-arms',
    title: 'Arm stretch on court',
    creator: 'AI25.Studio',
    pageUrl: 'https://www.pexels.com/video/a-tennis-player-stretching-4902770/',
    category: 'drill',
    level: 1,
    technique: 'footwork',
    durationSeconds: 11,
  ),
  _mixkit(
    id: 'rally-contact',
    title: 'Contact at the net',
    pageUrl: 'https://mixkit.co/free-stock-video/tennis-player-hitting-the-ball-during-a-game-47278/',
    category: 'stroke',
    level: 2,
    technique: 'volley',
    durationSeconds: 19,
  ),
  _mixkit(
    id: 'grip-on-court',
    title: 'Grip on the court',
    pageUrl: 'https://mixkit.co/free-stock-video/tennis-player-hitting-the-ball-47279/',
    category: 'grip',
    level: 1,
    technique: 'grip',
    durationSeconds: 26,
  ),
  _mixkit(
    id: 'serve-bounce',
    title: 'Bounce before the serve',
    pageUrl: 'https://mixkit.co/free-stock-video/tennis-player-bounces-tennis-ball-before-serving-45496/',
    category: 'serve',
    level: 1,
    technique: 'serve',
    durationSeconds: 18,
  ),
  _mixkit(
    id: 'basket-balls',
    title: 'Balls from the basket',
    pageUrl: 'https://mixkit.co/free-stock-video/a-man-takes-a-tennis-ball-out-of-the-basket-23946/',
    category: 'drill',
    level: 1,
    technique: 'serve',
    durationSeconds: 11,
  ),
  _mixkit(
    id: 'ball-over-net',
    title: 'Ball over the net',
    pageUrl: 'https://mixkit.co/free-stock-video/tennis-ball-flying-over-the-net-23639/',
    category: 'rally',
    level: 1,
    technique: 'rally',
    durationSeconds: 9,
  ),
];

const lessonVideoIds = <String, List<String>>{
  'welcome-to-tennis': ['intro-group-lesson', 'rally-friends'],
  'the-court': ['court-diagram', 'courts-overhead'],
  'scoring': ['scoring-diagram', 'match-rally'],
  'ready-position': [
    'ready-live',
    'return-stance',
    'split-step-feet',
  ],
  'basic-forehand': ['forehand-shadow', 'forehand-live', 'rally-practice'],
  'basic-rally': [
    'ball-over-net',
    'rally-friends',
    'rally-baseline',
    'rally-aerial',
    'rally-practice',
  ],
  'rally-construction': ['rally-baseline', 'rally-aerial'],
  'equipment': [
    'equipment-bag',
    'equipment-balls',
    'equipment-rackets',
    'equipment-court',
  ],
  'grips': ['grip-on-court', 'grips-diagram', 'grip-closeup', 'ball-control'],
  'basic-backhand': [
    'backhand-two-shadow',
    'backhand-one-shadow',
    'groundstrokes-close',
  ],
  'basic-serve': [
    'serve-bounce',
    'serve-shadow',
    'serve-side',
    'serve-trophy',
    'serve-toss',
    'serve-routine',
    'serve-junior',
    'serve-behind',
  ],
  'basic-volley': ['rally-contact', 'volley-shadow'],
  'etiquette': [
    'etiquette-return',
    'etiquette-collect',
    'etiquette-handshake',
    'etiquette-net-handshake',
    'match-rally',
  ],
  'forehand-fundamentals': [
    'forehand-live',
    'forehand-shadow',
    'groundstrokes-close',
  ],
  'footwork': ['split-step-feet', 'footwork-baseline', 'ready-live'],
  'serve-placement': [
    'basket-balls',
    'serve-bounce',
    'serve-wide',
    'serve-aerial',
    'court-practice',
    'serve-basket',
  ],
  'contact-point': ['rally-contact', 'forehand-shadow', 'forehand-live', 'groundstrokes-close'],
  'slice': ['slice-shadow'],
  'topspin': ['forehand-shadow', 'forehand-live'],
  'one-handed-backhand': ['backhand-one-shadow'],
  'return-of-serve': ['return-stance', 'ready-live', 'split-step-feet'],
  'overhead': ['smash-shadow'],
  'court-recovery': ['forehand-live', 'rally-aerial', 'footwork-baseline'],
  'lob': ['lob-shadow', 'passing-diagram'],
  'drop-shot': ['drop-shadow'],
  'approach-shot': ['approach-diagram'],
  'passing-shot': ['passing-diagram'],
  'second-serve': ['serve-bounce', 'serve-shadow', 'serve-trophy', 'serve-routine'],
};

const drillVideoIds = <String, List<String>>{
  'wall-rally': ['wall-rally-live'],
  'warmup': ['warmup-shoulder', 'warmup-arms', 'split-step-feet', 'footwork-baseline'],
  'forehand-consistency': [
    'rally-contact',
    'forehand-live',
    'forehand-shadow',
    'rally-practice',
  ],
  'split-step': ['ready-live', 'split-step-feet', 'footwork-baseline'],
  'serve-target': ['basket-balls', 'serve-bounce', 'serve-basket', 'serve-wide', 'serve-shadow', 'serve-toss'],
  'backhand-consistency': [
    'backhand-two-shadow',
    'backhand-one-shadow',
    'groundstrokes-close',
  ],
  'figure-8': ['rally-baseline', 'rally-aerial', 'footwork-baseline'],
};

LicensedVideo? videoById(String id) {
  for (final video in licensedVideos) {
    if (video.id == id) return video;
  }
  return null;
}

List<LicensedVideo> videosForLesson(String slug) {
  return _resolve(lessonVideoIds[slug]);
}

List<LicensedVideo> videosForDrill(String slug) {
  return _resolve(drillVideoIds[slug]);
}

List<LicensedVideo> videosForDrills(List<String> slugs) {
  final seen = <String>{};
  final videos = <LicensedVideo>[];
  for (final slug in slugs) {
    for (final video in videosForDrill(slug)) {
      if (seen.add(video.id)) videos.add(video);
    }
  }
  return videos;
}

List<LicensedVideo> _resolve(List<String>? ids) {
  if (ids == null) return const [];
  return [
    for (final id in ids)
      if (videoById(id) != null) videoById(id)!,
  ];
}
