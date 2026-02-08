import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../components/components.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.minimal,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message.contains('success')
                        ? 'Welcome back!'
                        : state.message,
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              // Navigation is handled automatically by app router
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      state.message.contains('Invalid') ||
                          state.message.contains('Input')
                      ? Text('Please Choose Strong Password')
                      : Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // Logo and branding
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

                    // Login form in glassmorphism container
                    Container(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title
                            Text(
                              'Welcome Back',
                              style: AppTextStyles.headlineMedium,
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: AppSpacing.xs),

                            Text(
                              'Login to continue your journey',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // Email Field
                            AppTextField(
                              label: 'Email',
                              hint: 'Enter your email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.email_outlined,
                              validator: Validators.validateEmail,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Password Field
                            AppTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _passwordController,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icons.lock_outlined,
                              validator: Validators.validatePassword,
                              onSubmitted: (_) => _onLogin(),
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse(
                                      'https://www.effulgence26.in/forgot-password',
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Login Button
                            GradientButton(
                              text: 'LOGIN',
                              isLoading: state is AuthLoading,
                              onPressed: _onLogin,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Divider
                    const DividerWithText(text: 'OR'),

                    const SizedBox(height: AppSpacing.lg),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text(
                            'Register',
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
            );
          },
        ),
      ),
    );
  }
}
