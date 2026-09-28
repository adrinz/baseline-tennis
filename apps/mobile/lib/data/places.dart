class CourtPlace {
  const CourtPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.surface,
    required this.lights,
    required this.indoor,
    required this.access,
    required this.hours,
    required this.priceText,
    required this.courtCount,
  });

  final String id;
  final String name;
  final String address;
  final String surface;
  final bool lights;
  final bool indoor;
  final String access;
  final String hours;
  final String priceText;
  final int courtCount;
}

class PlayerCardData {
  const PlayerCardData({
    required this.displayName,
    required this.levelLabel,
    required this.format,
    required this.city,
    required this.distanceBand,
    required this.goals,
    required this.availability,
  });

  final String displayName;
  final String levelLabel;
  final String format;
  final String city;
  final String distanceBand;
  final String goals;
  final String availability;
}

class CoachPlace {
  const CoachPlace({
    required this.name,
    required this.audience,
    required this.format,
    required this.area,
    required this.priceText,
    required this.summary,
  });

  final String name;
  final String audience;
  final String format;
  final String area;
  final String priceText;
  final String summary;
}

class StorePlace {
  const StorePlace({
    required this.name,
    required this.services,
    required this.area,
    required this.summary,
  });

  final String name;
  final String services;
  final String area;
  final String summary;
}

/// Sample Austin public tennis centers for the offline Discover list.
const austinCourts = <CourtPlace>[
  CourtPlace(
    id: 'caswell',
    name: 'Caswell Tennis Center',
    address: '2312 Shoal Creek Blvd, Austin, TX',
    surface: 'Hard',
    lights: true,
    indoor: false,
    access: 'Public',
    hours: 'Weekdays 8:00 a.m.–10:00 p.m. Weekends 8:00 a.m.–6:00 p.m.',
    priceText: 'Court fee by age, about \$3–\$5',
    courtCount: 8,
  ),
  CourtPlace(
    id: 'south-austin',
    name: 'South Austin Tennis Center',
    address: '1000 Cumberland Rd, Austin, TX',
    surface: 'Hard',
    lights: true,
    indoor: false,
    access: 'Public',
    hours: 'Weekdays 8:00 a.m.–10:00 p.m. Weekends 8:00 a.m.–8:00 p.m.',
    priceText: 'About \$2–\$4 for a 90-minute session',
    courtCount: 10,
  ),
  CourtPlace(
    id: 'pharr',
    name: 'Pharr Tennis Center',
    address: '4201 Brookview Rd, Austin, TX',
    surface: 'Hard',
    lights: true,
    indoor: false,
    access: 'Public',
    hours: 'Open seven days. Hours change with the season.',
    priceText: 'About \$1.50–\$4 per person',
    courtCount: 8,
  ),
];

const samplePlayer = PlayerCardData(
  displayName: 'Jordan P.',
  levelLabel: 'Beginner',
  format: 'Singles',
  city: 'Austin',
  distanceBand: 'Within 5 km',
  goals: 'Rally with consistency',
  availability: 'Weeknights after 6',
);

const sampleCoach = CoachPlace(
  name: 'Riley Nguyen',
  audience: 'Adults and juniors',
  format: 'Private and small groups',
  area: 'Central Austin',
  priceText: 'Intro lesson listed by the coach',
  summary: 'Junior programs appear here as coach listings. They do not create a child account.',
);

const sampleStore = StorePlace(
  name: 'Riverside Stringing',
  services: 'Stringing, grips, and repair',
  area: 'South Congress, Austin',
  summary: 'Sample shop. A paid placement will be labeled Sponsored.',
);

CourtPlace? courtById(String id) {
  for (final court in austinCourts) {
    if (court.id == id) return court;
  }
  return null;
}
