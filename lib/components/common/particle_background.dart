import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';

class FloatingBackgroundElement {
  /// Number of instances of this element to spawn.
  final int count;

  /// Provide either [assetPath] or [builder].
  final String? assetPath;
  final Widget Function(BuildContext context)? builder;

  final BoxFit fit;

  /// Size range in logical pixels.
  final double minSize;
  final double maxSize;

  /// Opacity range.
  final double minOpacity;
  final double maxOpacity;

  /// Drift amplitude in logical pixels.
  final double driftX;
  final double driftY;

  /// Relative speed multipliers for drift/rotation.
  final double minSpeed;
  final double maxSpeed;
  final double minRotationSpeed;
  final double maxRotationSpeed;

  /// Optional blur (nice for “ghosted” logos/mascots).
  final bool blur;
  final double blurSigma;

  /// Whether to enable rotation animation. Set to false to keep element
  /// in its original orientation (useful for oriented graphics like mascots).
  final bool rotationEnabled;

  const FloatingBackgroundElement({
    this.count = 1,
    this.assetPath,
    this.builder,
    this.fit = BoxFit.contain,
    this.minSize = 48,
    this.maxSize = 140,
    this.minOpacity = 0.04,
    this.maxOpacity = 0.10,
    this.driftX = 22,
    this.driftY = 16,
    this.minSpeed = 0.25,
    this.maxSpeed = 1.0,
    this.minRotationSpeed = -0.08,
    this.maxRotationSpeed = 0.08,
    this.blur = false,
    this.blurSigma = 2,
    this.rotationEnabled = true,
  }) : assert(
         (assetPath != null) ^ (builder != null),
         'Provide exactly one of assetPath or builder.',
       );
}

class _SpawnedFloatingElement {
  final FloatingBackgroundElement spec;
  final double xNorm;
  final double yNorm;
  final double size;
  final double opacity;
  final double speed;
  final double rotationSpeed;
  final double phaseX;
  final double phaseY;
  final double phaseR;

  const _SpawnedFloatingElement({
    required this.spec,
    required this.xNorm,
    required this.yNorm,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.rotationSpeed,
    required this.phaseX,
    required this.phaseY,
    required this.phaseR,
  });
}

class ParticleBackground extends StatefulWidget {
  final Widget? child;

  /// Optional floating decorations that drift behind content.
  ///
  /// Example:
  /// ParticleBackground(
  ///   floatingElements: [
  ///     FloatingBackgroundElement(
  ///       assetPath: 'assets/bg/effulgence_logo.png',
  ///       count: 3,
  ///       minOpacity: 0.03,
  ///       maxOpacity: 0.08,
  ///       blur: true,
  ///     ),
  ///   ],
  /// )
  final List<FloatingBackgroundElement> floatingElements;

  /// Set a seed if you want deterministic placement (useful for tests).
  /// If null, each widget instance uses a stable random seed.
  final int? seed;

  const ParticleBackground({
    super.key,
    this.child,
    this.floatingElements = const [],
    this.seed,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;
  late int _seed;
  late math.Random _random;
  late List<_SpawnedFloatingElement> _spawnedElements;
  late List<_FieldParticle> _dotParticles;
  late List<_FieldLine> _lineParticles;

  @override
  void initState() {
    super.initState();
    _seed = widget.seed ?? (widget.key?.hashCode ?? identityHashCode(this));
    _random = math.Random(_seed);
    _spawnedElements = _spawnElements(widget.floatingElements);

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _initParticles();
  }

  void _initParticles() {
    final particleRandom = math.Random(42);
    _dotParticles = List.generate(50, (_) => _FieldParticle(
      x: particleRandom.nextDouble(),
      y: particleRandom.nextDouble(),
      speed: 0.2 + particleRandom.nextDouble() * 0.3,
      size: 1.0 + particleRandom.nextDouble() * 2,
      color: Color.lerp(
        AppColors.electricBlue,
        AppColors.royalPurple,
        particleRandom.nextDouble(),
      )!.withValues(alpha: 0.3),
    ));

    _lineParticles = List.generate(20, (_) {
      return _FieldLine(
        startX: particleRandom.nextDouble(),
        startY: particleRandom.nextDouble(),
        dx: particleRandom.nextDouble() * 100 - 50,
        dy: particleRandom.nextDouble() * 100 - 50,
      );
    });
  }

  @override
  void didUpdateWidget(covariant ParticleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the element list changes, respawn.
    if (oldWidget.floatingElements != widget.floatingElements ||
        oldWidget.seed != widget.seed) {
      _seed = widget.seed ?? (widget.key?.hashCode ?? identityHashCode(this));
      _random = math.Random(_seed);
      _spawnedElements = _spawnElements(widget.floatingElements);
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Background Color
          Container(color: AppColors.bgPrimary),
      
          // Animated particle background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return RepaintBoundary(
                  child: CustomPaint(
                    painter: ParticleFieldPainter(
                      animation: _particleController,
                      dots: _dotParticles,
                      lines: _lineParticles,
                    ),
                  ),
                );
              },
            ),
          ),
      
