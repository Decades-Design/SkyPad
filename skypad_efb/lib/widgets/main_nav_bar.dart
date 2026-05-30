import 'package:flutter/material.dart';

import '../theme/skypad_theme.dart';

// ── Public widget ─────────────────────────────────────────────────────────────

/// Top navigation bar.
/// Tablet (≥600dp): single row — [menu] [action pill] [search]
/// Phone (<600dp):  two rows  — [menu | flight pill | search] / [action pill]
/// Safe-area handling is delegated to the parent (map_screen's SafeArea).
class MainNavBar extends StatelessWidget {
  const MainNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    return isTablet ? const _TabletLayout() : const _PhoneLayout();
  }
}

// ── Layouts ───────────────────────────────────────────────────────────────────

class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SkypadSizes.spaceXl,
        SkypadSizes.spaceM,
        SkypadSizes.spaceXl,
        SkypadSizes.spaceM,
      ),
      child: const SizedBox(
        height: SkypadSizes.navButton,
        child: Row(
          children: [
            _NavButton(icon: Icons.menu),
            SizedBox(width: SkypadSizes.spaceM),
            Expanded(child: _TabletActionPill()),
            SizedBox(width: SkypadSizes.spaceM),
            _NavButton(icon: Icons.search),
          ],
        ),
      ),
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SkypadSizes.spaceXl,
        SkypadSizes.spaceM,
        SkypadSizes.spaceXl,
        SkypadSizes.spaceM,
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: SkypadSizes.navButton,
            child: Row(
              children: [
                _NavButton(icon: Icons.menu),
                SizedBox(width: SkypadSizes.spaceM),
                Expanded(child: _FlightPlanPill(compact: true)),
                SizedBox(width: SkypadSizes.spaceM),
                _NavButton(icon: Icons.search),
              ],
            ),
          ),
          SizedBox(height: SkypadSizes.spaceM),
          _PhoneActionPill(),
        ],
      ),
    );
  }
}

// ── Action pills ──────────────────────────────────────────────────────────────

class _TabletActionPill extends StatelessWidget {
  const _TabletActionPill();

  @override
  Widget build(BuildContext context) {
    return const _PillContainer(
      child: Row(
        children: [
          SizedBox(width: SkypadSizes.spaceL),
          _PillButton(icon: Icons.arrow_forward),
          SizedBox(width: SkypadSizes.spaceL),
          _PillButton(icon: Icons.radar),
          SizedBox(width: SkypadSizes.spaceL),
          _PillButton(icon: Icons.show_chart),
          SizedBox(width: SkypadSizes.spaceL),
          Expanded(child: _FlightPlanPill(compact: false)),
          SizedBox(width: SkypadSizes.spaceL),
          _PillButton(icon: Icons.gps_fixed),
          SizedBox(width: SkypadSizes.spaceL),
          _PillButton(icon: Icons.warning_amber_rounded, emergency: true),
          SizedBox(width: SkypadSizes.spaceL),
          _PillButton(icon: Icons.tune),
          SizedBox(width: SkypadSizes.spaceL),
        ],
      ),
    );
  }
}

class _PhoneActionPill extends StatelessWidget {
  const _PhoneActionPill();

  @override
  Widget build(BuildContext context) {
    return const _PillContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PillButton(icon: Icons.arrow_forward),
          _PillButton(icon: Icons.radar),
          _PillButton(icon: Icons.show_chart),
          _PillButton(icon: Icons.gps_fixed),
          _PillButton(icon: Icons.warning_amber_rounded, emergency: true),
          _PillButton(icon: Icons.tune),
        ],
      ),
    );
  }
}

class _PillContainer extends StatelessWidget {
  const _PillContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SkypadSizes.navButton,
      decoration: BoxDecoration(
        color: SkypadColors.surfaceOverlay,
        borderRadius: BorderRadius.circular(SkypadSizes.navPillRadius),
        border: Border.all(color: SkypadColors.borderMedium, width: 1),
        boxShadow: SkypadShadows.panel,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SkypadSizes.navPillRadius),
        child: child,
      ),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

