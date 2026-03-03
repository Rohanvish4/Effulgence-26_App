import 'particle_background.dart';



/// ParticleBackground(
///   floatingElements: EffulgenceBackgroundElements.defaultSet,
///   child: YourPageContent(),
/// )
class EffulgenceBackgroundElements {
  EffulgenceBackgroundElements._();

  /// defaultt, subtle, low-opacity floating themed elements.
  static const List<FloatingBackgroundElement> defaultSet = [
    // Element 1
    FloatingBackgroundElement(
      assetPath: 'background_elements/1.png',
      count: 2,
      minSize: 80,
      maxSize: 160,
      minOpacity: 0.03,
      maxOpacity: 0.08,
      driftX: 28,
      driftY: 20,
      minSpeed: 0.3,
      maxSpeed: 0.7,
      minRotationSpeed: -0.05,
      maxRotationSpeed: 0.05,
      blur: true,
      blurSigma: 2.5,
      rotationEnabled: true,
    ),

    // Element 2: 
    FloatingBackgroundElement(
      assetPath: 'background_elements/2.png',
      count: 2,
      minSize: 70,
      maxSize: 140,
      minOpacity: 0.025,
      maxOpacity: 0.07,
      driftX: 22,
      driftY: 18,
      minSpeed: 0.25,
      maxSpeed: 0.65,
      minRotationSpeed: 0,
      maxRotationSpeed: 0,
      blur: true,
      blurSigma: 2.0,
      rotationEnabled: false,
    ),
  ];

  /// Denser variant (more visible, more elements).
  static const List<FloatingBackgroundElement> dense = [
    FloatingBackgroundElement(
      assetPath: 'background_elements/1.png',
      count: 3,
      minSize: 90,
      maxSize: 180,
      minOpacity: 0.9,
      maxOpacity: 1,
      driftX: 30,
      driftY: 22,
      minSpeed: 0.35,
      maxSpeed: 0.8,
      minRotationSpeed: 0,
      maxRotationSpeed: 0,
      blur: false,
      blurSigma: 2.5,
      rotationEnabled: false,
    ),
    FloatingBackgroundElement(
      assetPath: 'background_elements/2.png',
      count: 3,
      minSize: 80,
      maxSize: 160,
      minOpacity: 0.9,
      maxOpacity: 1,
      driftX: 26,
      driftY: 20,
      minSpeed: 0.3,
      maxSpeed: 0.75,
      minRotationSpeed: -0.07,
      maxRotationSpeed: 0.07,
      blur: false,
      blurSigma: 2.2,
      rotationEnabled: false,
    ),
  ];

  static const List<FloatingBackgroundElement> dense2 = [
    FloatingBackgroundElement(
      assetPath: 'background_elements/26.png',
      count: 3,
      minSize: 90,
      maxSize: 180,
      minOpacity: 0.9,
      maxOpacity: 1,
      driftX: 30,
      driftY: 22,
      minSpeed: 0.35,
      maxSpeed: 0.8,
      minRotationSpeed: 0,
      maxRotationSpeed: 0,
      blur: false,
      blurSigma: 2.5,
      rotationEnabled: false,
    ),
    FloatingBackgroundElement(
      assetPath: 'background_elements/27.png',
      count: 3,
      minSize: 80,
      maxSize: 160,
      minOpacity: 0.9,
      maxOpacity: 1,
      driftX: 26,
      driftY: 20,
      minSpeed: 0.3,
      maxSpeed: 0.75,
      minRotationSpeed: -0.07,
      maxRotationSpeed: 0.07,
      blur: false,
      blurSigma: 2.2,
      rotationEnabled: false,
    ),
    FloatingBackgroundElement(
      assetPath: 'background_elements/28.png',
      count: 3,
      minSize: 85,
      maxSize: 170,
      minOpacity: 0.9,
      maxOpacity: 1,
      driftX: 28,
      driftY: 24,
      minSpeed: 0.32,
      maxSpeed: 0.78,
      minRotationSpeed: 0,
      maxRotationSpeed: 0,
      blur: false,
      blurSigma: 2.3,
      rotationEnabled: false,
    ),
  ];

