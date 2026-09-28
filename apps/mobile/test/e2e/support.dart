import 'package:baseline/app.dart';
import 'package:baseline/screens/discover_screen.dart';
import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const placesChannel = MethodChannel('baseline/places');

PlayerSession adultSession({
  bool onboardingComplete = true,
  bool premium = false,
  String city = 'Dix Hills',
}) {
  return PlayerSession(
    authProvider: AuthProvider.email,
    email: 'player@example.com',
    birthYear: DateTime.now().year - 30,
    playedBefore: 'A little',
    level: 1,
    goal: 'Rally with consistency',
    daysPerWeek: 3,
    onboardingComplete: onboardingComplete,
    city: city,
    premium: premium,
  );
}

PlayerSession minorSession() {
  return PlayerSession(
    authProvider: AuthProvider.email,
    email: 'teen@example.com',
    birthYear: DateTime.now().year - 17,
    level: 1,
    onboardingComplete: true,
    city: 'Dix Hills',
  );
}

void usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(402, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void mockSavedSession() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
}

int milesToMeters(double miles) => (miles * 1609.344).round();

Map<String, Object> place({
  required String id,
  required String name,
  required double miles,
  String address = '',
  String note = '',
  String source = 'OpenStreetMap',
  String phone = '',
  String url = '',
  String city = 'Dix Hills',
}) {
  return {
    'id': id,
    'name': name,
    'address': address,
    'phone': phone,
    'url': url,
    'neighborhood': '',
    'city': city,
    'region': 'NY',
    'postalCode': '11746',
    'note': note,
    'source': source,
    'latitude': 40.81,
    'longitude': -73.34,
    'distanceMeters': milesToMeters(miles),
  };
}

/// Named parks, a high school, and a tennis center. A wider mile radius
/// includes every nearer place. Generic "Tennis Court" rows and private
/// courts are absent because the phone search drops them before this list.
final namedCourts = <Map<String, Object>>[
  place(
    id: 'osm-terry-farrell',
    name: 'Terry Farrell Park',
    miles: 0.8,
    address: 'Wolf Hill Rd and Old Country Rd, Huntington Station',
    note: '5 tennis courts',
  ),
  place(
    id: 'osm-caledonia',
    name: 'Caledonia Park',
    miles: 1.4,
    address: '670 Caledonia Road, Dix Hills',
    note: '2 tennis courts',
  ),
  place(
    id: 'osm-hhh-west',
    name: 'Half Hollow Hills High School West',
    miles: 3.6,
    address: '375 Wolf Hill Rd, Dix Hills',
    note: '8 tennis courts',
  ),
  place(
    id: 'apple-dix-center',
    name: 'Dix Hills Tennis Center',
    miles: 8.2,
    address: 'Dix Hills, NY',
    source: 'Apple Maps',
  ),
];

final namedCoaches = <Map<String, Object>>[
  place(
    id: 'coach-near',
    name: 'Avery Lane Tennis',
    miles: 1.2,
    source: 'Apple Maps',
    phone: '+1 631-555-0142',
  ),
  place(
    id: 'coach-far',
    name: 'West Hills Tennis Coaching',
    miles: 9.1,
    source: 'Apple Maps',
  ),
];

final namedStores = <Map<String, Object>>[
  place(
    id: 'store-near',
    name: 'String and Grip Shop',
    miles: 0.9,
    source: 'Apple Maps',
    url: 'https://example.com/string',
  ),
  place(
    id: 'store-far',
    name: 'Baseline Outfitters',
    miles: 7.4,
    source: 'Apple Maps',
  ),
];

List<Map<String, Object>> withinMiles(
  List<Map<String, Object>> rows,
  int miles,
) {
  final limit = miles * 1609.344;
  return [
    for (final row in rows)
      if ((row['distanceMeters']! as int) <= limit) row,
  ];
}

class PlacesHarness {
  PlacesHarness({this.status = 'ok', this.locality = 'Dix Hills'});

  String status;
  String locality;
  bool searching = false;
  final calls = <MethodCall>[];
  int token = 1;

  void install(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      placesChannel,
      (call) {
        calls.add(call);
        if (call.method != 'search') return null;
        final args = Map<Object?, Object?>.from(call.arguments as Map);
        final kind = args['kind'] as String? ?? 'courts';
        final miles = (args['radiusMiles'] as num?)?.toInt() ?? 5;
        token += 1;
        return Future<Object?>.value(<String, Object?>{
          'status': status,
          'locality': locality,
          'token': token,
          'searching': searching,
          'places': status == 'ok'
              ? _places(kind, miles)
              : <Map<String, Object>>[],
        });
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        placesChannel,
        null,
      );
    });
  }

  List<Map<String, Object>> _places(String kind, int miles) {
    final rows = switch (kind) {
      'coaches' => namedCoaches,
      'stores' => namedStores,
      _ => namedCourts,
    };
    return withinMiles(rows, miles);
  }

  List<int> searchMiles(String kind) {
    return [
      for (final call in calls)
        if (call.method == 'search' && (call.arguments as Map)['kind'] == kind)
          ((call.arguments as Map)['radiusMiles'] as num).toInt(),
    ];
  }
}

Future<void> pumpApp(
  WidgetTester tester, {
  PlayerSession? session,
  PlacesHarness? places,
}) async {
  mockSavedSession();
  usePhoneSurface(tester);
  places?.install(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (session != null)
          sessionProvider.overrideWith(
            () => SessionController(initial: session),
          ),
      ],
      child: const BaselineApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpDiscover(
  WidgetTester tester, {
  required PlayerSession session,
  required PlacesHarness places,
}) async {
  mockSavedSession();
  usePhoneSurface(tester);
  places.install(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(() => SessionController(initial: session)),
      ],
      child: const MaterialApp(home: DiscoverScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapSemanticsButton(WidgetTester tester, String label) async {
  final button = find.byWidgetPredicate((widget) {
    if (widget is! Semantics) return false;
    return widget.properties.button == true && widget.properties.label == label;
  });
  expect(button, findsWidgets);
  await tester.tap(button.first);
  await tester.pumpAndSettle();
}

Future<void> tapTab(WidgetTester tester, String label) async {
  final tab = find.byWidgetPredicate((widget) {
    if (widget is! Semantics) return false;
    return widget.properties.button == true &&
        widget.properties.label == label &&
        widget.properties.selected != null;
  });
  expect(tab, findsOneWidget);
  await tester.ensureVisible(tab);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}
