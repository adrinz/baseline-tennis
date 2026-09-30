import 'package:baseline/data/nearby_places.dart';
import 'package:baseline/screens/discover_screen.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test('distance labels use miles', () {
    expect(
      NearbyPlace(
        id: 'a',
        name: 'Near',
        address: '',
        phone: '',
        url: '',
        latitude: 0,
        longitude: 0,
        distanceMeters: 100,
      ).distanceLabel,
      'Under 0.1 mi',
    );
    expect(
      NearbyPlace(
        id: 'b',
        name: 'Park',
        address: '',
        phone: '',
        url: '',
        latitude: 0,
        longitude: 0,
        distanceMeters: milesToMeters(1.4),
      ).distanceLabel,
      '1.4 mi',
    );
    expect(
      NearbyPlace(
        id: 'c',
        name: 'Far',
        address: '',
        phone: '',
        url: '',
        latitude: 0,
        longitude: 0,
        distanceMeters: milesToMeters(12.2),
      ).distanceLabel,
      '12 mi',
    );
  });

  testWidgets('E2E-D01 courts at 10 miles keep the nearer parks and school', (
    tester,
  ) async {
    final places = PlacesHarness();
    await pumpDiscover(tester, session: adultSession(), places: places);

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Dix Hills'), findsWidgets);
    expect(find.text('5 mi'), findsOneWidget);
    expect(find.text('Terry Farrell Park'), findsOneWidget);
    expect(find.text('Caledonia Park'), findsOneWidget);
    expect(find.text('Half Hollow Hills High School West'), findsOneWidget);
    expect(find.text('5 tennis courts'), findsOneWidget);
    expect(find.text('Dix Hills Tennis Center'), findsNothing);
    expect(find.textContaining('km'), findsNothing);
    expect(find.text('Tennis Court'), findsNothing);
    expect(
      find.textContaining(
        'A wider distance keeps every court from a shorter one',
      ),
      findsOneWidget,
    );

    await tapSemanticsButton(tester, '10 mi, search radius');

    expect(places.searchMiles('courts'), [5, 10]);
    expect(find.text('Terry Farrell Park'), findsOneWidget);
    expect(find.text('Caledonia Park'), findsOneWidget);
    expect(find.text('Half Hollow Hills High School West'), findsOneWidget);
    expect(find.text('Dix Hills Tennis Center'), findsOneWidget);
    expect(find.text('8.2 mi'), findsOneWidget);
    expect(find.textContaining('4 places within 10 miles'), findsOneWidget);
  });

  testWidgets('E2E-D02 court details have Back, source, and save', (
    tester,
  ) async {
    final places = PlacesHarness();
    await pumpDiscover(tester, session: adultSession(), places: places);

    await tester.tap(find.text('Terry Farrell Park'));
    await tester.pumpAndSettle();

    expect(find.text('Back'), findsWidgets);
    expect(find.text('COURT'), findsOneWidget);
    expect(find.text('5 tennis courts'), findsOneWidget);
    expect(
      find.text('OpenStreetMap, including park and school courts'),
      findsOneWidget,
    );
    expect(find.text('1 mi'), findsNothing);
    expect(find.textContaining('within 5 miles'), findsNothing);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);

    await tester.tap(find.text('Directions'));
    await tester.pump();
    expect(places.calls.map((call) => call.method), contains('directions'));

    await tester.tap(find.text('Back').first);
    await tester.pumpAndSettle();

    expect(find.text('Terry Farrell Park'), findsOneWidget);
    expect(find.text('Caledonia Park'), findsOneWidget);
    expect(find.text('5 mi'), findsOneWidget);
  });

  testWidgets('E2E-D03 a custom mile radius stays between 1 and 50', (
    tester,
  ) async {
    final places = PlacesHarness();
    await pumpDiscover(tester, session: adultSession(), places: places);

    await tapSemanticsButton(tester, 'Other, search radius');
    await tester.pump();
    expect(find.text('Distance in miles'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '80');
    await tester.tap(find.text('Use this distance'));
    await tester.pumpAndSettle();

    expect(places.searchMiles('courts').last, 50);
    expect(find.text('50 mi'), findsOneWidget);
    expect(find.text('Dix Hills Tennis Center'), findsOneWidget);
    expect(find.text('Terry Farrell Park'), findsOneWidget);
  });

  testWidgets('E2E-D04 coaches and stores keep nearer places at 10 miles', (
    tester,
  ) async {
    final places = PlacesHarness();
    await pumpDiscover(tester, session: adultSession(), places: places);

    await tapSemanticsButton(tester, 'Coaches');
    expect(
      find.text(
        'Tennis coaches, instructors, academies, and clubs. A wider distance keeps every coach from a shorter one.',
      ),
      findsOneWidget,
    );
    expect(find.text('Avery Lane Tennis'), findsOneWidget);
    expect(find.text('West Hills Tennis Coaching'), findsNothing);
    expect(places.searchMiles('coaches'), [5]);

    await tapSemanticsButton(tester, '10 mi, search radius');
    expect(places.searchMiles('coaches'), [5, 10]);
    expect(find.text('Avery Lane Tennis'), findsOneWidget);
    expect(find.text('West Hills Tennis Coaching'), findsOneWidget);

    await tester.tap(find.text('Avery Lane Tennis'));
    await tester.pumpAndSettle();
    expect(find.text('COACH'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(
      find.text('Apple Maps, based on your current location'),
      findsOneWidget,
    );
    await tester.tap(find.text('Back').first);
    await tester.pumpAndSettle();

    await tapSemanticsButton(tester, 'Stores');
    expect(
      find.text(
        'Tennis shops, stringers, and sporting-goods stores. A wider distance keeps every shop from a shorter one.',
      ),
      findsOneWidget,
    );
    expect(find.text('String and Grip Shop'), findsOneWidget);
    expect(find.text('Baseline Outfitters'), findsNothing);

    await tapSemanticsButton(tester, '10 mi, search radius');
    expect(places.searchMiles('stores'), [5, 10]);
    expect(find.text('String and Grip Shop'), findsOneWidget);
    expect(find.text('Baseline Outfitters'), findsOneWidget);
  });

  testWidgets('E2E-D05 adult players use a mile band and stay unpinned', (
    tester,
  ) async {
    final places = PlacesHarness();
    await pumpDiscover(tester, session: adultSession(), places: places);

    await tapSemanticsButton(tester, 'Players');
    expect(find.text('Discoverable'), findsOneWidget);
    expect(find.text('Park Ave Tennis'), findsOneWidget);
    expect(find.text('Deer Park Tennis Club'), findsNothing);
    expect(find.textContaining('exact location stays hidden'), findsOneWidget);
    expect(places.searchMiles('players'), [5]);

    await tapSemanticsButton(tester, '10 mi, search radius');
    expect(places.searchMiles('players'), [5, 10]);
    expect(find.text('Park Ave Tennis'), findsOneWidget);
    expect(find.text('Deer Park Tennis Club'), findsOneWidget);
    expect(
      find.textContaining(
        'A wider distance includes everyone from a shorter one',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Discoverable'));
    await tester.pumpAndSettle();
    expect(find.text('Show a distance band?'), findsOneWidget);
    expect(find.textContaining('within 5 miles'), findsOneWidget);
    await tester.tap(find.text('Show me'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Players see your city and a distance band'),
      findsOneWidget,
    );
  });

  testWidgets('E2E-D06 players under 18 stay off discovery', (tester) async {
    final places = PlacesHarness();
    await pumpDiscover(tester, session: minorSession(), places: places);

    await tapSemanticsButton(tester, 'Players');
    expect(find.text('Player discovery is off'), findsOneWidget);
    expect(find.textContaining('until you are 18'), findsOneWidget);
    expect(find.text('Discoverable'), findsNothing);
    expect(find.text('5 mi'), findsNothing);
    expect(places.searchMiles('players'), isEmpty);
  });

  testWidgets('E2E-D07 denied location explains how to turn it on', (
    tester,
  ) async {
    final places = PlacesHarness(status: 'denied', locality: '');
    await pumpDiscover(
      tester,
      session: adultSession(city: 'Dix Hills'),
      places: places,
    );

    expect(find.text('Location is off'), findsOneWidget);
    expect(find.text('Open Settings'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    await tester.pump();
    expect(places.calls.map((call) => call.method), contains('openSettings'));
  });

  testWidgets('E2E-D08 a wider search can arrive after the first courts', (
    tester,
  ) async {
    final places = PlacesHarness()..searching = true;
    mockSavedSession();
    usePhoneSurface(tester);
    places.install(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(
            () => SessionController(initial: adultSession()),
          ),
        ],
        child: const MaterialApp(home: DiscoverScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Terry Farrell Park'), findsOneWidget);
    expect(find.text('Finding more courts farther out…'), findsOneWidget);
    expect(find.text('Dix Hills Tennis Center'), findsNothing);

    const codec = StandardMethodCodec();
    final data = codec.encodeMethodCall(
      MethodCall('placesUpdate', {
        'token': places.token,
        'searching': false,
        'places': namedCourts,
      }),
    );
    tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      placesChannel.name,
      data,
      (_) {},
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Finding more courts farther out…'), findsNothing);
    expect(find.text('Terry Farrell Park'), findsOneWidget);
    expect(find.text('Caledonia Park'), findsOneWidget);
    expect(find.text('Half Hollow Hills High School West'), findsOneWidget);
    expect(find.text('Dix Hills Tennis Center'), findsOneWidget);
  });
}
