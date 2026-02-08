import 'package:dartz/dartz.dart';
import 'package:effulgence26_mobile_app/core/errors/exceptions.dart';
import 'package:effulgence26_mobile_app/core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/qrcode_entity.dart';
import '../../domain/entities/verification_response_entity.dart';
import '../../domain/repositories/qrcode_repository.dart';
import '../datasources/qrcode_remote_datasource.dart';

class QrCodeRepositoryImpl implements QrCodeRepository {
  final QrCodeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  QrCodeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, QrCodeEntity>> getQrCode() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final remoteQrCode = await remoteDataSource.getQrCode();
      return Right(remoteQrCode);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerificationResponseEntity>> verifyQrCode(
    String qrData,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final remoteResponse = await remoteDataSource.verifyQrCode(qrData);
      return Right(remoteResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
