import 'dart:async';

import 'package:flutter/services.dart';

class NearbyPlace {
  const NearbyPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.url,
    this.neighborhood = '',
    this.city = '',
    this.region = '',
    this.postalCode = '',
    this.note = '',
    this.source = '',
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final String url;
  final String neighborhood;
  final String city;
  final String region;
  final String postalCode;
  final String note;
  final String source;
  final double latitude;
  final double longitude;
  final int distanceMeters;

  String get distanceLabel {
    final miles = distanceMeters / 1609.344;
    if (miles < 0.1) return 'Under 0.1 mi';
    if (miles < 10) return '${miles.toStringAsFixed(1)} mi';
    return '${miles.round()} mi';
  }
}

class NearbySearch {
  const NearbySearch({
    required this.status,
    required this.locality,
    required this.places,
    this.token = 0,
    this.searching = false,
  });

  final String status;
  final String locality;
  final List<NearbyPlace> places;

  /// Matches later [NearbyUpdate]s to this search.
  final int token;

  /// True while wider map areas are still loading.
  final bool searching;

  bool get allowed => status == 'ok';
}

/// More courts for a search that is still loading. [places] is the full list so far.
class NearbyUpdate {
  const NearbyUpdate({
    required this.token,
    required this.places,
    required this.searching,
  });

  final int token;
  final List<NearbyPlace> places;
  final bool searching;
}

/// Remembers the latest map results so a detail screen can open one place.
class NearbyDirectory {
  NearbyDirectory._();

  static final instance = NearbyDirectory._();
  final _places = <String, NearbyPlace>{};

  void remember(List<NearbyPlace> places) {
    for (final place in places) {
      _places[place.id] = place;
    }
  }

  NearbyPlace? find(String id) => _places[id];
}

const _channel = MethodChannel('baseline/places');

final _updates = StreamController<NearbyUpdate>.broadcast();
var _listening = false;

/// Courts that arrive after [searchNearby] returns, as wider map areas finish.
Stream<NearbyUpdate> get nearbyUpdates {
  if (!_listening) {
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'placesUpdate' && call.method != 'courtsUpdate') {
        return;
      }
      if (call.arguments is! Map) return;
      final raw = Map<String, dynamic>.from(call.arguments as Map);
      final places = _parsePlaces(raw['places']);
      NearbyDirectory.instance.remember(places);
      _updates.add(
        NearbyUpdate(
          token: (raw['token'] as num?)?.toInt() ?? 0,
          places: places,
          searching: raw['searching'] as bool? ?? false,
        ),
      );
    });
  }
  return _updates.stream;
}

Future<NearbySearch> searchNearby(String kind, {int radiusMiles = 5}) async {
  final raw = await _channel.invokeMapMethod<String, dynamic>('search', {
    'kind': kind,
    'radiusMiles': radiusMiles,
  });
  final places = _parsePlaces(raw?['places']);
  NearbyDirectory.instance.remember(places);
  return NearbySearch(
    status: raw?['status'] as String? ?? 'unavailable',
    locality: raw?['locality'] as String? ?? '',
    places: places,
    token: (raw?['token'] as num?)?.toInt() ?? 0,
    searching: raw?['searching'] as bool? ?? false,
  );
}

List<NearbyPlace> _parsePlaces(Object? rows) {
  final places = <NearbyPlace>[];
  if (rows is List) {
    for (final row in rows) {
      if (row is! Map) continue;
      final map = Map<String, dynamic>.from(row);
      places.add(
        NearbyPlace(
          id: map['id'] as String? ?? '',
          name: map['name'] as String? ?? 'Tennis place',
          address: map['address'] as String? ?? '',
          phone: map['phone'] as String? ?? '',
          url: map['url'] as String? ?? '',
          neighborhood: map['neighborhood'] as String? ?? '',
          city: map['city'] as String? ?? '',
          region: map['region'] as String? ?? '',
          postalCode: map['postalCode'] as String? ?? '',
          note: map['note'] as String? ?? '',
          source: map['source'] as String? ?? '',
          latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
          longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
          distanceMeters: (map['distanceMeters'] as num?)?.toInt() ?? 0,
        ),
      );
    }
  }
  return places;
}

Future<String?> getCurrentLocality() async {
  try {
    final raw = await _channel.invokeMapMethod<String, dynamic>('search', {
      'kind': 'courts',
      'radiusMiles': 1,
    });
    final locality = raw?['locality'] as String?;
    if (locality != null && locality.trim().isNotEmpty) {
      return locality.trim();
    }
  } catch (_) {}
  return null;
}

Future<void> openDirections(NearbyPlace place) {
  return _channel.invokeMethod<void>('directions', {
    'name': place.name,
    'latitude': place.latitude,
    'longitude': place.longitude,
  });
}

Future<void> openLocationSettings() {
  return _channel.invokeMethod<void>('openSettings');
}

Future<void> openExternal(String url) {
  return _channel.invokeMethod<void>('openLink', {'url': url});
}