          // Floating themed elements (images/widgets)
          if (_spawnedElements.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    final t = _particleController.value * 2 * math.pi;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
      
                        return Stack(
                          children: _spawnedElements.map((e) {
                            final dx =
                                math.sin(t * e.speed + e.phaseX) * e.spec.driftX;
                            final dy =
                                math.cos(t * e.speed + e.phaseY) * e.spec.driftY;
                            final r = t * e.rotationSpeed + e.phaseR;
      
                            // Position is normalized so it works for any screen size.
                            final left = (e.xNorm * w - e.size / 2 + dx).clamp(
                              -e.size,
                              w,
                            );
                            final top = (e.yNorm * h - e.size / 2 + dy).clamp(
                              -e.size,
                              h,
                            );
      
                            Widget elementChild =
                                e.spec.builder?.call(context) ??
                                Image.asset(
                                  e.spec.assetPath!,
                                  width: e.size,
                                  height: e.size,
                                  fit: e.spec.fit,
                                  filterQuality: FilterQuality.low,
                                  // Keep these light; they are background-only.
                                  cacheWidth:
                                      (e.size *
                                              MediaQuery.of(
                                                context,
                                              ).devicePixelRatio)
                                          .round(),
                                );
      
                            if (e.spec.blur) {
                              elementChild = ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(
                                  sigmaX: e.spec.blurSigma,
                                  sigmaY: e.spec.blurSigma,
                                ),
                                child: elementChild,
                              );
                            }
      
                            // Apply rotation only if enabled for this element.
                            if (e.spec.rotationEnabled) {
                              elementChild = Transform.rotate(
                                angle: r,
                                child: elementChild,
                              );
                            }
      
                            return Positioned(
                              left: left.toDouble(),
                              top: top.toDouble(),
                              child: Opacity(
                                opacity: e.opacity,
                                child: elementChild,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
      
          // Content
          if (widget.child != null) Positioned.fill(child: widget.child!),
        ],
      ),
    );
  }

  List<_SpawnedFloatingElement> _spawnElements(
    List<FloatingBackgroundElement> specs,
  ) {
    final spawned = <_SpawnedFloatingElement>[];
    for (final spec in specs) {
      final count = spec.count.clamp(0, 1000);
      for (var i = 0; i < count; i++) {
        spawned.add(
          _SpawnedFloatingElement(
            spec: spec,
            xNorm: _random.nextDouble(),
            yNorm: _random.nextDouble(),
            size: _lerp(spec.minSize, spec.maxSize, _random.nextDouble()),
            opacity: _lerp(
              spec.minOpacity,
              spec.maxOpacity,
              _random.nextDouble(),
            ),
            speed: _lerp(spec.minSpeed, spec.maxSpeed, _random.nextDouble()),
            rotationSpeed: _lerp(
              spec.minRotationSpeed,
              spec.maxRotationSpeed,
              _random.nextDouble(),
            ),
            phaseX: _random.nextDouble() * 2 * math.pi,
            phaseY: _random.nextDouble() * 2 * math.pi,
            phaseR: _random.nextDouble() * 2 * math.pi,
          ),
        );
      }
    }
    return spawned;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

class ParticleFieldPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_FieldParticle> dots;
  final List<_FieldLine> lines;

  // Pre-create Paint objects to avoid allocation in paint loop
  final Paint _dotPaint = Paint()..style = PaintingStyle.fill;
  final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5
    ..color = AppColors.electricBlue.withValues(alpha: 0.1);

  ParticleFieldPainter({
    required this.animation,
    required this.dots,
    required this.lines,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw particles
    for (final dot in dots) {
      final x = dot.x * size.width;
      final offset = (animation.value * dot.speed) % 1.0;
      final y = ((dot.y + offset) % 1.0) * size.height;

      // Reuse the paint object, only updating color
      _dotPaint.color = dot.color;

      canvas.drawCircle(
        Offset(x, y),
        dot.size,
        _dotPaint,
      );
    }

    // Draw connecting lines with the constant paint
    for (final line in lines) {
      final startX = line.startX * size.width;
      final startY = line.startY * size.height;
      final endX = startX + line.dx;
      final endY = startY + line.dy;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), _linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleFieldPainter oldDelegate) => true; 
}

class _FieldParticle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final Color color;

  _FieldParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class _FieldLine {
  final double startX;
  final double startY;
  final double dx;
  final double dy;

  _FieldLine({
    required this.startX,
    required this.startY,
    required this.dx,
    required this.dy,
  });
}
