import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

const _locationSettings = LocationSettings(
  accuracy: LocationAccuracy.bestForNavigation,
  distanceFilter: 10,
);

final locationProvider = StreamProvider<Position?>((ref) {
  final controller = StreamController<Position?>();
  StreamSubscription<Position>? positionSub;
  Timer? timer;
  bool lastKnownEnabled = false;
  bool disposed = false;

  void emit(Position? v) {
    if (!controller.isClosed) controller.add(v);
  }

  Future<void> startPositionStream() async {
    if (disposed) return;
    await positionSub?.cancel();
    positionSub = null;
    if (disposed) return;

    // Emit last known position immediately to reduce perceived startup latency
    // and to give a fast position after stream restarts
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (!disposed && lastKnown != null) emit(lastKnown);
    } catch (_) {}
    if (disposed) return;

    positionSub = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen(
      emit,
      onError: (_) => emit(null),
      onDone: () => positionSub = null,
      cancelOnError: false,
    );
  }

  Future<void> stopPositionStream() async {
    await positionSub?.cancel();
    positionSub = null;
    emit(null);
  }

  // Polls the real GPS setting — immune to spurious events from Android's
  // PROVIDERS_CHANGED broadcast or geolocator's foreground-service lifecycle
  Future<void> checkServiceState() async {
    if (disposed) return;
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (disposed) return;

    if (enabled && !lastKnownEnabled) {
      lastKnownEnabled = true;
      await startPositionStream();
    } else if (!enabled && lastKnownEnabled) {
      lastKnownEnabled = false;
      await stopPositionStream();
    } else if (enabled && positionSub == null) {
      // Stream died while GPS is still on (error/done) — restart it
      await startPositionStream();
    }
  }

  timer = Timer.periodic(const Duration(seconds: 2), (_) => checkServiceState());

  Future<void> initialize() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (disposed) return;

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      emit(null);
      return;
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (disposed) return;

    lastKnownEnabled = enabled;
    if (enabled) {
      await startPositionStream();
    } else {
      emit(null);
    }
  }

  initialize();

  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    positionSub?.cancel();
    controller.close();
  });

  return controller.stream;
});
