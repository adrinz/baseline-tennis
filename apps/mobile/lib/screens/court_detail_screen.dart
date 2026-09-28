import 'package:baseline/data/nearby_places.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CourtDetailScreen extends ConsumerWidget {
  const CourtDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final place =
        NearbyDirectory.instance.find(id) ??
        NearbyDirectory.instance.find(Uri.decodeComponent(id));
    final session = ref.watch(sessionProvider);
    if (place == null) {
      return Scaffold(
        appBar: AppBar(title: const ScaledText('Place')),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: ScaledText(
            'Open Discover again to load places near you.',
            style: BaselineType.cardBody,
          ),
        ),
      );
    }
    final saved = session.savedCourtIds.contains(place.id);
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Place')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ScaledText(
            place.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          if (place.address.isNotEmpty)
            ScaledText(
              place.address,
              style: const TextStyle(color: BaselineColors.ink, height: 1.4),
            ),
          const SizedBox(height: 8),
          ScaledText(place.distanceLabel, style: BaselineType.cardMuted),
          const SizedBox(height: 16),
          LineCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScaledText('APPLE MAPS', style: BaselineType.eyebrow),
                const SizedBox(height: 8),
                const ScaledText(
                  'This listing comes from Maps around your current location.',
                  style: BaselineType.cardBody,
                ),
                if (place.phone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ScaledText(place.phone, style: BaselineType.cardBody),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          BaselineButton(
            label: saved ? 'Saved' : 'Save place',
            semanticsLabel: saved ? 'Place saved' : 'Save place',
            onPressed: () =>
                ref.read(sessionProvider.notifier).toggleSavedCourt(place.id),
          ),
          const SizedBox(height: 12),
          BaselineButton(
            label: 'Directions',
            semanticsLabel: 'Directions in Apple Maps',
            tone: BaselineButtonTone.outline,
            onPressed: () => openDirections(place),
          ),
        ],
      ),
    );
  }
}
