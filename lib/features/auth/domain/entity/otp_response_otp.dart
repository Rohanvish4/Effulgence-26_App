/// OTP response entity for signup step
class OtpResponseEntity {
  final String message;
  final String step;

  const OtpResponseEntity({required this.message, required this.step});
}
