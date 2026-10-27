import 'dart:async';

import 'package:geolocator/geolocator.dart';

class TrackingSnapshot {
  const TrackingSnapshot({
    required this.lat,
    required this.lng,
    required this.speedMps,
    required this.accuracyM,
    required this.at,
    required this.fixCount,
    required this.maxGap,
  });

  final double lat;
  final double lng;
  final double speedMps;
  final double accuracyM;
  final DateTime at;
  final int fixCount;

  /// Massimo intervallo tra due fix consecutivi dall'avvio.
  final Duration maxGap;
}

class TrackingService {
  StreamSubscription<Position>? _subscription;
  StreamController<TrackingSnapshot>? _controller;

  /// Avvia il GPS in background (impostazioni dalla spec: automotive,
  /// niente pausa automatica). Se è già avviato restituisce lo stesso stream.
  Stream<TrackingSnapshot> start() {
    final existing = _controller;
    if (existing != null) return existing.stream;

    final controller = StreamController<TrackingSnapshot>.broadcast();
    _controller = controller;

    var fixCount = 0;
    DateTime? previous;
    var maxGap = Duration.zero;

    final settings = AppleSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      activityType: ActivityType.automotiveNavigation,
      pauseLocationUpdatesAutomatically: false,
      allowBackgroundLocationUpdates: true,
      showBackgroundLocationIndicator: true,
    );

    _subscription =
        Geolocator.getPositionStream(locationSettings: settings).listen(
      (position) {
        fixCount++;
        final at = position.timestamp;
        final before = previous;
        if (before != null) {
          final gap = at.difference(before);
          if (gap > maxGap) maxGap = gap;
        }
        previous = at;
        controller.add(TrackingSnapshot(
          lat: position.latitude,
          lng: position.longitude,
          speedMps: position.speed,
          accuracyM: position.accuracy,
          at: at,
          fixCount: fixCount,
          maxGap: maxGap,
        ));
      },
      onError: controller.addError,
    );
    return controller.stream;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _controller?.close();
    _controller = null;
  }
}
