import 'package:flutter/material.dart';

class EffulgenceStaticBackground extends StatelessWidget {
  final Widget child;
  final BoxFit fit;

  const EffulgenceStaticBackground({
    super.key,
    required this.child,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Static Background Image
        Positioned.fill(
          child: Image.asset(
            'background_elements/static_bg.png', // Ensure this asset is registered in pubspec.yaml
            fit: fit,
          ),
        ),
        // Content
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
