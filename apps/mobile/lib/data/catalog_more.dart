import 'package:baseline/data/catalog.dart';

/// Extra original lessons and drills for the version 1 course.
const moreLessons = <Lesson>[
  Lesson(
    slug: 'equipment',
    level: 1,
    title: 'Tennis equipment',
    category: 'etiquette',
    freeTier: true,
    estimatedMinutes: 8,
    summary: 'What to bring the first time you go to a court.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A beginner needs a racket that is not too heavy, a can of tennis balls, and court shoes. Running shoes slip on a hard court. A shop can check the grip size if the handle feels painful or numb.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Choose a light racket with a large face. 2. Buy a fresh can of balls. 3. Wear shoes meant for tennis. 4. Bring water.',
      ),
    ],
  ),
  Lesson(
    slug: 'grips',
    level: 1,
    title: 'How to hold the racket',
    category: 'technique',
    technique: 'grip',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Continental, eastern, and semi-western in plain language.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'The grip is how the hand sits on the handle. Continental feels like holding a hammer and is used for volleys and serves. An eastern forehand is the handshake grip: the hand turns a little so the palm is more behind the handle. Semi-western turns further and is a common forehand grip once contact is steady.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Squeezing the handle the whole time. A firm contact and a relaxed hand between shots is enough.',
      ),
    ],
  ),
  Lesson(
    slug: 'basic-backhand',
    level: 1,
    title: 'Basic backhand',
    category: 'technique',
    technique: 'backhand',
    freeTier: true,
    estimatedMinutes: 12,
    summary: 'A compact two-handed backhand for the first rallies.',
    blocks: [
      LessonBlock(
        kind: 'steps',
        body: 'Both hands on the handle, dominant hand at the bottom. Turn your shoulders. Meet the ball in front of the front hip. Finish forward and up, then recover to the middle.',
      ),
      LessonBlock(
        kind: 'beginner_mistakes',
        body: 'Dropping the racket head so the ball clips the frame. Prepare before the bounce.',
      ),
    ],
  ),
  Lesson(
    slug: 'basic-serve',
    level: 1,
    title: 'Basic serve introduction',
    category: 'technique',
    technique: 'serve',
    freeTier: true,
    estimatedMinutes: 12,
    summary: 'Toss, contact, and a serve that starts in the box.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'The serve starts the point. Place the toss in front of the hitting shoulder, reach up, and brush the ball into the service box. Catch a bad toss instead of swinging at it.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Stand sideways behind the baseline. 2. Toss with a straight arm. 3. Hit up and through. 4. Land inside the court, then recover.',
      ),
    ],
  ),
  Lesson(
    slug: 'basic-volley',
    level: 1,
    title: 'Basic volley',
    category: 'technique',
    technique: 'volley',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'A short punch in front of the body, before the bounce.',
    blocks: [
      LessonBlock(
        kind: 'steps',
        body: 'Continental grip. Racket head above the wrist. Step toward the ball. Contact in front. A short punch, not a full swing.',
      ),
    ],
  ),
  Lesson(
    slug: 'etiquette',
    level: 1,
    title: 'Basic tennis etiquette',
    category: 'etiquette',
    freeTier: true,
    estimatedMinutes: 6,
    summary: 'How to share a court and keep practice friendly.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'Call your own lines honestly. Return balls to the server, not at them. Wait until a point ends before walking behind a court. Say the score before you serve if you are playing points.',
      ),
    ],
  ),
  Lesson(
    slug: 'forehand-fundamentals',
    level: 2,
    title: 'Forehand fundamentals',
    category: 'technique',
    technique: 'forehand',
    freeTier: true,
    estimatedMinutes: 12,
    summary: 'Spacing, contact, and a finish you can repeat.',
    blocks: [
      LessonBlock(
        kind: 'why',
        body: 'A reliable forehand is the shot you use to stay in the rally. Height over the net matters more than pace.',
      ),
      LessonBlock(
        kind: 'steps',
        body: 'Set your feet so you are not jammed. Turn early. Contact in front of the front hip. Finish over the opposite shoulder and return to the middle.',
      ),
    ],
  ),
  Lesson(
    slug: 'footwork',
    level: 2,
    title: 'Footwork',
    category: 'technique',
    technique: 'footwork',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Split step, side shuffle, and getting back to the middle.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'The split step is a small hop as the other player hits. Land balanced, then move. After your shot, recover toward the middle so the next ball is not a sprint.',
      ),
    ],
  ),
  Lesson(
    slug: 'serve-placement',
    level: 3,
    title: 'Serve placement',
    category: 'technique',
    technique: 'serve',
    freeTier: false,
    estimatedMinutes: 12,
    summary: 'Aim for a target in the service box before you add pace.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A placed second serve that lands in is more useful than a fast serve that misses. Pick one target, toss in front, and hold the finish.',
      ),
    ],
  ),
  Lesson(
    slug: 'contact-point',
    level: 2,
    title: 'Contact point',
    category: 'technique',
    technique: 'contact-point',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Meet the ball in front of the body, with the strings facing the target.',
    blocks: [
      LessonBlock(
        kind: 'why',
        body: 'A ball into the net is often a late or low contact, not a lack of effort. Meeting the ball in front gives the racket a path that lifts it over the net.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Prepare before the bounce. 2. Meet the ball in front of the front hip, around waist height on a rally ball. 3. Keep the strings facing the target through contact. 4. Finish up, then recover.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Letting the ball come beside the hip, or stopping the swing at the waist so the path points down.',
      ),
    ],
  ),
  Lesson(
    slug: 'slice',
    level: 2,
    title: 'Slice',
    category: 'technique',
    technique: 'slice',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'A high-to-low swing that keeps the ball low after the bounce.',
    blocks: [
      LessonBlock(
        kind: 'steps',
        body: '1. Take the racket back a little higher than a flat swing, face slightly open. 2. Swing under the ball and meet it in front. 3. Keep the wrist quiet. 4. Finish out toward the target so the bounce stays low.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Chopping straight down into the net. Aim higher and let the open face do the work.',
      ),
    ],
  ),
  Lesson(
    slug: 'topspin',
    level: 2,
    title: 'Topspin',
    category: 'technique',
    technique: 'topspin',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'A low-to-high brush that helps the ball dip inside the lines.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'Topspin is forward spin. The ball climbs, then drops, so you can swing up and still land in the court.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Start the racket head below the ball. 2. Swing up through contact and brush the back of the ball. 3. Finish over the opposite shoulder. 4. Add height first, then a little more brush.',
      ),
    ],
  ),
  Lesson(
    slug: 'one-handed-backhand',
    level: 2,
    title: 'One-handed backhand',
    category: 'technique',
    technique: 'one-handed-backhand',
    freeTier: true,
    estimatedMinutes: 12,
    summary: 'A longer backhand with the front shoulder leading the turn.',
    blocks: [
      LessonBlock(
        kind: 'steps',
        body: '1. Use a continental or eastern backhand grip. 2. Turn the front shoulder and keep the free hand on the throat until the racket starts forward. 3. Contact in front with the arm extended. 4. Finish out and up.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Letting the elbow collapse so the face opens and the ball sails long.',
      ),
    ],
  ),
  Lesson(
    slug: 'return-of-serve',
    level: 2,
    title: 'Return of serve',
    category: 'technique',
    technique: 'return',
    freeTier: true,
    estimatedMinutes: 10,
    summary:
        'A short swing that gets the return in when the serve comes at you.',
    blocks: [
      LessonBlock(
        kind: 'steps',
        body: '1. Split step as the server tosses. 2. Shorten the backswing. 3. Aim cross-court, over the lowest part of the net. 4. Recover to the middle before you look for a winner.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'A first serve is a block. A second serve can be a fuller swing once the ball is in front of you.',
      ),
    ],
  ),
  Lesson(
    slug: 'overhead',
    level: 2,
    title: 'Overhead smash',
    category: 'technique',
    technique: 'smash',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'A short serve motion on a high ball, hit in front of you.',
    blocks: [
      LessonBlock(
        kind: 'steps',
        body: '1. Turn sideways as soon as you see a high ball. 2. Track it with the free hand and move back with small steps. 3. Hit at the highest point you can reach, in front of the body. 4. Finish across the body and recover.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Waiting until the ball drops to shoulder height, then swinging up at it.',
      ),
    ],
  ),
  Lesson(
    slug: 'court-recovery',
    level: 2,
    title: 'Court recovery',
    category: 'technique',
    technique: 'recovery',
    freeTier: true,
    estimatedMinutes: 8,
    summary: 'The steps that bring you back toward the middle after a shot.',
    blocks: [
      LessonBlock(
        kind: 'why',
        body: 'The next ball is easier when you are not still standing where you hit the last one.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. After contact, push back toward a spot just on the side you hit from. 2. Stay low for the first two steps. 3. Split step as the other player swings.',
      ),
    ],
  ),
  Lesson(
    slug: 'lob',
    level: 3,
    title: 'Lob',
    category: 'technique',
    technique: 'lob',
    freeTier: true,
    estimatedMinutes: 8,
    summary: 'A high ball that buys time or clears a player at the net.',
    blocks: [
      LessonBlock(
        kind: 'steps',
        body: '1. Prepare early and get under the ball. 2. Open the face and lift low to high. 3. Aim above the other player and deep toward the baseline. 4. Finish with the racket high, then recover for a smash.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Sending a flat ball that sits up at the net player.',
      ),
    ],
  ),
  Lesson(
    slug: 'drop-shot',
    level: 3,
    title: 'Drop shot',
    category: 'technique',
    technique: 'drop',
    freeTier: true,
    estimatedMinutes: 8,
    summary: 'A soft slice that dies just over the net when the other player is deep.',
    blocks: [
      LessonBlock(
        kind: 'steps',
        body: '1. Prepare like a normal groundstroke so the shot stays hidden. 2. Soften the hands and open the face. 3. Slice gently under the ball. 4. Land it just over the net with very little forward speed.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Save it for a ball you can reach comfortably, and only when the other player is behind the baseline.',
      ),
    ],
  ),
  Lesson(
    slug: 'approach-shot',
    level: 3,
    title: 'Approach shot',
    category: 'technique',
    technique: 'approach',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'The shot you hit while moving in, so you can take the net.',
    blocks: [
      LessonBlock(
        kind: 'steps',
        body: '1. Move in on a short ball. 2. Contact in front and aim deep, cross-court or down the line. 3. Keep moving through the shot. 4. Split step inside the service line before the reply.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Stopping to watch the shot and arriving late at the net.',
      ),
    ],
  ),
  Lesson(
    slug: 'passing-shot',
    level: 3,
    title: 'Passing shot',
    category: 'technique',
    technique: 'passing-shot',
    freeTier: true,
    estimatedMinutes: 8,
    summary: 'A low ball past a player who has come to the net.',
    blocks: [
      LessonBlock(
        kind: 'steps',
        body: '1. Choose cross-court or down the line before you swing. 2. Keep the ball low. 3. Contact in front. 4. Change direction only after you see them commit to one side.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Lifting the ball so it is easy to volley.',
      ),
    ],
  ),
  Lesson(
    slug: 'second-serve',
    level: 3,
    title: 'Second serve',
    category: 'technique',
    technique: 'second-serve',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'A slower serve with shape that still lands in the box.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'The second serve uses the same toss as the first, a little more in front. Brush up the back of the ball so it dips into a big target. A double fault loses the point, so the goal is a serve that starts the rally.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Keep the motion the same as the first serve. 2. Toss slightly in front. 3. Brush up the ball and aim for a large target in the box. 4. Catch a bad toss instead of pushing it in.',
      ),
    ],
  ),
];

