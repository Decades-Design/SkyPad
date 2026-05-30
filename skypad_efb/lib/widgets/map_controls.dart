import 'package:flutter/material.dart';

import '../theme/skypad_theme.dart';

enum MapOrientation { northUp, trackUp }

class MapControls extends StatelessWidget {
  const MapControls({
    super.key,
    required this.orientation,
    required this.isCentered,
    required this.gpsAvailable,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onOrientationToggle,
    required this.onRecenter,
    required this.onLayersTap,
  });

  final MapOrientation orientation;
  final bool isCentered;
  final bool gpsAvailable;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onOrientationToggle;
  final VoidCallback onRecenter;
  final VoidCallback onLayersTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Recenter — visible only when the camera is unlocked and GPS is available
        AnimatedOpacity(
          opacity: (isCentered || !gpsAvailable) ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: isCentered || !gpsAvailable,
            child: _ControlButton(
              onTap: onRecenter,
              child: Icon(
                Icons.my_location,
                color: SkypadColors.accent,
                size: SkypadSizes.iconS,
              ),
            ),
          ),
        ),
        const SizedBox(height: SkypadSizes.spaceS),
        _ControlButton(
          onTap: onZoomIn,
          child: Icon(Icons.add, color: SkypadColors.textPrimary, size: SkypadSizes.iconS),
        ),
        _ControlButton(
          onTap: onZoomOut,
          child: Icon(Icons.remove, color: SkypadColors.textPrimary, size: SkypadSizes.iconS),
        ),
        const SizedBox(height: SkypadSizes.spaceS),
        _ControlButton(
          onTap: onOrientationToggle,
          child: Icon(
            orientation == MapOrientation.northUp
                ? Icons.navigation_outlined
                : Icons.navigation,
            color: orientation == MapOrientation.trackUp
                ? SkypadColors.accent
                : SkypadColors.textPrimary,
            size: SkypadSizes.iconL,
          ),
        ),
        const SizedBox(height: SkypadSizes.spaceS),
        _ControlButton(
          onTap: onLayersTap,
          child: Icon(
            Icons.layers_outlined,
            color: SkypadColors.textPrimary,
            size: SkypadSizes.iconS,
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: SkypadSizes.controlButton,
        height: SkypadSizes.controlButton,
        decoration: BoxDecoration(
          color: SkypadColors.surfaceOverlay,
          borderRadius: BorderRadius.circular(SkypadSizes.controlRadius),
          border: Border.all(color: SkypadColors.borderHairline),
        ),
        child: Center(child: child),
      ),
    );
  }
}
