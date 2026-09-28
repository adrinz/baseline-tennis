import 'dart:async';

import 'package:baseline/data/nearby_places.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:baseline/data/catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DiscoverSegment { courts, players, coaches, stores }

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  DiscoverSegment _segment = DiscoverSegment.courts;
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<int> _closeRequests = ValueNotifier<int>(0);
  bool _showingPlace = false;

  @override
  void dispose() {
    _scroll.dispose();
    _closeRequests.dispose();
    super.dispose();
  }

  void _setShowingPlace(bool showing) {
    if (_showingPlace == showing) return;
    setState(() => _showingPlace = showing);
    if (!showing) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _closePlace() {
    _closeRequests.value++;
    _setShowingPlace(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_showingPlace)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _closePlace,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: BaselineColors.ink,
                    ),
                    label: const ScaledText(
                      'Back',
                      style: TextStyle(
                        color: BaselineColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: BaselineColors.ink,
                      minimumSize: const Size(kMinTapTarget, kMinTapTarget),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  ScaledText(
                    'Discover',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  ScaledText(
                    session.city.isEmpty ? 'Using your location' : session.city,
                    style: const TextStyle(
                      fontSize: 15,
                      color: BaselineColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SegmentBar(
                    selected: _segment,
                    onChanged: (value) => setState(() {
                      _segment = value;
                      _showingPlace = false;
                    }),
                  ),
                  const SizedBox(height: 16),
                  switch (_segment) {
                    DiscoverSegment.courts => _MapPane(
                      key: const ValueKey('courts'),
                      kind: 'courts',
                      chooseRadius: true,
                      closeRequests: _closeRequests,
                      onShowingPlace: _setShowingPlace,
                      empty: 'No tennis courts showed up in this distance. Try a wider distance.',
                    ),
                    DiscoverSegment.players => _PlayersPane(
                      adult: session.isAdult,
                      discoverable: session.discoverable,
                      onDiscoverable: (value) =>
                          _setDiscoverable(context, value),
                    ),
                    DiscoverSegment.coaches => _MapPane(
                      key: const ValueKey('coaches'),
                      kind: 'coaches',
                      chooseRadius: true,
                      closeRequests: _closeRequests,
                      onShowingPlace: _setShowingPlace,
                      empty: 'No tennis coaches showed up in this distance. Try a wider distance.',
                    ),
                    DiscoverSegment.stores => _MapPane(
                      key: const ValueKey('stores'),
                      kind: 'stores',
                      chooseRadius: true,
                      closeRequests: _closeRequests,
                      onShowingPlace: _setShowingPlace,
                      empty: 'No tennis shops showed up in this distance. Try a wider distance.',
                    ),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setDiscoverable(BuildContext context, bool value) async {
    if (!value) {
      ref.read(sessionProvider.notifier).setDiscoverable(false);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BaselineColors.line,
        title: const ScaledText(
          'Show a distance band?',
          style: BaselineType.cardTitle,
        ),
        content: const ScaledText(
          'Other players see a band such as within 5 miles. Baseline does not share your exact location.',
          style: BaselineType.cardBody,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(kMinTapTarget, kMinTapTarget),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const ScaledText(
              'Not now',
              style: TextStyle(color: BaselineColors.ink),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(kMinTapTarget, kMinTapTarget),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const ScaledText(
              'Show me',
              style: TextStyle(color: BaselineColors.fairway),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(sessionProvider.notifier).setDiscoverable(true);
    }
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({required this.selected, required this.onChanged});

  final DiscoverSegment selected;
  final ValueChanged<DiscoverSegment> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (DiscoverSegment.courts, 'Courts'),
      (DiscoverSegment.players, 'Players'),
      (DiscoverSegment.coaches, 'Coaches'),
      (DiscoverSegment.stores, 'Stores'),
    ];
    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Semantics(
                button: true,
                selected: selected == item.$1,
                label: item.$2,
                child: ExcludeSemantics(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: kMinTapTarget),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: selected == item.$1
                            ? BaselineColors.nightCourt
                            : BaselineColors.track,
                        foregroundColor: selected == item.$1
                            ? BaselineColors.line
                            : BaselineColors.ink,
                        minimumSize: const Size(kMinTapTarget, kMinTapTarget),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => onChanged(item.$1),
                      child: ScaledText(
                        item.$2,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected == item.$1
                              ? BaselineColors.line
                              : BaselineColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MapPane extends ConsumerStatefulWidget {
  const _MapPane({
    super.key,
    required this.kind,
    required this.empty,
    required this.closeRequests,
    required this.onShowingPlace,
    this.chooseRadius = false,
  });

  final String kind;
  final String empty;
  final bool chooseRadius;
  final ValueNotifier<int> closeRequests;
  final ValueChanged<bool> onShowingPlace;

  @override
  ConsumerState<_MapPane> createState() => _MapPaneState();
}

class _MapPaneState extends ConsumerState<_MapPane> {
  static const _presetMiles = [1, 2, 5, 10, 25];
  int _radiusMiles = 5;
  late Future<NearbySearch> _search = searchNearby(
    widget.kind,
    radiusMiles: widget.chooseRadius ? 5 : 12,
  );
  NearbyPlace? _selected;
  NearbyUpdate? _latestUpdate;
  StreamSubscription<NearbyUpdate>? _updates;

  int get _searchMiles => widget.chooseRadius ? _radiusMiles : 12;

  String get _placeNoun => switch (widget.kind) {
    'coaches' => 'coaches',
    'stores' => 'shops',
    _ => 'courts',
  };

  @override
  void initState() {
    super.initState();
    widget.closeRequests.addListener(_closePlace);
    _updates = nearbyUpdates.listen((update) {
      if (mounted) setState(() => _latestUpdate = update);
    });
  }

  @override
  void dispose() {
    widget.closeRequests.removeListener(_closePlace);
    _updates?.cancel();
    super.dispose();
  }

  void _closePlace() {
    if (!mounted || _selected == null) return;
    setState(() => _selected = null);
    widget.onShowingPlace(false);
  }

  void _openPlace(NearbyPlace place) {
    setState(() => _selected = place);
    widget.onShowingPlace(true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.chooseRadius && _selected == null) ...[
          _RadiusControl(
            miles: _radiusMiles,
            presets: _presetMiles,
            caption: switch (widget.kind) {
              'coaches' =>
                'A wider distance keeps every coach from a shorter one.',
              'stores' =>
                'A wider distance keeps every shop from a shorter one.',
              _ => 'Named parks, schools, academies, and tennis centers. A wider distance keeps every court from a shorter one.',
            },
            onSelected: _setRadius,
            onCustom: _chooseCustomMiles,
          ),
          const SizedBox(height: 12),
        ],
        FutureBuilder<NearbySearch>(
          future: _search,
          builder: (context, snapshot) => _results(snapshot),
        ),
      ],
    );
  }

  Widget _results(AsyncSnapshot<NearbySearch> snapshot) {
    if (snapshot.connectionState != ConnectionState.done ||
        snapshot.data?.status == 'cancelled') {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final result = snapshot.data;
    if (result == null || result.status == 'unavailable') {
      return _Message(
        title: 'Location unavailable',
        body: 'Baseline could not read your location. Try again in a moment.',
        action: 'Try again',
        onPressed: _reload,
      );
    }
    if (result.status == 'denied') {
      return _Message(
        title: 'Location is off',
        body: 'Allow location while using Baseline to see courts, coaches, and shops near you.',
        action: 'Open Settings',
        onPressed: openLocationSettings,
      );
    }
    final locality = result.locality;
    if (locality.isNotEmpty && ref.read(sessionProvider).city != locality) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(sessionProvider.notifier).setCity(locality);
        }
      });
    }
    final update = _latestUpdate;
    final live =
        update != null && result.token != 0 && update.token == result.token;
    final places = live ? update.places : result.places;
    final searching = live ? update.searching : result.searching;
    if (places.isEmpty && searching) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            ScaledText(
              'Searching $_placeNoun within $_radiusMiles miles…',
              textAlign: TextAlign.center,
              style: BaselineType.cardMuted,
            ),
          ],
        ),
      );
    }
    if (places.isEmpty) {
      return _Message(
        title: 'Nothing nearby',
        body: widget.chooseRadius
            ? 'No $_placeNoun showed up within $_radiusMiles miles. A wider distance keeps everything from a shorter one.'
            : widget.empty,
        action: 'Search again',
        onPressed: _reload,
      );
    }
    final selected = _selected;
    if (selected != null) {
      return _PlaceDetail(
        kind: widget.kind,
        place: selected,
        onBack: _closePlace,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScaledText(
          widget.chooseRadius
              ? '${places.length} ${places.length == 1 ? 'place' : 'places'} within $_radiusMiles miles. Tap one for details.'
              : 'Tap a place for the full details.',
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: BaselineColors.muted,
          ),
        ),
        if (searching) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ScaledText(
                  'Finding more $_placeNoun farther out…',
                  style: BaselineType.cardMuted,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        for (final place in places) ...[
          LineCard(
            semanticsLabel: [
              place.name,
              if (place.note.isNotEmpty) place.note,
              place.distanceLabel,
            ].join(', '),
            onTap: () => _openPlace(place),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(place.name, style: BaselineType.cardTitle),
                const SizedBox(height: 4),
                if (place.note.isNotEmpty)
                  ScaledText(place.note, style: BaselineType.cardBody),
                if (place.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ScaledText(place.address, style: BaselineType.cardBody),
                ],
                const SizedBox(height: 4),
                ScaledText(place.distanceLabel, style: BaselineType.cardMuted),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _reload() {
    setState(() {
      _selected = null;
      _latestUpdate = null;
      _search = searchNearby(widget.kind, radiusMiles: _searchMiles);
    });
  }

  void _setRadius(int miles) {
    final next = miles.clamp(1, 50).toInt();
    if (next == _radiusMiles) return;
    setState(() {
      _radiusMiles = next;
      _selected = null;
      _latestUpdate = null;
      _search = searchNearby(widget.kind, radiusMiles: next);
    });
  }

  Future<void> _chooseCustomMiles() async {
    final chosen = await showDialog<int>(
      context: context,
      builder: (context) => _MilesDialog(initial: _radiusMiles),
    );
    if (!mounted || chosen == null) return;
    _setRadius(chosen);
  }
}

class _RadiusControl extends StatelessWidget {
  const _RadiusControl({
    required this.miles,
    required this.presets,
    required this.caption,
    required this.onSelected,
    required this.onCustom,
  });

  final int miles;
  final List<int> presets;
  final String caption;
  final ValueChanged<int> onSelected;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final custom = !presets.contains(miles);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScaledText('WITHIN', style: BaselineType.eyebrow),
        const SizedBox(height: 4),
        ScaledText(
          caption,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: BaselineColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in presets)
              _MileChip(
                label: '$preset mi',
                selected: miles == preset,
                onTap: () => onSelected(preset),
              ),
            _MileChip(
              label: custom ? '$miles mi' : 'Other',
              selected: custom,
              onTap: onCustom,
            ),
          ],
        ),
      ],
    );
  }
}

class _MileChip extends StatelessWidget {
  const _MileChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label, search radius',
      child: Material(
        color: selected ? BaselineColors.nightCourt : BaselineColors.card,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? BaselineColors.nightCourt : BaselineColors.mist,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: ScaledText(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: selected ? BaselineColors.line : BaselineColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    required this.body,
    required this.action,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LineCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText(title, style: BaselineType.cardTitle),
          const SizedBox(height: 8),
          ScaledText(body, style: BaselineType.cardBody),
          const SizedBox(height: 12),
          BaselineButton(
            label: action,
            semanticsLabel: action,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _PlaceDetail extends ConsumerWidget {
  const _PlaceDetail({
    required this.kind,
    required this.place,
    required this.onBack,
  });

  final String kind;
  final NearbyPlace place;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(sessionProvider).savedCourtIds.contains(place.id);
    final title = switch (kind) {
      'coaches' => 'Coach',
      'stores' => 'Store',
      _ => 'Court',
    };
    final area = [
      place.neighborhood,
      place.city,
      place.region,
      place.postalCode,
    ].where((part) => part.isNotEmpty).join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: BaselineColors.ink),
          label: const ScaledText(
            'Back',
            style: TextStyle(
              color: BaselineColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: BaselineColors.ink,
            minimumSize: const Size(kMinTapTarget, kMinTapTarget),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
          ),
        ),
        ScaledText(title.toUpperCase(), style: BaselineType.eyebrow),
        const SizedBox(height: 4),
        ScaledText(
          place.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        LineCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Distance', place.distanceLabel),
              if (place.address.isNotEmpty)
                _detailRow('Address', place.address),
              if (area.isNotEmpty && area != place.address)
                _detailRow('Area', area),
              if (place.phone.isNotEmpty) _detailRow('Phone', place.phone),
              if (place.url.isNotEmpty) _detailRow('Website', place.url),
              if (place.note.isNotEmpty) _detailRow('Details', place.note),
              _detailRow(
                'Source',
                place.source == 'OpenStreetMap'
                    ? 'OpenStreetMap, including park and school courts'
                    : 'Apple Maps, based on your current location',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (place.phone.isNotEmpty) ...[
          BaselineButton(
            label: 'Call',
            semanticsLabel: 'Call ${place.name}',
            onPressed: () => openExternal(
              'tel:${place.phone.replaceAll(RegExp(r'[^\d+]'), '')}',
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (place.url.isNotEmpty) ...[
          BaselineButton(
            label: 'Website',
            semanticsLabel: 'Open website for ${place.name}',
            tone: BaselineButtonTone.outline,
            onPressed: () => openExternal(place.url),
          ),
          const SizedBox(height: 8),
        ],
        BaselineButton(
          label: 'Directions',
          semanticsLabel: 'Directions to ${place.name}',
          tone: BaselineButtonTone.outline,
          onPressed: () => openDirections(place),
        ),
        const SizedBox(height: 8),
        BaselineButton(
          label: saved ? 'Saved' : 'Save',
          semanticsLabel: saved ? 'Saved' : 'Save ${place.name}',
          tone: BaselineButtonTone.outline,
          onPressed: () =>
              ref.read(sessionProvider.notifier).toggleSavedCourt(place.id),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText(label.toUpperCase(), style: BaselineType.eyebrow),
          const SizedBox(height: 2),
          ScaledText(value, style: BaselineType.cardBody),
        ],
      ),
    );
  }
}

class _PlayerDetails extends ConsumerWidget {
  const _PlayerDetails({required this.miles});

  final int miles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final level = levelById(session.level);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScaledText('YOUR PLAYER DETAILS', style: BaselineType.eyebrow),
        const SizedBox(height: 8),
        LineCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(
                'Level',
                level == null
                    ? 'Level ${session.level}'
                    : '${level.id} · ${level.name}',
              ),
              _detailRow('Goal', session.goal ?? 'Not set yet'),
              _detailRow(
                'Area',
                session.city.isEmpty
                    ? 'Waiting for your location'
                    : session.city,
              ),
              _detailRow('Training days', '${session.daysPerWeek} a week'),
              _detailRow(
                'Visible to others',
                session.discoverable
                    ? 'Yes. Others see a distance band, not your exact location.'
                    : 'No. Turn on Discoverable to appear.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LineCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScaledText('Other players', style: BaselineType.cardTitle),
              const SizedBox(height: 8),
              ScaledText(
                'No other players within $miles miles. A wider distance includes everyone from a shorter one. When someone nearby turns on discovery, you see their level, goal, area, and a distance band. Their exact location stays hidden.',
                style: BaselineType.cardBody,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText(label.toUpperCase(), style: BaselineType.eyebrow),
          const SizedBox(height: 2),
          ScaledText(value, style: BaselineType.cardBody),
        ],
      ),
    );
  }
}

class _PlayersPane extends StatefulWidget {
  const _PlayersPane({
    required this.adult,
    required this.discoverable,
    required this.onDiscoverable,
  });

  final bool adult;
  final bool discoverable;
  final ValueChanged<bool> onDiscoverable;

  @override
  State<_PlayersPane> createState() => _PlayersPaneState();
}

class _PlayersPaneState extends State<_PlayersPane> {
  static const _presetMiles = [1, 2, 5, 10, 25];
  int _miles = 5;

  @override
  Widget build(BuildContext context) {
    if (!widget.adult) {
      return const LineCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaledText(
              'Player discovery is off',
              style: BaselineType.cardTitle,
            ),
            SizedBox(height: 8),
            ScaledText(
              'Discovery stays off until you are 18. You can still learn, train, and look up courts, coaches, and stores. Other players are hidden, and you cannot appear in search.',
              style: BaselineType.cardBody,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RadiusControl(
          miles: _miles,
          presets: _presetMiles,
          caption: 'A wider distance includes every player from a shorter one. Players show a distance band, not an exact location.',
          onSelected: (miles) =>
              setState(() => _miles = miles.clamp(1, 50).toInt()),
          onCustom: _chooseCustomMiles,
        ),
        const SizedBox(height: 12),
        LineCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScaledText(
                'Distance is a band, not a precise location.',
                style: BaselineType.cardBody,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const ScaledText(
                  'Discoverable',
                  style: BaselineType.cardTitle,
                ),
                subtitle: ScaledText(
                  widget.discoverable
                      ? 'Players see your city and a distance band, such as within $_miles miles.'
                      : 'You are hidden. Turn this on to appear with a coarse area, not a pin on your home.',
                  style: BaselineType.cardMuted,
                ),
                value: widget.discoverable,
                onChanged: widget.onDiscoverable,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PlayerDetails(miles: _miles),
      ],
    );
  }

  Future<void> _chooseCustomMiles() async {
    final chosen = await showDialog<int>(
      context: context,
      builder: (context) => _MilesDialog(initial: _miles),
    );
    if (!mounted || chosen == null) return;
    setState(() => _miles = chosen.clamp(1, 50).toInt());
  }
}

class _MilesDialog extends StatefulWidget {
  const _MilesDialog({required this.initial});

  final int initial;

  @override
  State<_MilesDialog> createState() => _MilesDialogState();
}

class _MilesDialogState extends State<_MilesDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.initial}',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BaselineColors.line,
      title: const ScaledText(
        'Distance in miles',
        style: BaselineType.cardTitle,
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Miles',
          hintText: '1 to 50',
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(kMinTapTarget, kMinTapTarget),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const ScaledText(
            'Cancel',
            style: TextStyle(color: BaselineColors.ink),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(kMinTapTarget, kMinTapTarget),
          ),
          onPressed: () =>
              Navigator.of(context).pop(int.tryParse(_controller.text.trim())),
          child: const ScaledText(
            'Use this distance',
            style: TextStyle(color: BaselineColors.fairway),
          ),
        ),
      ],
    );
  }
}
