import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary - Jet Black ──────────────────────────
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color primaryPressed = Color(0xFF334155); // Slate 700

  // ── Accent - Vibrant Orange ──────────────────────
  static const Color accent = Color(0xFFF97316); // Orange 500
  static const Color accentLight = Color(0xFFFFF7ED); // Orange 50
  static const Color accentDark = Color(0xFFEA580C); // Orange 600

  // ── Background & Surface ─────────────────────────
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color surfaceDim = Color(0xFFF1F5F9); // Slate 100
  static const Color card = Colors.white;

  // ── Text ──────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textHint = Color(0xFF94A3B8); // Slate 400

  // ── Status (Semantic) ─────────────────────────────
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFFECFDF5); // Emerald 50
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFFEF2F2); // Red 50
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFFFBEB); // Amber 50
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // ── Border & Divider ──────────────────────────────
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // ── Shimmer ───────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE2E8F0); // Slate 200
  static const Color shimmerHighlight = Color(0xFFF8FAFC); // Slate 50
}