/// Standalone circular button — menu and search.
class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SkypadSizes.navButton,
      height: SkypadSizes.navButton,
      decoration: BoxDecoration(
        color: SkypadColors.surfaceButton,
        shape: BoxShape.circle,
        border: Border.all(color: SkypadColors.borderSubtle, width: 1),
        boxShadow: SkypadShadows.panel,
      ),
      child: Center(
        child: Icon(icon, color: SkypadColors.textPrimary, size: SkypadSizes.iconM),
      ),
    );
  }
}

/// Circular button inside the action pill.
class _PillButton extends StatelessWidget {
  const _PillButton({required this.icon, this.emergency = false});

  final IconData icon;
  final bool emergency;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SkypadSizes.navButtonInner,
      height: SkypadSizes.navButtonInner,
      decoration: BoxDecoration(
        color: emergency ? SkypadColors.emergencyBg : SkypadColors.surfaceButton,
        shape: BoxShape.circle,
        border: Border.all(
          color: emergency ? SkypadColors.emergencyBorder : SkypadColors.borderSubtle,
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: emergency ? SkypadColors.emergencyIcon : SkypadColors.textPrimary,
          size: SkypadSizes.iconM,
        ),
      ),
    );
  }
}

// ── Flight plan pill ──────────────────────────────────────────────────────────

/// Flight-plan info pill.
/// [compact: true]  — standalone on phone top row, full navButton height.
/// [compact: false] — nested inside tablet action pill, navButtonInner height.
class _FlightPlanPill extends StatelessWidget {
  const _FlightPlanPill({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    // When standalone (compact) use the full nav height.
    // When nested inside the action pill (not compact) shrink slightly so
    // there is breathing room against the outer pill wall.
    final height = compact
        ? SkypadSizes.navButton
        : SkypadSizes.navButtonInner;
    final radius = height / 2;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: SkypadColors.surfaceFlight,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SkypadColors.borderMedium, width: 1),
        boxShadow: SkypadShadows.panel,
      ),
      child: Center(
        child: compact ? const _PillCompact() : const _PillFull(),
      ),
    );
  }
}

// ── Pill content ──────────────────────────────────────────────────────────────

/// Single-line — phone top row: EGKB → EGTB  |  00:32 ETE
class _PillCompact extends StatelessWidget {
  const _PillCompact();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('EGKB', style: SkypadTextStyles.icaoOriginCompact),
        const SizedBox(width: SkypadSizes.spaceS),
        const Icon(Icons.arrow_forward, color: SkypadColors.accent, size: 12),
        const SizedBox(width: SkypadSizes.spaceS),
        const Text('EGTB', style: SkypadTextStyles.icaoDestinationCompact),
        const SizedBox(width: SkypadSizes.spaceXl),
        Container(
          width: 1,
          height: 20,
          color: SkypadColors.borderHairline,
        ),
        const SizedBox(width: SkypadSizes.spaceXl),
        const Text('00:32', style: SkypadTextStyles.flightValueCompact),
        const SizedBox(width: SkypadSizes.spaceXs),
        const Text('ETE', style: SkypadTextStyles.flightUnitCompact),
      ],
    );
  }
}

/// Two-line — tablet inside action pill: EGKB → EGTB / 00:32 ETE · 10:49Z ETA · 64 NM
class _PillFull extends StatelessWidget {
  const _PillFull();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Line 1: EGKB → EGTB
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('EGKB', style: SkypadTextStyles.icaoOrigin),
            SizedBox(width: SkypadSizes.spaceM),
            Icon(Icons.arrow_forward, color: SkypadColors.accent, size: 13),
            SizedBox(width: SkypadSizes.spaceM),
            Text('EGTB', style: SkypadTextStyles.icaoDestination),
          ],
        ),
        const SizedBox(height: 3),
        // Line 2: 00:32 ETE · 10:49Z ETA · 64 NM
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('00:32',  style: SkypadTextStyles.flightValue),
            SizedBox(width: 3),
            Text('ETE',    style: SkypadTextStyles.flightUnit),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SkypadSizes.spaceXs + 1),
              child: Text('·', style: SkypadTextStyles.flightDot),
            ),
            Text('10:49Z', style: SkypadTextStyles.flightValue),
            SizedBox(width: 3),
            Text('ETA',    style: SkypadTextStyles.flightUnit),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SkypadSizes.spaceXs + 1),
              child: Text('·', style: SkypadTextStyles.flightDot),
            ),
            Text('64 NM',  style: SkypadTextStyles.flightValue),
          ],
        ),
      ],
    );
  }
}
