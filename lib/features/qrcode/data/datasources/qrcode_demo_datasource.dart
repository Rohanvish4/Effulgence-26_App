import 'package:effulgence26_mobile_app/core/demo/demo_data.dart';
import '../models/qrcode_model.dart';
import '../models/verification_response_model.dart';
import 'qrcode_remote_datasource.dart';

/// Demo implementation of [QrCodeRemoteDataSource].
class QrCodeDemoDataSource implements QrCodeRemoteDataSource {
  @override
  Future<QrCodeModel> getQrCode() async => DemoData.demoQrCode;

  @override
  Future<VerificationResponseModel> verifyQrCode(String qrData) async =>
      VerificationResponseModel.fromJson({
        'valid': true,
        'user': {
          'name': 'Demo User',
          'email': 'demo@effulgence26.in',
          'registrationId': 'REG-DEMO-001',
          'collegeName': 'Thakur College of Engineering & Technology',
          'isInternalUser': false,
        },
      });
}
