import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Utility to trigger a "fly to cart" overlay animation.
///
/// Usage:
///   FlyToCartAnimation.trigger(
///     context: context,
///     startGlobalKey: myButtonKey,   // GlobalKey on the button/widget
///     targetGlobalKey: cartIconKey,  // GlobalKey on the cart icon
///   );
class FlyToCartAnimation {
  FlyToCartAnimation._();

  static void trigger({
    required BuildContext context,
    required GlobalKey startGlobalKey,
    required GlobalKey targetGlobalKey,
  }) {
    final overlay = Overlay.of(context);

    // Get positions
    final startBox =
        startGlobalKey.currentContext?.findRenderObject() as RenderBox?;
    final targetBox =
        targetGlobalKey.currentContext?.findRenderObject() as RenderBox?;

    if (startBox == null || targetBox == null) return;

    final startPos = startBox.localToGlobal(
      Offset(startBox.size.width / 2, startBox.size.height / 2),
    );
    final targetPos = targetBox.localToGlobal(
      Offset(targetBox.size.width / 2, targetBox.size.height / 2),
    );

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FlyingDot(
        start: startPos,
        end: targetPos,
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _FlyingDot extends StatefulWidget {
  final Offset start;
  final Offset end;
  final VoidCallback onComplete;

  const _FlyingDot({
    required this.start,
    required this.end,
    required this.onComplete,
  });

  @override
  State<_FlyingDot> createState() => _FlyingDotState();
}

class _FlyingDotState extends State<_FlyingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _curveAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _curveAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curveAnim,
      builder: (context, child) {
        final t = _curveAnim.value;

        // Parabolic arc path
        final midX = (widget.start.dx + widget.end.dx) / 2;
        final midY =
            (widget.start.dy + widget.end.dy) / 2 - 120; // arc height

        // Quadratic bezier
        final x = _quadBezier(widget.start.dx, midX, widget.end.dx, t);
        final y = _quadBezier(widget.start.dy, midY, widget.end.dy, t);

        // Scale: start big, shrink to small
        final scale = 1.0 - (t * 0.6);
        // Opacity: fade out near end
        final opacity = (1.0 - (t * 0.3)).clamp(0.0, 1.0);

        return Positioned(
          left: x - 20 * scale,
          top: y - 20 * scale,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _quadBezier(double p0, double p1, double p2, double t) {
    return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2;
  }
}
