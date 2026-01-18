// import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';
// import '../errors/failures.dart';

// /// Base UseCase class with parameters
// abstract class UseCase<T, Params> {
//   Future<Either<Failure, T>> call(Params params);
// }

// /// UseCase without parameters
// abstract class UseCaseNoParams<T> {
//   Future<Either<Failure, T>> call();
// }

// /// Stream UseCase for real-time data
// abstract class StreamUseCase<T, Params> {
//   Stream<Either<Failure, T>> call(Params params);
// }

// /// No parameters class
// class NoParams extends Equatable {
//   const NoParams();

//   @override
//   List<Object?> get props => [];
// }

// /// Pagination parameters
// class PaginationParams extends Equatable {
//   final int page;
//   final int limit;

//   const PaginationParams({this.page = 1, this.limit = 10});

//   @override
//   List<Object?> get props => [page, limit];
// }
