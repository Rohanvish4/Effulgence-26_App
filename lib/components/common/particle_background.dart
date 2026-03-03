import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/services/remote_config_service.dart';

class FloatingBackgroundElement {
  final int count;
  final String? assetPath;
  final Widget Function(BuildContext context)? builder;
  final BoxFit fit;
  final double minSize;
  final double maxSize;
  final double minOpacity;
  final double maxOpacity;
  final double driftX;
  final double driftY;
  final double minSpeed;
  final double maxSpeed;
  final double minRotationSpeed;
  final double maxRotationSpeed;
  final bool blur;
  final double blurSigma;
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
  final List<FloatingBackgroundElement> floatingElements;
  final int? seed;
  final int? day;

  const ParticleBackground({
    super.key,
    this.child,
    this.floatingElements = const [],
    this.seed,
    this.day,
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
  late ParticleSystem _activeSystem;
  late ParticleFieldPainter _particlePainter;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _seed = widget.seed ?? (widget.key?.hashCode ?? identityHashCode(this));
    _random = math.Random(_seed);
    _spawnedElements = _spawnElements(widget.floatingElements);

    _particleController = AnimationController(
      // Ensure the animations run infinitely
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initSystem();
      _initialized = true;
    }
  }

  void _initSystem() {
    int day = widget.day ?? 1;
    if (widget.day == null) {
      try {
        day = context.read<RemoteConfigService>().techfestDay;
      } catch (e) {
        day = 1;
      }
    }

    switch (day) {
      case 2:
        _activeSystem = MatrixSystem();
        break;
      case 3:
        _activeSystem = CircuitSystem();
        break;
      case 4:
        _activeSystem = DataStreamSystem();
        break;
      case 5:
      case 1:
      default:
        _activeSystem = DefaultParticleSystem();
        break;
    }
    _activeSystem.init(_seed);
    _particlePainter = ParticleFieldPainter(
      animation: _particleController,
      system: _activeSystem,
    );
  }

  @override
  void didUpdateWidget(covariant ParticleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.day != widget.day) {
      _initSystem();
    }

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
    if (!_initialized) return const SizedBox();

    return SafeArea(
      child: Stack(
        children: [
          Container(color: AppColors.bgPrimary),
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _particlePainter,
              ),
            ),
          ),
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
                            final dx = math.sin(t * e.speed + e.phaseX) * e.spec.driftX;
                            final dy = math.cos(t * e.speed + e.phaseY) * e.spec.driftY;
                            final r = t * e.rotationSpeed + e.phaseR;

                            final left = (e.xNorm * w - e.size / 2 + dx).clamp(-e.size, w);
                            final top = (e.yNorm * h - e.size / 2 + dy).clamp(-e.size, h);

                            Widget elementChild = e.spec.builder?.call(context) ??
                                Image.asset(
                                  e.spec.assetPath!,
                                  width: e.size,
                                  height: e.size,
                                  fit: e.spec.fit,
                                  filterQuality: FilterQuality.low,
                                  cacheWidth: (e.size * MediaQuery.of(context).devicePixelRatio).round(),
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
          if (widget.child != null) Positioned.fill(child: widget.child!),
        ],
      ),
    );
  }

  List<_SpawnedFloatingElement> _spawnElements(List<FloatingBackgroundElement> specs) {
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
            opacity: _lerp(spec.minOpacity, spec.maxOpacity, _random.nextDouble()),
            speed: _lerp(spec.minSpeed, spec.maxSpeed, _random.nextDouble()),
            rotationSpeed: _lerp(spec.minRotationSpeed, spec.maxRotationSpeed, _random.nextDouble()),
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
  final ParticleSystem system;

  ParticleFieldPainter({
    required this.animation,
    required this.system,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    system.paint(canvas, size, animation.value);
  }

  @override
  bool shouldRepaint(covariant ParticleFieldPainter oldDelegate) {
    return oldDelegate.system != system;
  }
}

abstract class ParticleSystem {
  void init(int seed);
  void paint(Canvas canvas, Size size, double t);
}

// ---------------------------------------------------------
// Default / Day 1 Particle System (Dots & Static Lines)
// ---------------------------------------------------------
class _FieldParticle {
  final double x, y, speed, size;
  final Color color;
  _FieldParticle({required this.x, required this.y, required this.speed, required this.size, required this.color});
}

class _FieldLine {
  final double startX, startY, dx, dy;
  _FieldLine({required this.startX, required this.startY, required this.dx, required this.dy});
}

class DefaultParticleSystem implements ParticleSystem {
  late List<_FieldParticle> _dotParticles;
  late List<_FieldLine> _lineParticles;
  final Paint _dotPaint = Paint()..style = PaintingStyle.fill;
  final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5
    ..color = AppColors.electricBlue.withValues(alpha: 0.1);

  @override
  void init(int seed) {
    final rng = math.Random(seed);
    _dotParticles = List.generate(50, (_) => _FieldParticle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      speed: 0.2 + rng.nextDouble() * 0.3,
      size: 1.0 + rng.nextDouble() * 2,
      color: Color.lerp(
        AppColors.electricBlue,
        AppColors.royalPurple,
        rng.nextDouble(),
      )!.withValues(alpha: 0.3),
    ));

    _lineParticles = List.generate(20, (_) {
      return _FieldLine(
        startX: rng.nextDouble(),
        startY: rng.nextDouble(),
        dx: rng.nextDouble() * 100 - 50,
        dy: rng.nextDouble() * 100 - 50,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size, double t) {
    for (final dot in _dotParticles) {
      final x = dot.x * size.width;
      final offset = (t * dot.speed) % 1.0;
      final y = ((dot.y + offset) % 1.0) * size.height;

      _dotPaint.color = dot.color;
      canvas.drawCircle(Offset(x, y), dot.size, _dotPaint);
    }

    for (final line in _lineParticles) {
      final startX = line.startX * size.width;
      final startY = line.startY * size.height;
      final endX = startX + line.dx;
      final endY = startY + line.dy;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), _linePaint);
    }
  }
}

// ---------------------------------------------------------
// Matrix Rain / Day 2 System
// ---------------------------------------------------------
class _MatrixDrop {
  final double x, speed, length, thickness;
  final Color color;
  _MatrixDrop({required this.x, required this.speed, required this.length, required this.thickness, required this.color});
}

class MatrixSystem implements ParticleSystem {
  late List<_MatrixDrop> _drops;
  final Paint _paint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

  @override
  void init(int seed) {
    final rng = math.Random(seed);
    _drops = List.generate(40, (_) => _MatrixDrop(
      x: rng.nextDouble(),
      speed: 0.2 + rng.nextDouble() * 0.4,
      length: 0.1 + rng.nextDouble() * 0.25,
      thickness: 1.0 + rng.nextDouble() * 1.5,
      color: Colors.greenAccent.withValues(alpha: 0.1 + rng.nextDouble() * 0.3),
    ));
  }

  @override
  void paint(Canvas canvas, Size size, double t) {
    for (final drop in _drops) {
      final xPx = drop.x * size.width;
      final yOffset = (t * drop.speed) % 1.0;
      final headPx = yOffset * size.height;
      final lenPx = drop.length * size.height;

      _paint.color = drop.color;
      _paint.strokeWidth = drop.thickness;
      
      canvas.drawLine(Offset(xPx, headPx), Offset(xPx, headPx - lenPx), _paint);
      
      if (headPx - lenPx < 0) {
        canvas.drawLine(Offset(xPx, headPx + size.height), Offset(xPx, headPx + size.height - lenPx), _paint);
      }
    }
  }
}

// ---------------------------------------------------------
// Tech Circuit / Day 3 System
// ---------------------------------------------------------
class _CircuitNode {
  final double x, y, speedX, speedY, size;
  _CircuitNode(this.x, this.y, this.speedX, this.speedY, this.size);
}

class CircuitSystem implements ParticleSystem {
  late List<_CircuitNode> _nodes;
  final Paint _nodePaint = Paint()..color = AppColors.primary.withValues(alpha: 0.5)..style = PaintingStyle.fill;
  final Paint _linePaint = Paint()..color = AppColors.primary.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 1.0;

  @override
  void init(int seed) {
    final rng = math.Random(seed);
    _nodes = List.generate(35, (_) => _CircuitNode(
       rng.nextDouble(), rng.nextDouble(),
       (rng.nextDouble() - 0.5) * 0.15,
       (rng.nextDouble() - 0.5) * 0.15,
       1.5 + rng.nextDouble() * 2,
    ));
  }

  @override
  void paint(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    
    List<Offset> positions = [];
    for (var node in _nodes) {
      double px = ((node.x + node.speedX * t) % 1.0) * w;
      double py = ((node.y + node.speedY * t) % 1.0) * h;
      if (px < 0) px += w;
      if (py < 0) py += h;
      
      positions.add(Offset(px, py));
      canvas.drawCircle(Offset(px, py), node.size, _nodePaint);
    }
    
    final maxDist = w * 0.22;
    for (int i = 0; i < positions.length; i++) {
        for (int j = i + 1; j < positions.length; j++) {
            final p1 = positions[i];
            final p2 = positions[j];
            final dist = (p1 - p2).distance;
            if (dist < maxDist) {
               _linePaint.color = AppColors.primary.withValues(alpha: 0.3 * (1 - dist / maxDist));
               canvas.drawLine(p1, p2, _linePaint);
            }
        }
    }
  }
}

// ---------------------------------------------------------
// Data Stream / Day 4 System
// ---------------------------------------------------------
class _DataStreamLine {
  final double y, speed, length, thickness;
  final Color color;
  _DataStreamLine(this.y, this.speed, this.length, this.thickness, this.color);
}

class DataStreamSystem implements ParticleSystem {
  late List<_DataStreamLine> _streams;
  final Paint _paint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

  @override
  void init(int seed) {
    final rng = math.Random(seed);
    _streams = List.generate(45, (_) => _DataStreamLine(
       rng.nextDouble(),
       0.5 + rng.nextDouble() * 1.5,
       0.05 + rng.nextDouble() * 0.2,
       0.5 + rng.nextDouble() * 2.0,
       Color.lerp(Colors.orangeAccent, Colors.pinkAccent, rng.nextDouble())!.withValues(alpha: 0.1 + rng.nextDouble() * 0.3),
    ));
  }

  @override
  void paint(Canvas canvas, Size size, double t) {
    for (var s in _streams) {
       final yPx = s.y * size.height;
       final headOffset = (t * s.speed) % 1.0;
       final headPx = headOffset * size.width;
       final lenPx = s.length * size.width;
       
       _paint.color = s.color;
       _paint.strokeWidth = s.thickness;
       
       canvas.drawLine(Offset(headPx, yPx), Offset(headPx - lenPx, yPx), _paint);
       
       if (headPx - lenPx < 0) {
          canvas.drawLine(Offset(headPx + size.width, yPx), Offset(headPx + size.width - lenPx, yPx), _paint);
       }
    }
  }
}
