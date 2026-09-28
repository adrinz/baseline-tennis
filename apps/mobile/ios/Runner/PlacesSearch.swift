import CoreLocation
import Flutter
import MapKit
import UIKit

/// One search at one radius. Mutated only on the main queue.
private final class SearchRun {
  let token: Int
  let kind: String
  let origin: CLLocation
  let radiusMeters: Double
  var apple: [[String: Any]] = []
  var osmElements: [String: [String: Any]] = [:]
  var tileQueue: [[Double]] = []
  var tilesPending = 0
  var appleTileQueue: [[Double]] = []
  var appleTilesPending = 0
  var appleDone = false
  var firstTileDone = false
  var delivered = false
  var done = false

  init(token: Int, kind: String, origin: CLLocation, radiusMeters: Double) {
    self.token = token
    self.kind = kind
    self.origin = origin
    self.radiusMeters = radiusMeters
  }
}

/// Places found on earlier searches, so a wider radius never shows fewer places than a smaller one.
private enum PlaceCache {
  private static let limit = 3000

  private static func storageKey(_ kind: String) -> String {
    kind == "courts" ? "baseline.courtCache.v2" : "baseline.placeCache.v1.\(kind)"
  }

  static func store(_ kind: String, _ places: [[String: Any]]) {
    guard !places.isEmpty else { return }
    let key = storageKey(kind)
    var saved = UserDefaults.standard.dictionary(forKey: key) as? [String: [String: Any]] ?? [:]
    for place in places {
      guard let id = place["id"] as? String, !id.isEmpty else { continue }
      var copy = place
      copy.removeValue(forKey: "distanceMeters")
      copy["savedAt"] = Date().timeIntervalSince1970
      saved[id] = copy
    }
    if saved.count > limit {
      let oldest = saved.sorted {
        ($0.value["savedAt"] as? Double ?? 0) < ($1.value["savedAt"] as? Double ?? 0)
      }
      for (id, _) in oldest.prefix(saved.count - limit) {
        saved.removeValue(forKey: id)
      }
    }
    UserDefaults.standard.set(saved, forKey: key)
  }

  static func within(_ kind: String, _ origin: CLLocation, radiusMeters: Double) -> [[String: Any]] {
    let saved = UserDefaults.standard.dictionary(forKey: storageKey(kind)) as? [String: [String: Any]] ?? [:]
    return saved.values.compactMap { place in
      guard
        let latitude = (place["latitude"] as? NSNumber)?.doubleValue,
        let longitude = (place["longitude"] as? NSNumber)?.doubleValue
      else { return nil }
      let meters = origin.distance(from: CLLocation(latitude: latitude, longitude: longitude))
      guard meters <= radiusMeters else { return nil }
      var copy = place
      copy.removeValue(forKey: "savedAt")
      copy["distanceMeters"] = Int(meters.rounded())
      return copy
    }
  }
}

/// Looks up tennis places with the phone's location, Apple Maps, and OpenStreetMap.
final class PlacesChannel: NSObject, CLLocationManagerDelegate {
  static let shared = PlacesChannel()

