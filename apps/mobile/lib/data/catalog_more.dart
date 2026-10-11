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
  Lesson(
    slug: 'serve-plus-one',
    level: 4,
    title: 'Serve plus one',
    category: 'strategy',
    technique: 'serve-plus-one',
    freeTier: false,
    estimatedMinutes: 14,
    summary: 'Pair a purposeful serve with the first ball you expect to hit.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'Serve plus one is a two-shot plan: use the serve to create a manageable reply, then attack the first ball you receive. The goal is a repeatable pattern, not a winner on every point.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Choose a serve target that moves or jams the returner. 2. Recover to a balanced position after landing. 3. Read the return and move early to your planned side. 4. Play the first ball deep to open space, then recover.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Serving hard without a next-shot position, or trying to finish the point before the return gives you an opening.',
      ),
    ],
  ),
  Lesson(
    slug: 'inside-out-forehand',
    level: 3,
    title: 'Inside-out forehand',
    category: 'technique',
    technique: 'inside-out-forehand',
    freeTier: true,
    estimatedMinutes: 12,
    summary:
        'Run around the backhand corner to attack with a forehand cross-court.',
    blocks: [
      LessonBlock(
        kind: 'why',
        body: 'An inside-out forehand lets you use a comfortable forehand while sending the ball diagonally to the opponent\'s backhand. It is useful when you have time to move around the ball.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Recognize a ball that gives you time to move left or right. 2. Use small adjustment steps to get your body beside the ball. 3. Contact in front and send the ball cross-court with height. 4. Recover toward the middle before the reply.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Running around a ball that is too fast, or drifting so far out of position that the open court is unprotected.',
      ),
    ],
  ),
  Lesson(
    slug: 'crossover-step',
    level: 3,
    title: 'Crossover step',
    category: 'technique',
    technique: 'crossover-step',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Cover more court with a confident crossover before you set up the swing.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A crossover step is a traveling step for a larger move. One foot crosses over the other so you can cover ground quickly, then smaller steps put you in hitting position.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Push off the outside foot toward the ball. 2. Cross the moving foot over the other without turning your chest away from the court. 3. Use quick adjustment steps to find spacing. 4. Plant, swing, and recover with a split step.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Use a crossover for distance, not for every adjustment. Keep the racket prepared while the feet do the traveling.',
      ),
    ],
  ),
  Lesson(
    slug: 'kick-serve',
    level: 4,
    title: 'Kick serve',
    category: 'technique',
    technique: 'kick-serve',
    freeTier: false,
    estimatedMinutes: 14,
    summary:
        'Brush up the ball to create a high-bouncing serve with a safe margin.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A kick serve uses upward brushing and spin to make the ball clear the net with room, then jump up after the bounce. It is a useful second-serve shape when you can repeat the toss and finish.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Use a consistent toss slightly above and in front of your hitting side. 2. Reach up and brush from low to high behind the ball. 3. Aim high over the net toward a large service-box target. 4. Land balanced and get ready for the return.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Tossing behind the head, forcing sideways action with the wrist, or chasing extra speed before the ball has reliable shape.',
      ),
    ],
  ),
  Lesson(
    slug: 'angle-shot',
    level: 3,
    title: 'Angle shot',
    category: 'strategy',
    technique: 'angle-shot',
    freeTier: true,
    estimatedMinutes: 10,
    summary:
        'Use a shorter cross-court path to pull your opponent off the court.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'An angle shot travels cross-court and lands closer to the sideline than a neutral rally ball. The shorter path can open the court, but it leaves less room for error.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Wait for a ball you can reach comfortably. 2. Prepare early and keep the contact in front. 3. Use a compact swing with enough net clearance. 4. Recover for the next ball instead of admiring the angle.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Choose the angle when your opponent is deep or out of position. A safer cross-court ball is better when you are stretched or late.',
      ),
    ],
  ),
  Lesson(
    slug: 'neutral-ball',
    level: 3,
    title: 'Neutral ball',
    category: 'strategy',
    technique: 'neutral-ball',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Recognize the middle of a point and choose a reliable ball over a risky attack.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A neutral ball is neither an obvious attack nor a desperate defense. It keeps you balanced, clears the net safely, and asks the opponent to create the next opening.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Check whether the ball is comfortable but not short. 2. Aim cross-court with height and a dependable margin. 3. Recover to your ready position after contact. 4. Attack only when the next ball gives you time and space.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Treating every comfortable ball as a winner, or playing so defensively that the opponent gets an easy short ball.',
      ),
    ],
  ),
  Lesson(
    slug: 'flat-serve',
    level: 2,
    title: 'Flat serve',
    category: 'technique',
    technique: 'flat-serve',
    freeTier: true,
    estimatedMinutes: 12,
    summary:
        'Drive a first serve through the box with a high, repeatable contact.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A flat serve uses a mostly direct path through the ball for pace and a predictable bounce. Reliable direction and a repeatable toss matter more than trying to hit at maximum speed.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Start sideways with a continental grip. 2. Toss slightly in front of your hitting shoulder. 3. Reach up to contact at your highest comfortable point. 4. Land balanced inside the court and recover for the return.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Use a large target first, then narrow it toward the body or corner after the motion feels repeatable. Keep the tossing arm up while you drive to contact.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Chasing speed with a drifting toss, falling away from the ball, or aiming too close to the line before the serve is dependable.',
      ),
    ],
  ),
  Lesson(
    slug: 'slice-serve',
    level: 3,
    title: 'Slice serve',
    category: 'technique',
    technique: 'slice-serve',
    freeTier: true,
    estimatedMinutes: 12,
    summary: 'Curve the serve away from the returner with controlled sidespin.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A slice serve combines pace with sidespin so the ball bends in flight and moves after the bounce. It is especially useful when a wide target can pull the returner off the court.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Keep the starting stance and toss consistent. 2. Toss a little toward the hitting side. 3. Brush around the outside of the ball while reaching up. 4. Land balanced and recover toward the middle.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Shape the serve with the swing path rather than a sudden wrist turn. Practice the wide target on both sides before adding more pace.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Tossing too far to the side, cutting down on the ball, or over-rotating so the serve loses its direction.',
      ),
    ],
  ),
  Lesson(
    slug: 'return-positioning',
    level: 2,
    title: 'Return positioning',
    category: 'technique',
    technique: 'return-positioning',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Choose a return spot that gives you time to read the serve and move forward.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'Your return position should match the server and your ability to handle pace. Start far enough back to see the ball, but be ready to step forward and take a shorter serve early.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Begin in a balanced stance with the racket in front. 2. Stand a little farther back for a fast serve or closer for a slower one. 3. Split step as the server contacts the ball. 4. Recover toward the middle after the return.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Use the baseline, your usual contact point, and the server’s toss as references. Adjust by small steps instead of making a large move during the serve motion.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Standing rigidly in one spot, drifting backward on every serve, or beginning the swing before you have read the direction.',
      ),
    ],
  ),
  Lesson(
    slug: 'backhand-slice',
    level: 2,
    title: 'Backhand slice',
    category: 'technique',
    technique: 'backhand-slice',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Use a firm, gliding backhand slice to keep the ball low and controlled.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'The backhand slice is a useful change of pace and a reliable answer to a low or awkward ball. A stable racket face and forward finish help the ball travel through the court instead of floating.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Turn the shoulders early and take the racket back slightly high. 2. Set the front shoulder toward the target. 3. Swing from high to low and brush under the ball in front. 4. Finish forward and recover to the ready position.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Keep the grip steady and let the arm length create the slice. Aim cross-court first, where the longer diagonal gives you more room.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Chopping straight down, opening the racket face too much, or contacting beside the body after the ball has passed you.',
      ),
    ],
  ),
  Lesson(
    slug: 'forehand-down-the-line',
    level: 3,
    title: 'Forehand down the line',
    category: 'technique',
    technique: 'forehand-down-the-line',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Change direction with a forehand that travels cleanly down the sideline.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A down-the-line forehand changes the direction of a rally and can expose open court. It needs early preparation, comfortable spacing, and enough margin because the target is narrower than cross-court.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Wait for a ball that gives you time to set up. 2. Move beside the ball with small adjustment steps. 3. Contact in front and send the racket path toward the sideline. 4. Recover through the middle immediately after the swing.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Aim a little inside the sideline and clear the net with dependable height. Use the shot when you are balanced, not simply because you have hit several cross-court balls.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Changing direction while stretched, contacting late, or admiring the line and leaving the opposite side open.',
      ),
    ],
  ),
  Lesson(
    slug: 'cross-court-forehand',
    level: 2,
    title: 'Cross-court forehand',
    category: 'technique',
    technique: 'cross-court-forehand',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Build a safer forehand rally with height, depth, and the long diagonal.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'The cross-court forehand follows the longer diagonal and passes over the lower middle of the net. That combination gives a developing player more space while keeping the rally moving.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Prepare the racket before the bounce. 2. Set your feet so contact stays in front. 3. Swing low to high with safe net clearance. 4. Send the ball deep cross-court and recover toward the middle.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Picture a target inside the far sideline rather than the line itself. Add depth by finishing through the ball, not by swinging harder.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Aiming too close to the sideline, lifting without depth, or staying wide after contact and giving away the open court.',
      ),
    ],
  ),
  Lesson(
    slug: 'swing-volley',
    level: 3,
    title: 'Swing volley',
    category: 'technique',
    technique: 'swing-volley',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Take a short ball early with a compact forehand swing on the way to the net.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A swing volley is an attacking groundstroke taken before the ball drops to a comfortable baseline height. It lets you keep moving forward while using a controlled swing to handle a short ball.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Recognize the short ball and move forward behind it. 2. Prepare early with the racket up. 3. Contact in front using a compact low-to-high swing. 4. Continue toward the net and split step before the reply.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Choose a target with margin and let your forward movement add pressure. Keep the swing shorter than a baseline forehand so you arrive ready for the next ball.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Waiting for the ball to drop, taking a full backswing while moving, or stopping after contact instead of closing the net.',
      ),
    ],
  ),
  Lesson(
    slug: 'drop-volley',
    level: 3,
    title: 'Drop volley',
    category: 'technique',
    technique: 'drop-volley',
    freeTier: true,
    estimatedMinutes: 10,
    summary:
        'Absorb the incoming pace and leave a soft volley just over the net.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A drop volley uses touch rather than a long swing. The racket face cushions the incoming ball so it lands short and forces the opponent to cover forward quickly.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Move your racket behind the ball early. 2. Keep a continental grip and a slightly open face. 3. Soften the hands to absorb pace on contact. 4. Angle the ball just over the net and recover for the next shot.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Use the drop volley when the opponent is deep and the incoming ball has manageable pace. Keep the racket head stable while the body moves through the volley.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Swinging at the ball, trying the shot from too far behind the net, or leaving the face so open that the ball sits up.',
      ),
    ],
  ),
  Lesson(
    slug: 'serve-and-volley',
    level: 4,
    title: 'Serve and volley',
    category: 'strategy',
    technique: 'serve-and-volley',
    freeTier: false,
    estimatedMinutes: 14,
    summary:
        'Turn a purposeful serve into forward pressure and a first volley.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'Serve and volley connects the serve, the approach, and the first volley into one plan. The serve should make the return predictable enough for you to move forward with balance and time.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Choose a serve target that limits the return angles. 2. Move forward behind the serve with the racket up. 3. Split step as the returner contacts the ball. 4. Volley into space, then recover for the next shot.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Practice the first volley as a deep, simple ball before trying sharp angles. Keep your steps active so the return does not catch you flat-footed.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Rushing forward without reading the return, dropping the racket below the hands, or trying to finish the first volley from a poor position.',
      ),
    ],
  ),
  Lesson(
    slug: 'doubles-formation',
    level: 3,
    title: 'Doubles formation',
    category: 'strategy',
    technique: 'doubles-formation',
    freeTier: true,
    estimatedMinutes: 12,
    summary: 'Use spacing and shared court coverage to make a doubles team harder to pass.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A doubles formation gives each partner a starting responsibility and keeps the middle protected. Good teams move as a pair, close gaps, and adjust when the ball changes direction.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Set the server behind the baseline and the partner in a ready net position. 2. Cover the middle before chasing the sideline. 3. Shift together as the ball travels. 4. Reset your spacing after every point.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Agree on who owns the middle and the first lob before serving. Keep the racket up and communicate after the point, not during a rushed swing.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Standing in parallel without a plan, leaving a lane between partners, or one player moving while the other stays fixed.',
      ),
    ],
  ),
  Lesson(
    slug: 'poaching',
    level: 3,
    title: 'Poaching',
    category: 'strategy',
    technique: 'poaching',
    freeTier: true,
    estimatedMinutes: 10,
    summary: 'Cross in front of your partner to intercept a predictable doubles return.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'Poaching is a planned net-player move across the middle to take the ball before it reaches your partner. It works best when the serve or partner’s shot makes the reply predictable.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Start in a ready net position with a clear signal. 2. Watch the opponent’s racket and read the likely return. 3. Close across the middle when the ball is committed. 4. Volley simply and recover with your partner.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Leave only when your partner knows the plan. A small first step is enough to test the return; commit when you can reach the ball in front.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Crossing too early, watching only the ball, or moving so far that the down-the-line lane becomes an easy target.',
      ),
    ],
  ),
  Lesson(
    slug: 'tiebreak-strategy',
    level: 3,
    title: 'Tiebreak strategy',
    category: 'strategy',
    technique: 'tiebreak-strategy',
    freeTier: true,
    estimatedMinutes: 12,
    summary:
        'Play a tiebreak one clear point at a time with targets and margin.',
    blocks: [
      LessonBlock(
        kind: 'overview',
        body: 'A tiebreak rewards a steady routine because every point has extra weight. Choose a dependable target, protect the middle, and make the opponent earn the next opening instead of forcing a low-percentage winner.',
      ),
      LessonBlock(
        kind: 'steps',
        body: '1. Call the score and settle into the same routine before each point. 2. Start serves and returns with clear targets. 3. Play the safe cross-court ball when the position is neutral. 4. Change direction only when you have time and space, then reset for the next point.',
      ),
      LessonBlock(
        kind: 'tips',
        body: 'Treat the tiebreak as a sequence of small decisions, not one long test. Breathe after each point and keep the two-point winning margin in mind without rushing.',
      ),
      LessonBlock(
        kind: 'mistakes',
        body: 'Chasing a quick winner, abandoning a reliable serve pattern after one miss, or letting the previous point change the next-point routine.',
      ),
    ],
  ),
];

