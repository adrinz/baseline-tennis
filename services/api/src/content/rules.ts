export type RulesArticle = {
  slug: string;
  title: string;
  topic: 'scoring' | 'serve' | 'let';
  summary: string;
  body: {
    sections: Array<{ heading: string; paragraphs: string[] }>;
  };
};

/**
 * Original Baseline teaching notes. Facts are restated in our own words.
 * These are not a copy of a rulebook.
 */
export const RULES_ARTICLES: RulesArticle[] = [
  {
    slug: 'scoring',
    title: 'How a tennis game is counted',
    topic: 'scoring',
    summary: 'Points use love, 15, 30, and 40. Games then build a set.',
    body: {
      sections: [
        {
          heading: 'The words for points',
          paragraphs: [
            'A game starts at love, which simply means zero. The first point a player wins is called 15, the second is 30, and the third is 40.',
            'Take the next point while you are ahead and the game is yours. The server’s score is said first.',
          ],
        },
        {
          heading: 'When both players reach 40',
          paragraphs: [
            'Call that score deuce. The following point is advantage for whoever won it.',
            'Win the point after advantage and you win the game. Lose it and the score goes back to deuce. You always need a two-point lead to close the game.',
          ],
        },
        {
          heading: 'Games and sets',
          paragraphs: [
            'Players take turns serving whole games. A common set is the first person to six games with a lead of two.',
            'If the set reaches six games each, many matches play one short tiebreak game to pick a winner. A match is often the first player to win two sets.',
          ],
        },
      ],
    },
  },
  {
    slug: 'serve',
    title: 'Putting the ball in play',
    topic: 'serve',
    summary: 'The serve starts the point. You get two tries to land it in the diagonal service box.',
    body: {
      sections: [
        {
          heading: 'Where you stand',
          paragraphs: [
            'Start behind the baseline, on the correct side of the center mark. The ball has to land in the service box diagonally across the net.',
            'In a game you swap sides after each point, beginning on the right. Change ends with your opponent after odd-numbered games so sun and wind are shared.',
          ],
        },
        {
          heading: 'Two tries',
          paragraphs: [
            'The first attempt is the first serve. If it misses the box, fails to clear the net, or lands long or wide, that try is a fault and you serve again.',
            'Miss the second serve as well and the receiver wins the point. Players call those two misses in a row a double fault.',
          ],
        },
        {
          heading: 'A serve that counts',
          paragraphs: [
            'A good serve crosses the net and bounces in the correct box. The receiver lets that bounce happen before hitting.',
            'If the receiver cannot touch a serve that landed in, the point is an ace. In practice, aim for a repeatable toss in front of the hitting shoulder before you chase pace.',
          ],
        },
      ],
    },
  },
  {
    slug: 'let',
    title: 'When the point starts over',
    topic: 'let',
    summary: 'A let replays the point. The usual case is a serve that clips the net and still lands in.',
    body: {
      sections: [
        {
          heading: 'A serve that ticks the net',
          paragraphs: [
            'If the serve touches the net and then bounces inside the correct service box, neither player wins the point. Call a let and play that same serve again.',
            'If it touches the net and then misses the box, it is a fault. Do not replay it as a let.',
          ],
        },
        {
          heading: 'An interruption',
          paragraphs: [
            'A let is also the right call when something outside the point gets in the way, such as another court’s ball rolling through your rally.',
            'Replay the whole point. A let is not a way to take back a shot you simply missed.',
          ],
        },
        {
          heading: 'How to call it',
          paragraphs: [
            'Say “let” clearly, then the server starts the same attempt again. Agree on this before a practice match so both people stop at the same time.',
          ],
        },
      ],
    },
  },
];
