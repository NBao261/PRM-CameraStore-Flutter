/// Centralized spacing, sizing and radius constants.
///
/// Using these instead of hard-coded numbers keeps the UI consistent
/// and makes global spacing changes trivial.
class AppSizes {
  AppSizes._();

  // ── Spacing ────────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // ── Border Radius ──────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 100;

  // ── Icon Sizes ─────────────────────────────────────────
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // ── Font Sizes ─────────────────────────────────────────
  static const double fontXs = 10;
  static const double fontSm = 12;
  static const double fontMd = 14;
  static const double fontLg = 16;
  static const double fontXl = 20;
  static const double fontXxl = 24;
  static const double fontDisplay = 28;

  // ── Component Heights ──────────────────────────────────
  static const double buttonHeight = 48;
  static const double inputHeight = 56;
  static const double appBarHeight = 56;
  static const double bottomNavHeight = 56;

  // ── Avatar Sizes ───────────────────────────────────────
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;
}
