// lib/app/shared/widgets/simpul_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color kForest    = Color(0xFF2D5A4E);
const Color kForestMid = Color(0xFF3D6B5F);
const Color kGold      = Color(0xFFC8A96A);
const Color kBg        = Color(0xFFF5F6F5);
const Color kSurface   = Colors.white;
const Color kBorder    = Color(0xFFEEEEEE);
const Color kSubtext   = Color(0xFF6B7280);
const Color kFog       = Color(0xFFEBF2F0);
const Color kMist      = Color(0xFFB8CFC9);
const Color kInk       = Color(0xFF111827);
const Color kGoldLight = Color(0xFFF7F3EB);
const Color kLavender  = Color(0xFFF0EEF8);
const Color kLavDark   = Color(0xFF6B5EA8);

// ── Logo ──────────────────────────────────────────────────────────────────────

class SimpulLogo extends StatelessWidget {
  const SimpulLogo({super.key, this.fontSize = 24});
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Simpul',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: kForest,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(
              fontSize: fontSize + 2,
              color: kGold,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ── AppBar untuk Scaffold biasa ───────────────────────────────────────────────
//
// Parameter [leading] opsional — jika diisi, tampil di kiri (misal tombol back).
// Default [automaticallyImplyLeading] = false agar tab utama tidak munculkan back.

class SimpulAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SimpulAppBar({
    super.key,
    this.leading,
    this.actions,
    this.bottom,
    this.elevation = 0,
    this.backgroundColor,
    this.automaticallyImplyLeading = false,
  });

  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double elevation;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? kBg,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      centerTitle: true,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: const SimpulLogo(),
      actions: actions,
      bottom: bottom,
    );
  }
}

// ── SliverAppBar untuk CustomScrollView ──────────────────────────────────────

class SliverSimpulAppBar extends StatelessWidget {
  const SliverSimpulAppBar({super.key, this.actions});
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: kBg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      floating: true,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const SimpulLogo(),
      actions: actions,
    );
  }
}