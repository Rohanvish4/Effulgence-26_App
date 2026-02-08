import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sponsor_entity.dart';
import '../../domain/repositories/sponsor_repository.dart';
import '../datasources/sponsor_local_datasource.dart';

/// Repository implementation for sponsors
class SponsorRepositoryImpl implements SponsorRepository {
  final SponsorLocalDataSource localDataSource;

  SponsorRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<SponsorEntity>>> getSponsors() async {
    try {
      final sponsors = await localDataSource.getSponsors();
      return Right(sponsors);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch sponsors: $e'));
    }
  }

  @override
  Future<Either<Failure, SponsorEntity>> getSponsorById(String id) async {
    try {
      final sponsor = await localDataSource.getSponsorById(id);
      return Right(sponsor);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch sponsor: $e'));
    }
  }
}