  static const List<FloatingBackgroundElement> dense3 = [
    FloatingBackgroundElement(
      assetPath: 'background_elements/29.png',
      count: 3,
      minSize: 90,
      maxSize: 180,
      minOpacity: 0.9,
      maxOpacity: 1,
      driftX: 30,
      driftY: 22,
      minSpeed: 0.35,
      maxSpeed: 0.8,
      minRotationSpeed: 0,
      maxRotationSpeed: 0,
      blur: false,
      blurSigma: 2.5,
      rotationEnabled: false,
    ),
    FloatingBackgroundElement(
      assetPath: 'background_elements/30.png',
      count: 3,
      minSize: 80,
      maxSize: 160,
      minOpacity: 0.9,
      maxOpacity: 1,
      driftX: 26,
      driftY: 20,
      minSpeed: 0.3,
      maxSpeed: 0.75,
      minRotationSpeed: -0.07,
      maxRotationSpeed: 0.07,
      blur: false,
      blurSigma: 2.2,
      rotationEnabled: false,
    ),
    FloatingBackgroundElement(
      assetPath: 'background_elements/1.png',
      count: 3,
      minSize: 85,
      maxSize: 170,
      minOpacity: 0.9,
      maxOpacity: 1,
      driftX: 28,
      driftY: 24,
      minSpeed: 0.32,
      maxSpeed: 0.78,
      minRotationSpeed: 0,
      maxRotationSpeed: 0,
      blur: false,
      blurSigma: 2.3,
      rotationEnabled: false,
    ),
  ];


    static const List<FloatingBackgroundElement> staticElementsBg = [
    FloatingBackgroundElement(
      assetPath: 'background_elements/static_bg.png',
      count: 1,
      minSize: 1920,
      maxSize: 1920,
      minOpacity: 0.9,
      maxOpacity: 1,
      driftX: 0,
      driftY: 0,
      minSpeed: 0,
      maxSpeed: 0,
      minRotationSpeed: 0,
      maxRotationSpeed: 0,
      blur: false,
      blurSigma: 2.5,
      rotationEnabled: false,
    ),
  ];


  



  /// Minimal/subtle variant (fewer, smaller, more transparent).
  static const List<FloatingBackgroundElement> minimal = [
    FloatingBackgroundElement(
      assetPath: 'background_elements/1.png',
      count: 1,
      minSize: 60,
      maxSize: 120,
      minOpacity: 0.02,
      maxOpacity: 0.05,
      driftX: 20,
      driftY: 14,
      minSpeed: 0.25,
      maxSpeed: 0.6,
      minRotationSpeed: -0.04,
      maxRotationSpeed: 0.04,
      blur: true,
      blurSigma: 3.0,
      rotationEnabled: true,
    ),
    FloatingBackgroundElement(
      assetPath: 'background_elements/2.png',
      count: 1,
      minSize: 55,
      maxSize: 110,
      minOpacity: 0.015,
      maxOpacity: 0.045,
      driftX: 18,
      driftY: 12,
      minSpeed: 0.2,
      maxSpeed: 0.55,
      minRotationSpeed: -0.04,
      maxRotationSpeed: 0.04,
      blur: true,
      blurSigma: 3.5,
      rotationEnabled: false,
    ),
  ];

  /// High-energy variant (larger, more visible, faster drift).
  static const List<FloatingBackgroundElement> energetic = [
    FloatingBackgroundElement(
      assetPath: 'background_elements/1.png',
      count: 4,
      minSize: 100,
      maxSize: 200,
      minOpacity: 0.05,
      maxOpacity: 0.12,
      driftX: 40,
      driftY: 30,
      minSpeed: 0.5,
      maxSpeed: 1.2,
      minRotationSpeed: -0.10,
      maxRotationSpeed: 0.10,
      blur: true,
      blurSigma: 2.0,
      rotationEnabled: true,
    ),
    FloatingBackgroundElement(
      assetPath: 'background_elements/2.png',
      count: 3,
      minSize: 90,
      maxSize: 180,
      minOpacity: 0.045,
      maxOpacity: 0.11,
      driftX: 35,
      driftY: 28,
      minSpeed: 0.45,
      maxSpeed: 1.1,
      minRotationSpeed: -0.09,
      maxRotationSpeed: 0.09,
      blur: true,
      blurSigma: 2.2,
      rotationEnabled: false,
    ),
  ];

  static List<FloatingBackgroundElement> getElementsForDay(int day) {
    switch (day) {
      case 1:
        return dense;
      case 2:
        return dense;
      case 3:
        return dense;
      case 4:
        return energetic;
      case 5:
        return staticElementsBg;
      default:
        return dense;
    }
  }
}
