import 'package:equatable/equatable.dart';
import '../../domain/entities/verification_response_entity.dart';

abstract class QrVerificationState extends Equatable {
  const QrVerificationState();

  @override
  List<Object?> get props => [];
}

class QrVerificationInitial extends QrVerificationState {}

class QrVerificationScanning extends QrVerificationState {}

class QrVerificationLoading extends QrVerificationState {}

class QrVerificationSuccess extends QrVerificationState {
  final VerificationResponseEntity result;

  const QrVerificationSuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

class QrVerificationFailure extends QrVerificationState {
  final String message;

  const QrVerificationFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
