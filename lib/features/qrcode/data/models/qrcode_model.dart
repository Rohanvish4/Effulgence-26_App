import '../../domain/entities/qrcode_entity.dart';

class QrCodeModel extends QrCodeEntity {
  const QrCodeModel({
    required super.qrCodeData,
    required super.registrationId,
    required super.name,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      qrCodeData: json['qrCodeData'] ?? '',
      registrationId: json['registrationId'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
