import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';

//temprary splash screen
class EffulgenceSplashScreen extends StatefulWidget {
  const EffulgenceSplashScreen({super.key});

  @override
  State<EffulgenceSplashScreen> createState() => _EffulgenceSplashScreenState();
}

class _EffulgenceSplashScreenState extends State<EffulgenceSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _textController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Animated particle background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticleFieldPainter(animation: _particleController),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _rotationController,
                    _pulseAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer rotating ring
                          Transform.rotate(
                            angle: _rotationController.value * 2 * math.pi,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.electricBlue.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: CustomPaint(
                                painter: CircuitRingPainter(
                                  color: AppColors.electricBlue,
                                ),
                              ),
                            ),
                          ),

                          // Middle rotating ring (opposite direction)
                          Transform.rotate(
                            angle:
                                -_rotationController.value * 2 * math.pi * 0.7,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.royalPurple.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          // Glow effect
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electricBlue.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: 20,
                                ),
                                BoxShadow(
                                  color: AppColors.royalPurple.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 60,
                                  spreadRadius: 30,
                                ),
                              ],
                            ),
                          ),

                          // Center icon
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.electricBlue,
                                  AppColors.royalPurple,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electricBlue.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flash_on,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Animated text
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _textAnimation.value)),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [
                                    AppColors.electricBlue,
                                    AppColors.royalPurple,
                                    AppColors.cyanTeal,
                                  ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                "EFFULGENCE '26",
                                style: AppTextStyles.displayMedium.copyWith(
                                  letterSpacing: 3,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'THE ANNUAL TECH FEST',
                              style: AppTextStyles.labelSmall.copyWith(
                                letterSpacing: 3,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Loading indicator
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Column(
                        children: [
                          // Custom progress bar
                          Container(
                            width: 200,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.bgSecondary,
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: AnimatedBuilder(
                              animation: _rotationController,
                              builder: (context, child) {
                                return Stack(
                                  children: [
                                    // Animated gradient bar
                                    FractionallySizedBox(
                                      widthFactor:
                                          (_rotationController.value % 0.5) * 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppColors.electricBlue,
                                              AppColors.royalPurple,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.electricBlue
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'INITIALIZING SYSTEMS...',
                            style: AppTextStyles.labelSmall.copyWith(
                              letterSpacing: 2,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Corner decorations
          Positioned(
            top: 40,
            left: 20,
            child: AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textAnimation.value * 0.5,
                  child: CustomPaint(
                    size: const Size(40, 40),
                    painter: CornerBracketPainter(
                      color: AppColors.electricBlue,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textAnimation.value * 0.5,
                  child: Transform.rotate(
                    angle: math.pi,
                    child: CustomPaint(
                      size: const Size(40, 40),
                      painter: CornerBracketPainter(
                        color: AppColors.royalPurple,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Particle field painter
class ParticleFieldPainter extends CustomPainter {
  final Animation<double> animation;

  ParticleFieldPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.electricBlue.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    // Draw particles
    for (var i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.2 + random.nextDouble() * 0.3;
      final offset = (animation.value * speed) % 1.0;
      final y = (baseY + offset * size.height) % size.height;

      final particleSize = 1.0 + random.nextDouble() * 2;

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint
          ..color = Color.lerp(
            AppColors.electricBlue,
            AppColors.royalPurple,
            random.nextDouble(),
          )!.withValues(alpha: 0.3),
      );
    }

    // Draw connecting lines
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.5;
    paint.color = AppColors.electricBlue.withValues(alpha: 0.1);

    for (var i = 0; i < 20; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final endX = startX + random.nextDouble() * 100 - 50;
      final endY = startY + random.nextDouble() * 100 - 50;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Circuit ring painter
class CircuitRingPainter extends CustomPainter {
  final Color color;

  CircuitRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw circuit nodes
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.drawCircle(Offset(x, y), 3, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Corner bracket painter
class CornerBracketPainter extends CustomPainter {
  final Color color;

  CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, 0)
      ..lineTo(0, size.height);

    canvas.drawPath(path, paint);

    // Add small decorative lines
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, 5),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(5, size.height * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
