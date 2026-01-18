import 'package:effulgence26_mobile_app/features/auth/domain/entity/otp_response_otp.dart';

class OtpResponseModel extends OtpResponseEntity {
  const OtpResponseModel({required super.message, required super.step});

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      message: json['message'] as String,
      step: json['step'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'step': step};
  }
}
