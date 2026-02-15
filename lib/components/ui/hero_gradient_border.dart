import 'package:flutter/material.dart';
import 'package:effulgence26_mobile_app/core/theme/app_colors.dart';

class HeroGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final BoxShape shape;

  const HeroGradientBorder({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.shape = BoxShape.rectangle,
  });

  @override
  State<HeroGradientBorder> createState() => _HeroGradientBorderState();
}

class _HeroGradientBorderState extends State<HeroGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(seconds: 3), vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary improves performance by isolating the rotation painting
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: widget.shape,
              borderRadius: widget.shape == BoxShape.rectangle
                  ? BorderRadius.circular(widget.borderRadius)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary
                      .withValues(alpha: 0.2 * _controller.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _HeroPainter(
                rotation: _controller.value,
                borderRadius: widget.borderRadius,
                shape: widget.shape,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  final double rotation;
  final double borderRadius;
  final BoxShape shape;

  _HeroPainter({
    required this.rotation,
    required this.borderRadius,
    required this.shape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..strokeWidth = 3 // Thicker for Hero
      ..style = PaintingStyle.stroke;

    paint.shader = SweepGradient(
      colors: [
        Colors.transparent,
        AppColors.primary,
        AppColors.secondary,
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.5, 1.0],
      transform: GradientRotation(rotation * 2 * 3.14159),
    ).createShader(rect);

    if (shape == BoxShape.circle) {
      // Calculate radius for circle
      final double radius = size.shortestSide / 2;
      canvas.drawCircle(rect.center, radius, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeroPainter oldDelegate) =>
      oldDelegate.rotation != rotation ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.shape != shape;
}
