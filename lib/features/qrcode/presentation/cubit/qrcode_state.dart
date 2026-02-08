import 'package:equatable/equatable.dart';
import '../../domain/entities/qrcode_entity.dart';

abstract class QrCodeState extends Equatable {
  const QrCodeState();

  @override
  List<Object> get props => [];
}

class QrCodeInitial extends QrCodeState {}

class QrCodeLoading extends QrCodeState {}

class QrCodeLoaded extends QrCodeState {
  final QrCodeEntity qrCode;

  const QrCodeLoaded({required this.qrCode});

  @override
  List<Object> get props => [qrCode];
}

class QrCodeError extends QrCodeState {
  final String message;

  const QrCodeError({required this.message});

  @override
  List<Object> get props => [message];
}