const moreGlossary = <GlossaryTerm>[
  GlossaryTerm(
    term: 'Break point',
    definition: 'A point the receiver can win to take the server\'s game.',
  ),
  GlossaryTerm(
    term: 'Deuce court',
    definition: 'The server\'s right-hand side of the court, where the first point of a game is served.',
  ),
  GlossaryTerm(
    term: 'Ad court',
    definition: 'The server\'s left-hand side of the court, used for the point after deuce.',
  ),
  GlossaryTerm(
    term: 'Continental grip',
    definition: 'A hammer-like grip commonly used for serves, volleys, slices, and overheads.',
  ),
  GlossaryTerm(
    term: 'Eastern grip',
    definition: 'A forehand grip that puts the palm more behind the handle for comfortable flatter contact.',
  ),
  GlossaryTerm(
    term: 'Sweet spot',
    definition: 'The racket face area where contact feels solid and sends the ball with little vibration.',
  ),
  GlossaryTerm(
    term: 'Split step',
    definition: 'A small hop that lands as the opponent hits, leaving you balanced to move either way.',
  ),
  GlossaryTerm(
    term: 'Recovery position',
    definition: 'A balanced spot near the middle of your court where you can cover the next shot.',
  ),
  GlossaryTerm(
    term: 'Approach shot',
    definition: 'A shot hit while moving forward to take a better position near the net.',
  ),
  GlossaryTerm(
    term: 'Passing shot',
    definition:
        'A shot aimed beyond an opponent who is positioned near the net.',
  ),
  GlossaryTerm(
    term: 'Kick serve',
    definition: 'A spin serve that clears the net safely and jumps up after it bounces.',
  ),
  GlossaryTerm(
    term: 'Serve plus one',
    definition:
        'A plan to use the serve to set up the first shot after the return.',
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
