import 'package:dartz/dartz.dart';
import 'package:effulgence26_mobile_app/core/errors/failures.dart';
import '../entities/qrcode_entity.dart';

import '../entities/verification_response_entity.dart';

abstract class QrCodeRepository {
  Future<Either<Failure, QrCodeEntity>> getQrCode();
  Future<Either<Failure, VerificationResponseEntity>> verifyQrCode(
    String qrData,
  );
}
