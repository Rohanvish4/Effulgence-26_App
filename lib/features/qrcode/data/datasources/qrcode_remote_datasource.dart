import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/qrcode_model.dart';

import '../models/verification_response_model.dart';

abstract class QrCodeRemoteDataSource {
  Future<QrCodeModel> getQrCode();
  Future<VerificationResponseModel> verifyQrCode(String qrData);
}

class QrCodeRemoteDataSourceImpl implements QrCodeRemoteDataSource {
  final ApiClient apiClient;

  QrCodeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<QrCodeModel> getQrCode() async {
    final response = await apiClient.get(ApiConstants.qrCode);
    return QrCodeModel.fromJson(response.data);
  }

  @override
  Future<VerificationResponseModel> verifyQrCode(String qrData) async {
    final response = await apiClient.post(
      ApiConstants.verifyQrCode,
      data: {'qrData': qrData},
    );
    return VerificationResponseModel.fromJson(response.data);
  }
}
