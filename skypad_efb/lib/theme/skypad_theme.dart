import 'package:flutter/material.dart';

// ┌─────────────────────────────────────────────────────────────────────────┐
// │  SkyPad Design System                                                   │
// │                                                                         │
// │  Single source of truth for all visual tokens.                          │
// │  Import this file anywhere a color, size, shadow, or text style        │
// │  is needed — never hard-code values in widget files.                   │
// │                                                                         │
// │  Classes:                                                               │
// │    SkypadColors      — palette                                          │
// │    SkypadSizes       — dimensions & spacing                             │
// │    SkypadShadows     — reusable BoxShadow lists                         │
// │    SkypadTextStyles  — reusable TextStyle constants                     │
// └─────────────────────────────────────────────────────────────────────────┘

// ── Colors ────────────────────────────────────────────────────────────────────

abstract final class SkypadColors {
  // ── Accent ──────────────────────────────────────────────────────────────────

  /// Primary accent — active states, highlights, flight-plan destination.
  static const Color accent = Color(0xFF4D7FFF);

  // ── Surfaces ────────────────────────────────────────────────────────────────

  /// Opaque dark surface for standalone nav buttons.
  static const Color surfaceButton = Color(0xFF0F0F1E);

  /// 70 % black overlay — pill containers, HUD strip, map-controls panel.
  /// Equivalent to Colors.black.withValues(alpha: 0.7).
  static const Color surfaceOverlay = Color(0xB3000000);

  /// Slightly darker surface for the flight-plan inner pill.
  static const Color surfaceFlight = Color(0xFF0D0D1C);

  // ── Emergency ───────────────────────────────────────────────────────────────

  static const Color emergencyBg     = Color(0xFF5C1010);
  static const Color emergencyBorder = Color(0x55FF2828);
  static const Color emergencyIcon   = Color(0xFFFF7070);

  // ── Borders ─────────────────────────────────────────────────────────────────

  /// Subtle border on standalone buttons — ≈ 16 % white.
  static const Color borderSubtle = Color(0x2AFFFFFF);

  /// Medium border on pill containers — ≈ 27 % white.
  static const Color borderMedium = Color(0x44FFFFFF);

  /// Hairline divider — 12 % white (identical to Colors.white12).
  static const Color borderHairline = Colors.white12;

  // ── Text ────────────────────────────────────────────────────────────────────

  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Colors.white54; // labels, units
  static const Color textTertiary  = Colors.white38; // secondary units
  static const Color textDim       = Colors.white30; // separators / dots
}

// ── Sizes ─────────────────────────────────────────────────────────────────────

abstract final class SkypadSizes {
  // ── Nav bar ─────────────────────────────────────────────────────────────────

  /// Standalone nav buttons (menu, search).
  static const double navButton = 70.0;

  /// Buttons nested inside the action pill.
  static const double navButtonInner = 55.0;

  /// Pill end-cap radius — always navButton / 2 for a true pill shape.
  static const double navPillRadius = navButton / 2; // 35.0

  // ── Map controls ────────────────────────────────────────────────────────────

  /// Side-panel control buttons (zoom, orientation, layers).
  static const double controlButton = 44.0;

  /// Border-radius for control buttons and the HUD strip.
  static const double controlRadius = 8.0;

  // ── HUD strip ───────────────────────────────────────────────────────────────

  static const double hudRadius        = 12.0;
  static const double hudDividerHeight = 40.0;

  // ── Spacing ─────────────────────────────────────────────────────────────────

  static const double spaceXs = 4.0;
  static const double spaceS  = 6.0;
  static const double spaceM  = 8.0;
  static const double spaceL  = 10.0;
  static const double spaceXl = 12.0;

  // ── Icon sizes ───────────────────────────────────────────────────────────────

  /// Small icons — map-control panel buttons.
  static const double iconS = 16.0;

  /// Medium icons — nav-bar buttons.
  static const double iconM = 20.0;

  /// Large icon — map-control orientation button.
  static const double iconL = 22.0;
}

// ── Shadows ───────────────────────────────────────────────────────────────────

abstract final class SkypadShadows {
  /// Standard drop shadow used on nav buttons, pills, and panels.
  static const List<BoxShadow> panel = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}

// ── Text styles ───────────────────────────────────────────────────────────────

abstract final class SkypadTextStyles {
  // ── HUD strip ───────────────────────────────────────────────────────────────

  /// Field label (GS, TRK, ALT).
  static const TextStyle hudLabel = TextStyle(
    color: Colors.white54,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  /// Instrument readout value.
  static const TextStyle hudValue = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Unit suffix (kt, ft, mag).
  static const TextStyle hudUnit = TextStyle(
    color: Colors.white38,
    fontSize: 10,
    letterSpacing: 0.8,
  );

  // ── Flight-plan pill — full (tablet, nested inside action pill) ──────────────

  /// Origin ICAO code — white.
  static const TextStyle icaoOrigin = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  /// Destination ICAO code — accent blue.
  static const TextStyle icaoDestination = TextStyle(
    color: Color(0xFF4D7FFF), // SkypadColors.accent
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  /// Data value on the sub-line (00:32, 10:49Z, 64).
  static const TextStyle flightValue = TextStyle(
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Unit label on the sub-line (ETE, ETA, NM).
  static const TextStyle flightUnit = TextStyle(
    color: Colors.white54,
    fontSize: 10,
  );

  /// Separator dot between sub-line fields.
  static const TextStyle flightDot = TextStyle(
    color: Colors.white30,
    fontSize: 11,
  );

  // ── Flight-plan pill — compact (phone, standalone top row) ──────────────────

  /// Origin ICAO — compact (14 px).
  static const TextStyle icaoOriginCompact = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  /// Destination ICAO — compact, accent blue.
  static const TextStyle icaoDestinationCompact = TextStyle(
    color: Color(0xFF4D7FFF), // SkypadColors.accent
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  /// ETE value in compact pill.
  static const TextStyle flightValueCompact = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// ETE unit label in compact pill.
  static const TextStyle flightUnitCompact = TextStyle(
    color: Colors.white54,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
