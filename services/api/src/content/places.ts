import { coarseCell } from '../geo.ts';

export type CourtRecord = {
  id: string;
  name: string;
  courtCount: number;
  indoor: boolean;
  access: 'public' | 'private' | 'club' | 'unknown';
  lights: boolean;
  surface: string;
  priceText: string | null;
  bookingUrl: string | null;
  address: string;
  city: string;
  phone: string | null;
  website: string | null;
  hours: Record<string, string>;
  lat: number;
  lng: number;
  source: 'admin';
};

export type CoachRecord = {
  id: string;
  name: string;
  credentials: string;
  yearsExperience: number;
  specialties: string[];
  audience: 'adult' | 'junior' | 'both';
  format: 'private' | 'group' | 'both';
  priceText: string;
  priceBand: 'mid' | 'high';
  city: string;
  address: string;
  contactUrl: string | null;
  lat: number;
  lng: number;
  summary: string;
};

export type StoreRecord = {
  id: string;
  name: string;
  services: string[];
  city: string;
  address: string;
  phone: string | null;
  website: string | null;
  hours: Record<string, string>;
  lat: number;
  lng: number;
  summary: string;
};

export type SeedPlayer = {
  id: string;
  email: string;
  birthYear: number;
  displayName: string;
  level: number;
  format: 'singles' | 'doubles' | 'both';
  primaryGoal: string;
  focusSkills: string[];
  setting: 'indoor' | 'outdoor' | 'either';
  homeCity: string;
  availability: { summary: string };
  locationCell: { lat: number; lng: number };
  playFrequency: string;
  daysPerWeek: 2 | 3 | 4 | 5;
};

/** Fictional public places around a sample map center. Not real venues. */
export const COURTS: CourtRecord[] = [
  {
    id: 'court-riverton-municipal',
    name: 'Riverton Municipal Courts',
    courtCount: 6,
    indoor: false,
    access: 'public',
    lights: true,
    surface: 'hard',
    priceText: 'Free with a park permit',
    bookingUrl: null,
    address: '100 Court Street, Riverton',
    city: 'Riverton',
    phone: null,
    website: null,
    hours: { mon: '07:00-21:00', sat: '08:00-18:00' },
    lat: 40.73,
    lng: -73.99,
    source: 'admin',
  },
  {
    id: 'court-north-loop-indoor',
    name: 'North Loop Indoor Tennis',
    courtCount: 4,
    indoor: true,
    access: 'club',
    lights: true,
    surface: 'hard',
    priceText: 'Day pass listed at the desk',
    bookingUrl: null,
    address: '18 Loop Avenue, Riverton',
    city: 'Riverton',
    phone: null,
    website: null,
    hours: { mon: '06:00-22:00' },
    lat: 40.733,
    lng: -73.987,
    source: 'admin',
  },
  {
    id: 'court-cedar-park',
    name: 'Cedar Park Public Courts',
    courtCount: 2,
    indoor: false,
    access: 'public',
    lights: false,
    surface: 'clay',
    priceText: 'Free',
    bookingUrl: null,
    address: '4 Cedar Path, Riverton',
    city: 'Riverton',
    phone: null,
    website: null,
    hours: { mon: '08:00-dusk' },
    lat: 40.79,
    lng: -73.96,
    source: 'admin',
  },
];

export const COACHES: CoachRecord[] = [
  {
    id: 'coach-avery-lane',
    name: 'Avery Lane',
    credentials: 'Community coach, beginner groups',
    yearsExperience: 8,
    specialties: ['forehand', 'rallying fundamentals'],
    audience: 'adult',
    format: 'both',
    priceText: 'Intro lesson listed on request',
    priceBand: 'mid',
    city: 'Riverton',
    address: '100 Court Street, Riverton',
    contactUrl: null,
    lat: 40.73,
    lng: -73.99,
    summary: 'Teaches first rallies and a calm ready position for new adults.',
  },
  {
    id: 'coach-morgan-hale',
    name: 'Morgan Hale',
    credentials: 'Club pro, match-play groups',
    yearsExperience: 12,
    specialties: ['serve', 'point construction'],
    audience: 'both',
    format: 'group',
    priceText: 'Group block, higher than a public clinic',
    priceBand: 'high',
    city: 'Riverton',
    address: '18 Loop Avenue, Riverton',
    contactUrl: null,
    lat: 40.733,
    lng: -73.987,
    summary: 'Runs small groups for players who can already keep a rally going.',
  },
];

export const STORES: StoreRecord[] = [
  {
    id: 'store-string-and-grip',
    name: 'String and Grip Shop',
    services: ['stringing', 'grips', 'repair'],
    city: 'Riverton',
    address: '22 Court Street, Riverton',
    phone: null,
    website: null,
    hours: { tue: '10:00-18:00', sat: '10:00-16:00' },
    lat: 40.731,
    lng: -73.989,
    summary: 'Same-week stringing and fresh grips next to the municipal courts.',
  },
  {
    id: 'store-baseline-outfitters',
    name: 'Baseline Outfitters',
    services: ['shoes', 'rackets', 'used'],
    city: 'Riverton',
    address: '9 Cedar Path, Riverton',
    phone: null,
    website: null,
    hours: { mon: '11:00-19:00' },
    lat: 40.788,
    lng: -73.962,
    summary: 'Demo rackets and court shoes, including a small used wall.',
  },
];

export const SEED_PLAYERS: SeedPlayer[] = [
  {
    id: 'player-riley',
    email: 'riley.m@baseline.example',
    birthYear: 1994,
    displayName: 'Riley M.',
    level: 2,
    format: 'singles',
    primaryGoal: 'consistency',
    focusSkills: ['forehand'],
    setting: 'outdoor',
    homeCity: 'Riverton',
    availability: { summary: 'Weeknights after 6' },
    locationCell: coarseCell(40.731, -73.991),
    playFrequency: 'weekly',
    daysPerWeek: 3,
  },
  {
    id: 'player-casey',
    email: 'casey.d@baseline.example',
    birthYear: 1991,
    displayName: 'Casey D.',
    level: 3,
    format: 'doubles',
    primaryGoal: 'first match',
    focusSkills: ['serve', 'rally'],
    setting: 'either',
    homeCity: 'Riverton',
    availability: { summary: 'Saturday mornings' },
    locationCell: coarseCell(40.786, -73.962),
    playFrequency: 'twice a week',
    daysPerWeek: 2,
  },
];