const moreDrills = <Drill>[
  Drill(
    slug: 'backhand-consistency',
    name: 'Backhand consistency',
    levelMin: 1,
    objective: 'Keep a two-handed backhand in play for ten contacts.',
    equipment: ['racket', 'balls', 'wall'],
    playersRequired: 1,
    durationMinutes: 12,
    repetitions: '10 in a row, 3 times',
    difficulty: 2,
    freeTier: true,
    instructions: 'Stand a comfortable distance from a wall. Hit only backhands. Count a contact that comes back on one bounce. Reset the count after two misses.',
    coachingTips: 'Turn the shoulders before the ball bounces.',
    commonMistakes: 'Reaching with the arms while the feet stay still.',
  ),
  Drill(
    slug: 'figure-8',
    name: 'Figure-8 drill',
    levelMin: 2,
    objective: 'Practice recovery steps between two spots.',
    equipment: ['two cones or towels'],
    playersRequired: 1,
    durationMinutes: 8,
    repetitions: '4 sets of 30 seconds',
    difficulty: 2,
    freeTier: true,
    instructions: 'Place two markers about four steps apart. Shuffle to one, split step, shuffle to the other, and trace a figure-8. Stay low.',
    coachingTips:
        'The split step happens at each marker, not in the middle of the run.',
    commonMistakes: 'Crossing the feet so you trip when you change direction.',
  ),
];
