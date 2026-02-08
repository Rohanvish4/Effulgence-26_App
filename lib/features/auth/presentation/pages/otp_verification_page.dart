import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final Map<String, dynamic> registrationData; // For resend

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.registrationData,
  });
  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpVerified) {
            // Success! Navigate to home
            Navigator.of(context).pushReplacementNamed('/home');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthError) {
            // Show error
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(state.message),
            //     backgroundColor: Colors.red,
            //   ),
            // );
          } else if (state is AuthOtpSent) {
            // OTP resent successfully
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mail_outline, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  Text(
                    'Enter OTP',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check your email: ${widget.email}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // OTP Input Field
                  TextFormField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: 'OTP Code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP';
                      }
                      if (value.length != 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _verifyOtp,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Verify OTP'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resend OTP Button
                  TextButton(
                    onPressed: isLoading ? null : _resendOtp,
                    child: const Text("Didn't receive OTP? Resend"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().verifyOtp(
        email: widget.email,
        otp: _otpController.text,
      );
    }
  }

  void _resendOtp() {
    final data = widget.registrationData;
    context.read<AuthCubit>().resendOtp(
      name: data['name'],
      email: data['email'],
      password: data['password'],
      mobile: data['mobile'],
      collegeName: data['collegeName'],
      imageUrl: data['imageUrl'],
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
