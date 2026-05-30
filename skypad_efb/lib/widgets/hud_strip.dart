import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../theme/skypad_theme.dart';

class HudStrip extends StatelessWidget {
  const HudStrip({super.key, required this.position});

  final Position position;

  @override
  Widget build(BuildContext context) {
    final groundSpeedKt = (position.speed * 1.94384).clamp(0, 9999).toInt();
    final trackDeg = position.heading.toInt();
    final altitudeFt = (position.altitude * 3.28084).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SkypadSizes.spaceXl),
      padding: const EdgeInsets.symmetric(
        horizontal: SkypadSizes.spaceL,
        vertical: SkypadSizes.spaceL,
      ),
      decoration: BoxDecoration(
        color: SkypadColors.surfaceOverlay,
        borderRadius: BorderRadius.circular(SkypadSizes.hudRadius),
        border: Border.all(color: SkypadColors.borderHairline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _HudField(label: 'GS',  value: '$groundSpeedKt', unit: 'kt'),
          const _HudDivider(),
          _HudField(
            label: 'TRK',
            value: '${trackDeg.toString().padLeft(3, '0')}°',
            unit: 'mag',
          ),
          const _HudDivider(),
          _HudField(label: 'ALT', value: '$altitudeFt', unit: 'ft'),
        ],
      ),
    );
  }
}

class _HudField extends StatelessWidget {
  const _HudField({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: SkypadTextStyles.hudLabel),
        const SizedBox(height: 2),
        Text(value, style: SkypadTextStyles.hudValue),
        Text(unit,  style: SkypadTextStyles.hudUnit),
      ],
    );
  }
}

class _HudDivider extends StatelessWidget {
  const _HudDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: SkypadSizes.hudDividerHeight,
      color: SkypadColors.borderHairline,
    );
  }
}
