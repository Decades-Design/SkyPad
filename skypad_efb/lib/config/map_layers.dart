import 'secrets.dart';

enum BaseMapLayer {
  skypad,
  satellite;

  String get styleUri {
    switch (this) {
      case BaseMapLayer.skypad:
        return mapboxStyleUrl;
      case BaseMapLayer.satellite:
        return 'mapbox://styles/mapbox/satellite-streets-v12';
    }
  }

  String get label {
    switch (this) {
      case BaseMapLayer.skypad:
        return 'SkyPad';
      case BaseMapLayer.satellite:
        return 'Satellite';
    }
  }
}
