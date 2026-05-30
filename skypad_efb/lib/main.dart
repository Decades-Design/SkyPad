import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'config/secrets.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock portrait only on phones (shortest side < 600dp); tablets can rotate freely
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
  if (shortestSide < 600) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  MapboxOptions.setAccessToken(mapboxApiKey);
  runApp(
    const ProviderScope(
      child: EFBApp(),
    ),
  );
}

class EFBApp extends StatelessWidget {
  const EFBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EFB',
      theme: ThemeData.dark(),
      home: const MapScreen(),
    );
  }
}
