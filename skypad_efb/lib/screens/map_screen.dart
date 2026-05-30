import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../providers/location_provider.dart';
import '../providers/map_layer_provider.dart';
import '../widgets/hud_strip.dart';
import '../widgets/main_nav_bar.dart';
import '../widgets/map_controls.dart';

// How long to show the greyed-out last-known puck before hiding it entirely
const _stalePuckDuration = Duration(minutes: 4);
// Mapbox style-image key for the stale puck icon
const _stalePuckImageId = 'stale-location-puck';
// Pixel dimensions of the generated stale puck image
const _stalePuckSize = 35;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapboxMap? _mapboxMap;
  bool _initialPositionSet = false;
  bool _puckEnabled = false;
  MapOrientation _orientation = MapOrientation.northUp;
  bool _isCentered = true;
  bool _gpsBannerDismissed = false;

  // Last known position — used to place the stale puck when GPS is lost
  geo.Position? _lastKnownPosition;

  // Stale puck state
  Uint8List? _stalePuckImage;
  PointAnnotationManager? _staleAnnotationManager;
  PointAnnotation? _staleAnnotation;
  Timer? _staleTimer;

  @override
  void dispose() {
    _staleTimer?.cancel();
    super.dispose();
  }

  // ── Stale puck ────────────────────────────────────────────────────────────

  static Future<Uint8List> _buildStalePuckImage() async {
    final size = _stalePuckSize.toDouble();
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - 4;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Drop shadow
    canvas.drawCircle(
      center + const Offset(0, 1.5),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    
    // White ring
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    // Grey fill
    canvas.drawCircle(center, radius * 0.75, Paint()..color = const Color(0xFFBDBDBD));
    // Darker inner dot
    canvas.drawCircle(center, radius * 0.55, Paint()..color = const Color(0xFF757575));

    final picture = recorder.endRecording();
    final img = await picture.toImage(_stalePuckSize, _stalePuckSize);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _registerStalePuckImage() async {
    if (_mapboxMap == null || _stalePuckImage == null) return;
    try {
      await _mapboxMap!.style.addStyleImage(
        _stalePuckImageId,
        1.0,
        MbxImage(width: _stalePuckSize, height: _stalePuckSize, data: _stalePuckImage!),
        false, [], [], null,
      );
    } catch (_) {
      // Silently ignore — image may already be registered
    }
  }

  Future<void> _showStalePuck() async {
    if (_mapboxMap == null || _lastKnownPosition == null) return;
    await _clearStalePuck(restartTimer: false);

    _staleAnnotationManager ??=
        await _mapboxMap!.annotations.createPointAnnotationManager();

    _staleAnnotation = await _staleAnnotationManager!.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            _lastKnownPosition!.longitude,
            _lastKnownPosition!.latitude,
          ),
        ),
        iconImage: _stalePuckImageId,
        iconSize: 0.75,
      ),
    );

    _staleTimer?.cancel();
    _staleTimer = Timer(_stalePuckDuration, _clearStalePuck);
  }

  Future<void> _clearStalePuck({bool restartTimer = true}) async {
    if (restartTimer) {
      _staleTimer?.cancel();
      _staleTimer = null;
    }
    if (_staleAnnotation != null && _staleAnnotationManager != null) {
      try {
        await _staleAnnotationManager!.delete(_staleAnnotation!);
      } catch (_) {}
      _staleAnnotation = null;
    }
  }

  // ── Map interaction ───────────────────────────────────────────────────────

  Future<void> _zoomIn() async {
    final camera = await _mapboxMap?.getCameraState();
    if (camera == null) return;
    await _mapboxMap!.flyTo(
      CameraOptions(zoom: camera.zoom + 1),
      MapAnimationOptions(duration: 400),
    );
  }

  Future<void> _zoomOut() async {
    final camera = await _mapboxMap?.getCameraState();
    if (camera == null) return;
    await _mapboxMap!.flyTo(
      CameraOptions(zoom: camera.zoom - 1),
      MapAnimationOptions(duration: 400),
    );
  }

  Future<void> _toggleOrientation() async {
    if (_mapboxMap == null) return;
    setState(() {
      _orientation = _orientation == MapOrientation.northUp
          ? MapOrientation.trackUp
          : MapOrientation.northUp;
    });
    final bearing = _orientation == MapOrientation.trackUp
        ? (ref.read(locationProvider).asData?.value?.heading ?? 0)
        : 0.0;
    await _mapboxMap!.flyTo(
      CameraOptions(bearing: bearing),
      MapAnimationOptions(duration: 400),
    );
  }

  Future<void> _recenter() async {
    if (_mapboxMap == null) return;
    final position = ref.read(locationProvider).asData?.value;
    if (position == null) return;
    setState(() => _isCentered = true);
    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(position.longitude, position.latitude)),
      ),
      MapAnimationOptions(duration: 400),
    );
  }

  void _onMapScrolled(MapContentGestureContext context) {
    if (_isCentered) setState(() => _isCentered = false);
  }

  // ── Map lifecycle ─────────────────────────────────────────────────────────

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await mapboxMap.setCamera(CameraOptions(
      center: Point(coordinates: Position(9.2765, 45.45)),
      zoom: 4.0,
    ));

    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    await mapboxMap.attribution.updateSettings(AttributionSettings(enabled: true));

    // Build the stale puck image once; re-register it whenever the style loads
    _stalePuckImage ??= await _buildStalePuckImage();
    await _registerStalePuckImage();
    _staleAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    // Sync puck with GPS state that may already be resolved by the time the map loads
    final currentPosition = ref.read(locationProvider).asData?.value;
    _puckEnabled = currentPosition != null;
    if (currentPosition != null) _lastKnownPosition = currentPosition;

    await mapboxMap.location.updateSettings(_puckSettings(enabled: _puckEnabled));

    if (currentPosition != null && !_initialPositionSet) {
      _initialPositionSet = true;
      if (mounted) setState(() => _isCentered = true);
      await mapboxMap.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(currentPosition.longitude, currentPosition.latitude),
          ),
          zoom: 11.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }
  }

  /// Re-registers the stale puck image after a style reload (e.g. base-map change).
  Future<void> _onStyleLoaded(StyleLoadedEventData _) async {
    await _registerStalePuckImage();
  }

  // ── Location updates ──────────────────────────────────────────────────────

  void _onLocationChanged(
    AsyncValue<geo.Position?>? previous,
    AsyncValue<geo.Position?> next,
  ) {
    next.whenData((position) async {
      if (_mapboxMap == null) return;

      // ── GPS lost ──────────────────────────────────────────────────────────
      if (position == null) {
        if (_puckEnabled) {
          _puckEnabled = false;
          await _mapboxMap!.location.updateSettings(_puckSettings(enabled: false));
        }
        // Re-show the banner for every new GPS outage
        if (mounted && _gpsBannerDismissed) {
          setState(() => _gpsBannerDismissed = false);
        }
        // Show grey puck at last known position for up to 4 minutes
        await _showStalePuck();
        return;
      }

      // ── GPS available ─────────────────────────────────────────────────────
      _lastKnownPosition = position;
      await _clearStalePuck();

      if (!_puckEnabled) {
        _puckEnabled = true;
        await _mapboxMap!.location.updateSettings(_puckSettings(enabled: true));
      }

      // First fix — fly in and lock camera
      if (!_initialPositionSet) {
        _initialPositionSet = true;
        if (mounted) setState(() => _isCentered = true);
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            zoom: 11.0,
          ),
          MapAnimationOptions(duration: 1000),
        );
        return;
      }

      // GPS restored mid-session — always recenter
      final prevPosition = previous?.asData?.value;
      if (prevPosition == null) {
        if (mounted) setState(() => _isCentered = true);
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
          ),
          MapAnimationOptions(duration: 800),
        );
        return;
      }

      // Normal update — bearing and camera follow
      if (_orientation == MapOrientation.trackUp) {
        await _mapboxMap!.setCamera(CameraOptions(bearing: position.heading));
      }
      if (_isCentered) {
        await _mapboxMap!.setCamera(CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
        ));
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static LocationComponentSettings _puckSettings({required bool enabled}) =>
      LocationComponentSettings(
        enabled: enabled,
        puckBearing: PuckBearing.HEADING,
        pulsingEnabled: false,
      );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final styleUri = ref.watch(baseMapLayerProvider).styleUri;
    ref.listen(locationProvider, _onLocationChanged);

    final locationState = ref.watch(locationProvider);
    final position = locationState.asData?.value;
    final gpsUnavailable = locationState.asData != null && position == null;

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            styleUri: styleUri,
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoaded,
            onScrollListener: _onMapScrolled,
          ),
          SafeArea(
            child: Stack(
              children: [
                // Nav bar + GPS banner stacked at the top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MainNavBar(),
                      if (gpsUnavailable && !_gpsBannerDismissed)
                        _GpsBanner(
                          onDismiss: () =>
                              setState(() => _gpsBannerDismissed = true),
                        ),
                    ],
                  ),
                ),
                if (position != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 25,
                    child: HudStrip(position: position),
                  ),
                Positioned(
                  right: 16,
                  bottom: 0,
                  top: 0,
                  child: Center(
                    child: MapControls(
                      orientation: _orientation,
                      isCentered: _isCentered,
                      gpsAvailable: position != null,
                      onZoomIn: _zoomIn,
                      onZoomOut: _zoomOut,
                      onOrientationToggle: _toggleOrientation,
                      onRecenter: _recenter,
                      onLayersTap: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _GpsBanner extends StatelessWidget {
  const _GpsBanner({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.gps_off, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'GPS unavailable — check location services',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
