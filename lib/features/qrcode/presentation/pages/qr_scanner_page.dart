import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // For Haptics

import '../../../../components/loading/loading_indicators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/verification_response_entity.dart';
import '../cubit/qr_verification_cubit.dart';
import '../cubit/qr_verification_state.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _checkPermissions();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        controller.stop();
        break;
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        await controller.start();
      } catch (e) {
        debugPrint('Error starting scanner: $e');
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final code = capture.barcodes.first.rawValue;
    if (code != null) {
      HapticFeedback.mediumImpact();
      setState(() => _isProcessing = true);
      controller.stop();
      context.read<QrVerificationCubit>().verifyQrCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // 1. CAMERA FEED
          MobileScanner(controller: controller, onDetect: _onDetect),

          // 2. SCANNING OVERLAY (Focus Brackets)
          _buildScannerOverlay(),

          // 3. FULL SCREEN RESULT OVERLAY
          BlocBuilder<QrVerificationCubit, QrVerificationState>(
            builder: (context, state) {
              if (state is QrVerificationLoading) {
                return _buildFullScreenStatus(
                  const AppLoadingIndicator(),
                  "VERIFYING ENCRYPTED DATA...",
                );
              }
              if (state is QrVerificationSuccess) {
                return _buildFullResultOverlay(state.result);
              }
              if (state is QrVerificationFailure) {
                return _buildFullErrorOverlay(state.message);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'SECURE ENTRY SCAN',
        style: AppTextStyles.labelSmall.copyWith(
          letterSpacing: 2,
          color: AppColors.primary,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.flash_on_rounded),
          onPressed: () => controller.toggleTorch(),
        ),
        IconButton(
          icon: const Icon(Icons.flip_camera_ios_rounded),
          onPressed: () => controller.switchCamera(),
        ),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return Stack(
      children: [
        // Darken out-of-focus area
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha:0.7),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(color: Colors.black),
              Center(
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    color:
                        Colors.red, // Arbitrary color for ColorFiltered logic
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Brackets
        Center(
          child: Container(
            height: 260,
            width: 260,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenStatus(Widget child, String label) {
    return Container(
      color: Colors.black.withValues(alpha:0.9),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          const SizedBox(height: 20),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFullResultOverlay(VerificationResponseEntity result) {
    final bool isValid = result.valid;
    if (isValid)
      HapticFeedback.heavyImpact();
    else
      HapticFeedback.vibrate();

    return Container(
      color: AppColors.bgPrimary, // Hides the background entirely
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Security Status Header
          Icon(
            isValid ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
            color: isValid ? AppColors.success : AppColors.error,
            size: 100,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isValid ? "ACCESS GRANTED" : "ACCESS DENIED",
            style: AppTextStyles.headlineMedium.copyWith(
              color: isValid ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const Divider(height: 50, color: AppColors.border),

          // User ID Card
          if (result.user != null) _buildUserIdentityCard(result.user!),

          const SizedBox(height: 50),

          _buildActionButton(
            "SCAN NEXT ENTRY",
            () => _resetScan(),
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            "CLOSE TERMINAL",
            () => Navigator.pop(context),
            color: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildUserIdentityCard(user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.border,
            backgroundImage: user.imageUrl != null
                ? NetworkImage(user.imageUrl!)
                : null,
            child: user.imageUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name.toUpperCase(), style: AppTextStyles.titleLarge),
                Text(
                  user.registrationId,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.collegeName,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullErrorOverlay(String message) {
    return _buildFullScreenStatus(
      Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 80,
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
          ),
          _buildActionButton(
            "TRY AGAIN",
            () => _resetScan(),
            color: AppColors.error,
          ),
        ],
      ),
      "SYSTEM ERROR",
    );
  }

  Widget _buildActionButton(
    String label,
    VoidCallback onTap, {
    required Color color,
  }) {
    return SizedBox(
      width: 250,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: color == Colors.transparent ? AppColors.border : color,
          ),
          backgroundColor: color.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: color == Colors.transparent ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  void _resetScan() {
    context.read<QrVerificationCubit>().reset();
    setState(() => _isProcessing = false);
    controller.start();
  }
}
