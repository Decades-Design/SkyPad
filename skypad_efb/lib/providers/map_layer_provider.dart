import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/map_layers.dart';

class BaseMapLayerNotifier extends Notifier<BaseMapLayer> {
  @override
  BaseMapLayer build() => BaseMapLayer.skypad;

  void setLayer(BaseMapLayer layer) => state = layer;
}

final baseMapLayerProvider = NotifierProvider<BaseMapLayerNotifier, BaseMapLayer>(
  BaseMapLayerNotifier.new,
);
