export type ProductSuggestion = {
  id: string;
  name: string;
  category: 'racket' | 'shoes' | 'grips' | 'balls';
  levelMin: number;
  levelMax: number;
  playingStyle: string;
  budgetBand: 'starter' | 'mid' | 'premium';
  summary: string;
  pros: string[];
  considerations: string[];
  priceCents: number | null;
  currency: 'USD';
  retailerName: string;
  retailerUrl: string | null;
  sponsored: boolean;
  placement: 'editorial' | 'sponsored';
};

/** Original equipment notes. None of these are real catalog products. */
export const PRODUCTS: ProductSuggestion[] = [
  {
    id: 'harborline-learn-27',
    name: 'Harborline Learn 27',
    category: 'racket',
    levelMin: 1,
    levelMax: 2,
    playingStyle: 'learning the first rally',
    budgetBand: 'starter',
    summary: 'A light adult racket with a large face so early contact still finds the strings.',
    pros: ['Easier to swing for a full session', 'A bigger face forgives contact that is a little off center'],
    considerations: ['Players who already rally comfortably may want a slightly smaller head later.'],
    priceCents: 7900,
    currency: 'USD',
    retailerName: 'Baseline Outfitters',
    retailerUrl: null,
    sponsored: false,
    placement: 'editorial',
  },
  {
    id: 'quiet-court-shoe',
    name: 'Quiet Court Shoe',
    category: 'shoes',
    levelMin: 1,
    levelMax: 5,
    playingStyle: 'hard-court sessions',
    budgetBand: 'mid',
    summary: 'A hard-court shoe with a stable heel so split-steps do not roll the ankle.',
    pros: ['Sole pattern meant for hard courts', 'A wider toe box than a running shoe'],
    considerations: ['Replace them when the tread smooths out. Running shoes are a poor substitute on a court.'],
    priceCents: 11000,
    currency: 'USD',
    retailerName: 'String and Grip Shop',
    retailerUrl: null,
    sponsored: false,
    placement: 'editorial',
  },
  {
    id: 'cloud-tack-overgrip',
    name: 'Cloud Tack Overgrip',
    category: 'grips',
    levelMin: 1,
    levelMax: 5,
    playingStyle: 'any',
    budgetBand: 'starter',
    summary: 'A thin overgrip three-pack so the handle stays dry through a lesson.',
    pros: ['Cheap way to refresh the feel of a used racket', 'Easy to wrap again after a sweaty session'],
    considerations: ['Grip size itself should be checked in a shop if the handle feels painful or numb.'],
    priceCents: 900,
    currency: 'USD',
    retailerName: 'String and Grip Shop',
    retailerUrl: null,
    sponsored: false,
    placement: 'editorial',
  },
  {
    id: 'launchline-match-100',
    name: 'Launchline Match 100',
    category: 'racket',
    levelMin: 3,
    levelMax: 5,
    playingStyle: 'players who already keep a rally',
    budgetBand: 'premium',
    summary: 'A mid-weight frame aimed at players who want a bit more plow on serves and drives.',
    pros: ['More stable when the ball comes in faster', 'A 100 square inch face is still forgiving'],
    considerations: [
      'Heavier than a first racket. Demo one before you buy.',
      'This card is a paid placement and is separate from Baseline’s own picks.',
    ],
    priceCents: 21900,
    currency: 'USD',
    retailerName: 'Launchline',
    retailerUrl: null,
    sponsored: true,
    placement: 'sponsored',
  },
];
