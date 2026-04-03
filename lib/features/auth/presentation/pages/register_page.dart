
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
import '../widgets/auth_support_section.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Register Page
class RegisterPage extends StatefulWidget {
  final Map<String, dynamic>? googleUser;

  const RegisterPage({super.key, this.googleUser});

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
  final _referralCodeController = TextEditingController();
  // State
  bool _isCollegeLocked = false;
  late AnimationController _glowController;
  bool _isGoogleSignup = false;
  String? _googleIdToken;

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

    if (widget.googleUser != null) {
      _isGoogleSignup = true;
      _googleIdToken = widget.googleUser!['idToken'];
      _nameController.text = widget.googleUser!['name'] ?? '';
      _emailController.text = widget.googleUser!['email'] ?? '';
    }

    // Also check if we arrived here via router redirect (no extra data)
    // by reading the AuthCubit state directly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isGoogleSignup) {
        final authState = context.read<AuthCubit>().state;
        if (authState is GoogleUserNotRegistered) {
          setState(() {
            _isGoogleSignup = true;
            _googleIdToken = authState.idToken;
            _nameController.text = authState.name ?? '';
            _emailController.text = authState.email;
            _checkKnitEmail();
          });
        }
      }
    });

    _emailController.addListener(_checkKnitEmail);
    // Trigger check for google email immediately
    if (_isGoogleSignup) {
      _checkKnitEmail();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _collegeNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();

    // _otpController removed
    // _resendTimer removed
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



  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isGoogleSignup) {
        // Direct Google Registration
        context.read<AuthCubit>().googleRegister(
          idToken: _googleIdToken!,
          mobile: _mobileController.text.trim(),
          collegeName: _collegeNameController.text.trim(),
          password: _passwordController.text,
          referralRegId: (!_isCollegeLocked && _referralCodeController.text.trim().isNotEmpty)
              ? _referralCodeController.text.trim()
              : null,
        );
      } else {
        // Manual registration removed
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Please sign up with Google.')),
        );
      }
    }
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
              if (state is AuthRegistrationSuccess || 
                  state is AuthAuthenticated) { // Handle AuthAuthenticated for Google Sign Up success
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
              } else if (state is GoogleUserNotRegistered) {
                setState(() {
                  _isGoogleSignup = true;
                  _googleIdToken = state.idToken;
                  _nameController.text = state.name ?? '';
                  _emailController.text = state.email;
                  _checkKnitEmail();
                });

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
                        const SizedBox(height: AppSpacing.sm),

                        // Logo and branding (Consistent with LoginPage)
                        Center(
                          child: Column(
                            children: [
                              Image.asset(
                        AppAssets.logoPng,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                              const SizedBox(height: AppSpacing.md),
                              SvgPicture.asset(AppAssets.textSvg, width: 180),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'INNOVATION AND BEYOND',
                                style: AppTextStyles.labelSmall.copyWith(
                                  letterSpacing: 2.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

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
                          child: _buildRegistrationForm(isLoading),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Login Link
                        if (!_isGoogleSignup)
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

                        const SizedBox(height: AppSpacing.md),

                        const AuthSupportSection(),

                        const SizedBox(height: AppSpacing.sm),
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
            _isGoogleSignup ? 'Complete Profile' : 'Join Effulgence\'26',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _isGoogleSignup 
              ? 'Welcome, ${_nameController.text.split(' ').first}!\nJust a few more details to finish setup.' 
              : 'Sign in with your Google account to get started.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          if (_isGoogleSignup) ...[
            // User Info Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.primary.withValues(alpha:0.3)),
              ),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                        widget.googleUser?['photoUrl'] ?? 
                        (context.read<AuthCubit>().state is GoogleUserNotRegistered ? 
                        (context.read<AuthCubit>().state as GoogleUserNotRegistered).photoUrl ?? '' : ''),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha:0.1),
                    onBackgroundImageError: (_, __) {},
                    child: (widget.googleUser?['photoUrl'] == null && 
                           (context.read<AuthCubit>().state is! GoogleUserNotRegistered || 
                            (context.read<AuthCubit>().state as GoogleUserNotRegistered).photoUrl == null))
                        ? Text(
                            _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U',
                            style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text,
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          _emailController.text,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AppColors.success),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // College Warning if needed (only relevant if we are detecting email, which we do automatically)
            if (_isCollegeLocked)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
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
              ),

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
              label: 'Create Password',
              hint: 'Set a password for your account',
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

            // Referral Code field (optional, only for non-KNIT users)
            if (!_isCollegeLocked) ...[  
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Referral Code (Optional)',
                hint: 'Enter a friend\'s registration ID',
                controller: _referralCodeController,
                keyboardType: TextInputType.text,
                prefixIcon: Icons.card_giftcard_outlined,
                enabled: !isLoading,
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            GradientButton(
              text: isLoading ? 'SETTING UP...' : 'COMPLETE SETUP',
              isLoading: isLoading,
              onPressed: _onRegister,
            ),
          ] else ...[
            // Initial State - Only Google Sign In
            const SizedBox(height: AppSpacing.md),
            Center(
              child: GoogleButton(
                onPressed: () {
                   context.read<AuthCubit>().googleLogin();
                },
                isLoading: isLoading, 
                text: "Register with Google",
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'Note: KNIT students must use their college mail ID (@knit.ac.in).\nStudents from other colleges can use any email.',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.warning,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}