  private static let overpassHosts = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.private.coffee/api/interpreter",
  ]
  private static let tileSideMeters = 16_093.44
  private static let parallelTiles = 2
  private static let firstResultWait = 7.0
  private static let searchDeadline = 120.0

  private let manager = CLLocationManager()
  private var channel: FlutterMethodChannel?
  private var pendingResult: FlutterResult?
  private var pendingKind = "courts"
  private var pendingRadiusMiles = 5.0
  private var activeToken = 0
  private var didStartSearch = false

  static func register(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "BaselinePlaces") else { return }
    let channel = FlutterMethodChannel(
      name: "baseline/places",
      binaryMessenger: registrar.messenger()
    )
    shared.channel = channel
    shared.manager.delegate = shared
    shared.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    channel.setMethodCallHandler { call, result in
      shared.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "search":
      let args = call.arguments as? [String: Any]
      let miles = (args?["radiusMiles"] as? NSNumber)?.doubleValue ?? 5
      search(kind: args?["kind"] as? String ?? "courts", radiusMiles: miles, result: result)
    case "directions":
      let args = call.arguments as? [String: Any]
      openDirections(args)
      result(nil)
    case "openLink":
      let args = call.arguments as? [String: Any]
      if let raw = args?["url"] as? String, let url = URL(string: raw) {
        UIApplication.shared.open(url)
      }
      result(nil)
    case "openSettings":
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func search(kind: String, radiusMiles: Double, result: @escaping FlutterResult) {
    if let previous = pendingResult {
      previous(["status": "cancelled", "places": []])
    }
    activeToken += 1
    pendingResult = result
    pendingKind = kind
    pendingRadiusMiles = min(50, max(1, radiusMiles))
    didStartSearch = false

    switch manager.authorizationStatus {
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
    case .authorizedAlways, .authorizedWhenInUse:
      didStartSearch = true
      manager.requestLocation()
    case .denied, .restricted:
      finish(token: activeToken, status: "denied", location: nil, places: [])
    @unknown default:
      finish(token: activeToken, status: "unavailable", location: nil, places: [])
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard pendingResult != nil, !didStartSearch else { return }
    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      didStartSearch = true
      manager.requestLocation()
    case .denied, .restricted:
      finish(token: activeToken, status: "denied", location: nil, places: [])
    case .notDetermined:
      break
    @unknown default:
      finish(token: activeToken, status: "unavailable", location: nil, places: [])
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else {
      finish(token: activeToken, status: "unavailable", location: nil, places: [])
      return
    }
    guard pendingResult != nil else { return }
    let run = SearchRun(
      token: activeToken,
      kind: pendingKind,
      origin: location,
      radiusMeters: pendingRadiusMiles * 1609.344
    )
    startAppleSearch(run)
    if run.kind == "courts" {
      startTiles(run)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + Self.firstResultWait) { [weak self] in
      self?.deliver(run, force: true)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + Self.searchDeadline) { [weak self] in
      guard let self, !run.done else { return }
      run.tileQueue.removeAll()
      run.tilesPending = 0
      run.appleTileQueue.removeAll()
      run.appleTilesPending = 0
      self.deliver(run, force: true)
      self.pushUpdate(run)
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    finish(token: activeToken, status: "unavailable", location: nil, places: [])
  }

  // MARK: Apple Maps

  private func startAppleSearch(_ run: SearchRun) {
    if run.kind == "courts" {
      let region = MKCoordinateRegion(
        center: run.origin.coordinate,
        latitudinalMeters: run.radiusMeters * 2,
        longitudinalMeters: run.radiusMeters * 2
      )
      searchApple(run, region: region) { found in
        run.apple = found
        run.appleDone = true
        PlaceCache.store(run.kind, found)
      }
      return
    }
    run.appleTileQueue = Self.tiles(around: run.origin, radiusMeters: run.radiusMeters)
    run.appleTilesPending = run.appleTileQueue.count
    if run.appleTileQueue.isEmpty {
      run.appleDone = true
      deliver(run)
      return
    }
    for _ in 0..<min(Self.parallelTiles, run.appleTileQueue.count) {
      nextAppleTile(run)
    }
  }

  /// Coaches and stores are searched one area at a time, nearest first, so a wider distance keeps nearer places.
  private func nextAppleTile(_ run: SearchRun) {
    guard run.token == activeToken, !run.done, !run.appleTileQueue.isEmpty else { return }
    let box = run.appleTileQueue.removeFirst()
    let center = CLLocationCoordinate2D(
      latitude: (box[0] + box[2]) / 2,
      longitude: (box[1] + box[3]) / 2
    )
    let span = min(Self.tileSideMeters, run.radiusMeters * 2)
    let region = MKCoordinateRegion(
      center: center,
      latitudinalMeters: span,
      longitudinalMeters: span
    )
    searchApple(run, region: region) { found in
      guard run.token == self.activeToken, !run.done else { return }
      run.apple.append(contentsOf: found)
      PlaceCache.store(run.kind, found)
      run.appleTilesPending = max(0, run.appleTilesPending - 1)
      run.firstTileDone = true
      run.appleDone = run.appleTilesPending == 0 && run.appleTileQueue.isEmpty
      self.nextAppleTile(run)
    }
  }

  private func searchApple(
    _ run: SearchRun,
    region: MKCoordinateRegion,
    apply: @escaping ([[String: Any]]) -> Void
  ) {
    let group = DispatchGroup()
    var found: [[String: Any]] = []
    for query in queries(for: run.kind) {
      group.enter()
      let request = MKLocalSearch.Request()
      request.naturalLanguageQuery = query
      request.region = region
      request.resultTypes = .pointOfInterest
      MKLocalSearch(request: request).start { response, _ in
        let mapped = (response?.mapItems ?? []).compactMap { item in
          Self.place(from: item, origin: run.origin, kind: run.kind)
        }
        DispatchQueue.main.async {
          found.append(contentsOf: mapped)
          group.leave()
        }
      }
    }
    group.notify(queue: .main) { [weak self] in
      apply(found)
      guard let self else { return }
      if run.delivered {
        self.pushUpdate(run)
      } else {
        self.deliver(run)
      }
    }
  }

  private func queries(for kind: String) -> [String] {
    switch kind {
    case "coaches":
      return ["tennis coach"]
    case "stores":
      return ["tennis shop"]
    default:
      return ["tennis court", "tennis club", "tennis academy", "tennis center"]
    }
  }

  // MARK: OpenStreetMap tiles

  private func startTiles(_ run: SearchRun) {
    run.tileQueue = Self.tiles(around: run.origin, radiusMeters: run.radiusMeters)
    run.tilesPending = run.tileQueue.count
    for _ in 0..<min(Self.parallelTiles, run.tileQueue.count) {
      nextTile(run)
    }
  }

  private func nextTile(_ run: SearchRun) {
    guard run.token == activeToken, !run.done, !run.tileQueue.isEmpty else { return }
    let tile = run.tileQueue.removeFirst()
    Self.fetchTile(tile, attempt: 0) { [weak self] elements in
      guard let self, run.token == self.activeToken, !run.done else { return }
      for element in elements {
        let key = "\(element["type"] ?? "n")/\(element["id"] ?? UUID().uuidString)"
        run.osmElements[key] = element
      }
      run.tilesPending = max(0, run.tilesPending - 1)
      run.firstTileDone = true
      if run.delivered {
        self.pushUpdate(run)
      } else {
        self.deliver(run)
      }
      self.nextTile(run)
    }
  }

  /// Square tiles about 10 miles wide covering the search circle, nearest first.
  private static func tiles(around origin: CLLocation, radiusMeters: Double) -> [[Double]] {
    let side = min(tileSideMeters, radiusMeters * 2)
    let steps = Int(ceil(max(0, radiusMeters - side / 2) / side))
    let lat = origin.coordinate.latitude
    let lon = origin.coordinate.longitude
    let latPerMeter = 1 / 111_320.0
    let lonPerMeter = 1 / (111_320.0 * max(0.1, cos(lat * .pi / 180)))
    var tiles: [(distance: Double, box: [Double])] = []
    for i in -steps...steps {
      for j in -steps...steps {
        let x = Double(i) * side
        let y = Double(j) * side
        let nearX = max(0, abs(x) - side / 2)
        let nearY = max(0, abs(y) - side / 2)
        guard hypot(nearX, nearY) <= radiusMeters else { continue }
        let box = [
          lat + (y - side / 2) * latPerMeter,
          lon + (x - side / 2) * lonPerMeter,
          lat + (y + side / 2) * latPerMeter,
          lon + (x + side / 2) * lonPerMeter,
        ]
        tiles.append((hypot(x, y), box))
      }
    }
    return tiles.sorted { $0.distance < $1.distance }.map(\.box)
  }

  private static func fetchTile(
    _ box: [Double],
    attempt: Int,
    completion: @escaping ([[String: Any]]) -> Void
  ) {
    let bbox = box.map { String(format: "%.5f", $0) }.joined(separator: ",")
    let query = """
    [out:json][timeout:25];
    (
      way["leisure"="pitch"]["sport"~"tennis"](\(bbox));
      node["leisure"="pitch"]["sport"~"tennis"](\(bbox));
    )->.p;
    .p out center tags qt;
    (
      way["leisure"="park"]["name"](around.p:180);
      rel["leisure"="park"]["name"](around.p:180);
      way["amenity"~"^(school|college|university)$"]["name"](around.p:180);
      rel["amenity"~"^(school|college|university)$"]["name"](around.p:180);
      nwr["leisure"~"^(sports_centre|stadium)$"]["name"~"academy|tennis cent|racquet|racket",i](around.p:180);
    );
    out center tags qt;
    """
    let host = overpassHosts[attempt % overpassHosts.count]
    guard let url = URL(string: host) else {
      DispatchQueue.main.async { completion([]) }
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = query.data(using: .utf8)
    request.timeoutInterval = 30
    request.setValue("Baseline/1.0 (tennis court search)", forHTTPHeaderField: "User-Agent")
    URLSession.shared.dataTask(with: request) { data, response, _ in
      let status = (response as? HTTPURLResponse)?.statusCode ?? 0
      if status == 200,
        let data,
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let elements = json["elements"] as? [[String: Any]]
      {
        DispatchQueue.main.async { completion(elements) }
        return
      }
      guard attempt < 3 else {
        DispatchQueue.main.async { completion([]) }
        return
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(attempt + 1) * 2) {
        fetchTile(box, attempt: attempt + 1, completion: completion)
      }
    }.resume()
  }

  // MARK: Results

  private func merged(_ run: SearchRun) -> [[String: Any]] {
    var all = run.apple
    if run.kind == "courts" {
      let osm = Self.venues(from: Array(run.osmElements.values), origin: run.origin)
      PlaceCache.store(run.kind, osm)
      all.append(contentsOf: osm)
    }
    all.append(contentsOf: PlaceCache.within(run.kind, run.origin, radiusMeters: run.radiusMeters))
    let limit = Int(run.radiusMeters.rounded())
    let within = all.filter { Self.metersValue($0) <= limit }
    return Self.dedupe(within).sorted { Self.metersValue($0) < Self.metersValue($1) }
  }

  private func deliver(_ run: SearchRun, force: Bool = false) {
    guard run.token == activeToken, !run.delivered else { return }
    let ready = run.kind == "courts"
      ? run.appleDone && (run.firstTileDone || run.tilesPending == 0)
      : run.firstTileDone || run.appleTilesPending == 0
    guard force || ready else { return }
    run.delivered = true
    let searching = isSearching(run)
    if !searching { run.done = true }
    finish(
      token: run.token,
      status: "ok",
      location: run.origin,
      places: merged(run),
      extra: ["token": run.token, "searching": searching]
    )
  }

  private func isSearching(_ run: SearchRun) -> Bool {
    if run.kind == "courts" {
      return run.tilesPending > 0 || !run.appleDone
    }
    return run.appleTilesPending > 0
  }

  private func pushUpdate(_ run: SearchRun) {
    guard run.token == activeToken, run.delivered, !run.done else { return }
    let searching = isSearching(run)
    if !searching { run.done = true }
    channel?.invokeMethod("placesUpdate", arguments: [
      "token": run.token,
      "places": merged(run),
      "searching": searching,
    ])
  }

  private func finish(
    token: Int,
    status: String,
    location: CLLocation?,
    places: [[String: Any]],
    extra: [String: Any] = [:]
  ) {
    guard token == activeToken, let result = pendingResult else { return }
    pendingResult = nil
    didStartSearch = false
    guard let location else {
      result(["status": status, "places": places].merging(extra) { $1 })
      return
    }
    CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
      let locality = placemarks?.first?.locality ?? ""
      let payload: [String: Any] = [
        "status": status,
        "latitude": location.coordinate.latitude,
        "longitude": location.coordinate.longitude,
        "locality": locality,
        "places": places,
      ]
      result(payload.merging(extra) { $1 })
    }
  }

  private func openDirections(_ args: [String: Any]?) {
    guard
      let latitude = args?["latitude"] as? Double,
      let longitude = args?["longitude"] as? Double
    else { return }
    let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    let item = MKMapItem(placemark: placemark)
    item.name = args?["name"] as? String
    item.openInMaps(launchOptions: [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
    ])
  }

  // MARK: Filtering

  /// Keeps a named park, school, academy, or tennis center. Drops private courts and a bare "Tennis Court".
  private static func isShownCourt(_ name: String, fromNamedPlace: Bool) -> Bool {
    let n = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    if n.isEmpty || n.contains("private") || isGenericCourtLabel(n) || !hasSpecificPlaceName(n) {
      return false
    }
    if fromNamedPlace { return true }
    return isAcademySchoolParkOrCenter(n)
  }

  private static func isGenericCourtLabel(_ name: String) -> Bool {
    let cleaned = normalizedPlaceName(name)
    if cleaned.hasPrefix("tennis courts on ") || cleaned.hasPrefix("tennis court on ") {
      return true
    }
    let words = cleaned.split(separator: " ").map(String.init)
    let filler: Set<String> = [
      "tennis", "court", "courts", "the", "a", "public", "outdoor", "indoor",
      "hard", "clay", "grass",
    ]
    return !words.isEmpty && words.allSatisfy { filler.contains($0) || Int($0) != nil }
  }

  private static func hasSpecificPlaceName(_ name: String) -> Bool {
    let words = normalizedPlaceName(name).split(separator: " ").map(String.init)
    let generic: Set<String> = [
      "tennis", "court", "courts", "the", "a", "public", "outdoor", "indoor",
      "hard", "clay", "grass", "park", "parks", "school", "schools", "high",
      "middle", "elementary", "academy", "center", "centre", "racquet", "racket",
      "university", "college", "campus",
    ]
    return words.contains { !generic.contains($0) && Int($0) == nil }
  }

  private static func isAcademySchoolParkOrCenter(_ name: String) -> Bool {
    if name.contains("park") { return true }
    if name.contains("school") || name.contains("campus") || name.contains("elementary")
      || name.contains("university") || name.contains("college") {
      return true
    }
    if name.contains("academy") { return true }
    let center = name.contains("center") || name.contains("centre")
    let tennis = name.contains("tennis") || name.contains("racquet") || name.contains("racket")
    return center && tennis
  }

  private static func normalizedPlaceName(_ name: String) -> String {
    name.lowercased()
      .replacingOccurrences(of: "[^a-z0-9 ]", with: " ", options: .regularExpression)
      .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
      .trimmingCharacters(in: .whitespaces)
  }

  private static func isVenueParent(leisure: String, amenity: String, name: String) -> Bool {
    if leisure == "park" { return true }
    if amenity == "school" || amenity == "university" || amenity == "college" { return true }
    let sportsPlace = leisure == "sports_centre" || leisure == "stadium"
    guard sportsPlace else { return false }
    let lower = name.lowercased()
    return lower.contains("academy")
      || lower.contains("tennis center")
      || lower.contains("tennis centre")
      || lower.contains("racquet")
      || lower.contains("racket")
  }

  // MARK: Mapping

  private static func place(from item: MKMapItem, origin: CLLocation, kind: String) -> [String: Any]? {
    let placemark = item.placemark
    let coordinate = placemark.coordinate
    let meters = origin.distance(
      from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    )
    let name = item.name ?? ""
    if kind == "courts" {
      guard isShownCourt(name, fromNamedPlace: false) else { return nil }
    } else if name.isEmpty {
      return nil
    }
    return [
      "id": "\(coordinate.latitude),\(coordinate.longitude),\(name)",
      "name": name,
      "address": address(from: placemark),
      "neighborhood": placemark.subLocality ?? "",
      "city": placemark.locality ?? "",
      "region": placemark.administrativeArea ?? "",
      "postalCode": placemark.postalCode ?? "",
      "phone": item.phoneNumber ?? "",
      "url": item.url?.absoluteString ?? "",
      "note": "",
      "source": "Apple Maps",
      "latitude": coordinate.latitude,
      "longitude": coordinate.longitude,
      "distanceMeters": Int(meters.rounded()),
    ]
  }

  /// One row per park, school, or club. Courts inside the same place are counted together.
  private static func venues(from elements: [[String: Any]], origin: CLLocation) -> [[String: Any]] {
    struct Spot {
      let id: String
      let latitude: Double
      let longitude: Double
      let name: String
      let tags: [String: Any]
    }
    struct Venue {
      var id: String
      var name: String
      var tags: [String: Any]
      var fromNamedPlace: Bool
      var count = 0
      var latitudeSum = 0.0
      var longitudeSum = 0.0
      var surfaces = Set<String>()
      var lights = 0
      var unlit = 0
    }

    var pitches: [Spot] = []
    var parents: [Spot] = []
    for element in elements {
      let tags = element["tags"] as? [String: Any] ?? [:]
      let center = element["center"] as? [String: Any]
      guard
        let latitude = doubleValue(element["lat"]) ?? doubleValue(center?["lat"]),
        let longitude = doubleValue(element["lon"]) ?? doubleValue(center?["lon"])
      else { continue }
      let leisure = (tag(tags, "leisure") ?? "").lowercased()
      let sport = (tag(tags, "sport") ?? "").lowercased()
      let amenity = (tag(tags, "amenity") ?? "").lowercased()
      let access = (tag(tags, "access") ?? "").lowercased()
      let name = tag(tags, "name") ?? ""
      let id = "\(element["type"] ?? "n")/\(element["id"] ?? "\(latitude),\(longitude)")"
      let spot = Spot(id: id, latitude: latitude, longitude: longitude, name: name, tags: tags)
      if leisure == "pitch" && sport.contains("tennis") {
        if access == "private" || access == "no" || name.lowercased().contains("private") {
          continue
        }
        pitches.append(spot)
      } else if !name.isEmpty && isVenueParent(leisure: leisure, amenity: amenity, name: name) {
        if access == "private" || access == "no" { continue }
        parents.append(spot)
      }
    }

    var groups: [String: Venue] = [:]
    for pitch in pitches {
      let here = CLLocation(latitude: pitch.latitude, longitude: pitch.longitude)
      var nearest: Spot?
      var nearestMeters = 180.0
      for parent in parents {
        let meters = here.distance(from: CLLocation(latitude: parent.latitude, longitude: parent.longitude))
        if meters <= nearestMeters {
          nearestMeters = meters
          nearest = parent
        }
      }
      let key = nearest?.id ?? "pitch/\(pitch.id)"
      var venue = groups[key] ?? Venue(
        id: "osm-\(key)",
        name: nearest?.name ?? courtName(tags: pitch.tags),
        tags: nearest?.tags ?? pitch.tags,
        fromNamedPlace: nearest != nil
      )
      venue.count += 1
      venue.latitudeSum += pitch.latitude
      venue.longitudeSum += pitch.longitude
      if let surface = tag(pitch.tags, "surface") {
        venue.surfaces.insert(surface.capitalized)
      }
      if tag(pitch.tags, "lit") == "yes" { venue.lights += 1 }
      if tag(pitch.tags, "lit") == "no" { venue.unlit += 1 }
      groups[key] = venue
    }

    return groups.values.compactMap { venue -> [String: Any]? in
      guard isShownCourt(venue.name, fromNamedPlace: venue.fromNamedPlace) else { return nil }
      let count = max(venue.count, 1)
      let latitude = venue.latitudeSum / Double(count)
      let longitude = venue.longitudeSum / Double(count)
      let coordinate = CLLocation(latitude: latitude, longitude: longitude)
      var notes = ["\(count) tennis court\(count == 1 ? "" : "s")"]
      if venue.surfaces.count == 1, let surface = venue.surfaces.first {
        notes.append(surface)
      }
      if venue.lights > 0 && venue.unlit == 0 { notes.append("Lights") }
      let street = tag(venue.tags, "addr:street")
      let city = tag(venue.tags, "addr:city") ?? ""
      let region = tag(venue.tags, "addr:state") ?? ""
      return [
        "id": venue.id,
        "name": venue.name,
        "address": [street, city, region].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", "),
        "neighborhood": "",
        "city": city,
        "region": region,
        "postalCode": tag(venue.tags, "addr:postcode") ?? "",
        "phone": tag(venue.tags, "phone") ?? "",
        "url": tag(venue.tags, "website") ?? tag(venue.tags, "contact:website") ?? "",
        "note": notes.joined(separator: " · "),
        "source": "OpenStreetMap",
        "latitude": latitude,
        "longitude": longitude,
        "distanceMeters": Int(origin.distance(from: coordinate).rounded()),
      ]
    }
  }

  private static func courtName(tags: [String: Any]) -> String {
    if let name = tag(tags, "name") { return name }
    return "Tennis courts"
  }

  private static func metersValue(_ place: [String: Any]) -> Int {
    if let meters = place["distanceMeters"] as? Int { return meters }
    if let meters = place["distanceMeters"] as? NSNumber { return meters.intValue }
    return Int.max
  }

  private static func tag(_ tags: [String: Any], _ key: String) -> String? {
    guard let value = tags[key] as? String else { return nil }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  private static func doubleValue(_ value: Any?) -> Double? {
    switch value {
    case let number as NSNumber:
      return number.doubleValue
    case let text as String:
      return Double(text)
    default:
      return nil
    }
  }

  private static func dedupe(_ places: [[String: Any]]) -> [[String: Any]] {
    var byId: [String: [String: Any]] = [:]
    var order: [String] = []
    for place in places {
      let id = place["id"] as? String ?? UUID().uuidString
      if let existing = byId[id] {
        if prefer(place, over: existing) { byId[id] = place }
      } else {
        byId[id] = place
        order.append(id)
      }
    }
    var kept: [[String: Any]] = []
    for id in order {
      guard let place = byId[id] else { continue }
      let here = CLLocation(
        latitude: doubleValue(place["latitude"]) ?? 0,
        longitude: doubleValue(place["longitude"]) ?? 0
      )
      if let index = kept.firstIndex(where: { existing in
        let other = CLLocation(
          latitude: doubleValue(existing["latitude"]) ?? 0,
          longitude: doubleValue(existing["longitude"]) ?? 0
        )
        let meters = here.distance(from: other)
        if meters < 40 { return true }
        guard meters < 150 else { return false }
        let left = normalizedPlaceName(existing["name"] as? String ?? "")
        let right = normalizedPlaceName(place["name"] as? String ?? "")
        return left == right || left.hasPrefix(right) || right.hasPrefix(left)
      }) {
        if prefer(place, over: kept[index]) {
          kept[index] = place
        }
      } else {
        kept.append(place)
      }
    }
    return kept
  }

  /// Prefers the OpenStreetMap row (it carries a court count), then the one with more details.
  private static func prefer(_ place: [String: Any], over existing: [String: Any]) -> Bool {
    let newCount = courtCount(place)
    let oldCount = courtCount(existing)
    if newCount != oldCount { return newCount > oldCount }
    let newNote = place["note"] as? String ?? ""
    let oldNote = existing["note"] as? String ?? ""
    return newNote.count > oldNote.count
  }

  private static func courtCount(_ place: [String: Any]) -> Int {
    let note = place["note"] as? String ?? ""
    guard let first = note.split(separator: " ").first else { return 0 }
    return Int(first) ?? 0
  }

  private static func address(from placemark: MKPlacemark) -> String {
    let street = [placemark.subThoroughfare, placemark.thoroughfare]
      .compactMap { $0 }
      .joined(separator: " ")
    let city = [placemark.locality, placemark.administrativeArea, placemark.postalCode]
      .compactMap { $0 }
      .joined(separator: " ")
    return [street, city].filter { !$0.isEmpty }.joined(separator: ", ")
  }
}
