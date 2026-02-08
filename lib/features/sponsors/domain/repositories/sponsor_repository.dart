import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sponsor_entity.dart';

/// Repository interface for sponsor operations
abstract class SponsorRepository {
  /// Fetch all sponsors
  Future<Either<Failure, List<SponsorEntity>>> getSponsors();

  /// Fetch a specific sponsor by ID
  Future<Either<Failure, SponsorEntity>> getSponsorById(String id);
}
