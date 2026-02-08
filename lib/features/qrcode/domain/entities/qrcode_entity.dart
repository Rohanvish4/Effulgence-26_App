import 'package:equatable/equatable.dart';

class QrCodeEntity extends Equatable {
  final String qrCodeData;
  final String registrationId;
  final String name;

  const QrCodeEntity({
    required this.qrCodeData,
    required this.registrationId,
    required this.name,
  });

  @override
  List<Object?> get props => [qrCodeData, registrationId, name];
}
