import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../components/components.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Register Page
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _collegeNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  // State
  String _step = 'form'; // 'form' or 'verify'
  bool _isCollegeLocked = false;
  int _resendCooldown = 0;
  Timer? _resendTimer;
  Map<String, dynamic>? _registrationData;
  late AnimationController _glowController;

  static const String _knitEmailSuffix = '@knit.ac.in';
  static const String _knitCollegeName =
      'Kamla Nehru Institute of Technology, Sultanpur';

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _emailController.addListener(_checkKnitEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _collegeNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  void _checkKnitEmail() {
    final email = _emailController.text.trim().toLowerCase();
    if (email.endsWith(_knitEmailSuffix)) {
      if (!_isCollegeLocked) {
        setState(() {
          _collegeNameController.text = _knitCollegeName;
          _isCollegeLocked = true;
        });
      }
    } else {
      if (_isCollegeLocked) {
        setState(() {
          _isCollegeLocked = false;
          // Optional: clear college name when unlocking, or keep it
        });
      }
    }
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // Store data for resend
      _registrationData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'mobile': int.parse(_mobileController.text.trim()),
        'collegeName': _collegeNameController.text.trim(),
      };

      context.read<AuthCubit>().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        mobile: int.parse(_mobileController.text.trim()),
        collegeName: _collegeNameController.text.trim(),
      );
    }
  }

  void _onVerifyOtp() {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AuthCubit>().verifyOtp(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
    );
  }

  void _onResendOtp() {
    if (_resendCooldown > 0 || _registrationData == null) return;

    context.read<AuthCubit>().resendOtp(
      name: _registrationData!['name'],
      email: _registrationData!['email'],
      password: _registrationData!['password'],
      mobile: _registrationData!['mobile'],
      collegeName: _registrationData!['collegeName'],
    );
  }

  void _backToForm() {
    setState(() {
      _step = 'form';
      _otpController.clear();
      _resendTimer?.cancel();
      _resendCooldown = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.minimal,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthOtpSent) {
                setState(() {
                  _step = 'verify';
                });
                _startResendCooldown();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (state is AuthOtpVerified ||
                  state is AuthRegistrationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registration successful!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // context.go('/');
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.xl),

                        // Logo and branding (Consistent with LoginPage)
                        Center(
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                AppAssets.logo,
                                width: 100,
                                height: 100,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SvgPicture.asset(AppAssets.textSvg, width: 180),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'INNOVATION AND BEYOND',
                                style: AppTextStyles.labelSmall.copyWith(
                                  letterSpacing: 2.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Glassmorphism Card
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.bgSecondary.withValues(alpha: 0.7),
                                AppColors.bgSecondary.withValues(alpha: 0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _step == 'form'
                                ? _buildRegistrationForm(isLoading)
                                : _buildOtpVerification(isLoading),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Login Link
                        if (_step == 'form')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.pop(),
                                child: Text(
                                  'Login',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        key: const ValueKey('form'),
        children: [
          Text(
            'Create Account',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Register to participate in Effulgence\'26',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          // KNIT Warning
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'KNIT students must use their official college email.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameController,
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_outlined,
            validator: Validators.validateName,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
            enabled: !isLoading,
          ),
          if (_isCollegeLocked)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                '✓ KNIT email detected',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Mobile Number',
            hint: 'Enter your mobile number',
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: Validators.validatePhone,
            enabled: !isLoading,
          ),

          const SizedBox(height: AppSpacing.md),

          Opacity(
            opacity: _isCollegeLocked ? 0.7 : 1.0,
            child: AppTextField(
              label: 'College Name',
              hint: 'Enter your college name',
              controller: _collegeNameController,
              keyboardType: TextInputType.text,
              prefixIcon: Icons.school_outlined,
              validator: Validators.validateCollegeName,
              enabled: !isLoading && !_isCollegeLocked,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Password',
            hint: 'Create a password',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: Icons.lock_outlined,
            validator: Validators.validatePassword,
            enabled: !isLoading,
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock_outlined,
            validator: (value) => Validators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
            onSubmitted: (_) => isLoading ? null : _onRegister(),
            enabled: !isLoading,
          ),

          const SizedBox(height: AppSpacing.sm),
          Text(
            'Password must be 8+ chars with 1 letter & 1 number.',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          GradientButton(
            text: isLoading ? 'SENDING OTP...' : 'GET OTP',
            isLoading: isLoading,
            onPressed: _onRegister,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerification(bool isLoading) {
    return Column(
      key: const ValueKey('verify'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Verify Email',
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Enter the 6-digit code sent to',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          _emailController.text,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xl),

        AppTextField(
          label: 'Enter OTP',
          hint: '000000',
          controller: _otpController,
          keyboardType: TextInputType.number,

          // Increase letter spacing for OTP feel
          style: AppTextStyles.headlineSmall.copyWith(letterSpacing: 8),
          maxLength: 6,
          textAlign: TextAlign.center,
          enabled: !isLoading,
        ),

        const SizedBox(height: AppSpacing.lg),

        GradientButton(
          text: isLoading ? 'VERIFYING...' : 'VERIFY & REGISTER',
          isLoading: isLoading,
          onPressed: _onVerifyOtp,
        ),

        const SizedBox(height: AppSpacing.md),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: isLoading ? null : _backToForm,
              child: Text(
                '← Edit Details',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: (isLoading || _resendCooldown > 0)
                  ? null
                  : _onResendOtp,
              child: Text(
                _resendCooldown > 0
                    ? 'Resend in ${_resendCooldown}s'
                    : 'Resend OTP',
                style: AppTextStyles.labelMedium.copyWith(
                  color: _resendCooldown > 0
                      ? AppColors.textSecondary
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
