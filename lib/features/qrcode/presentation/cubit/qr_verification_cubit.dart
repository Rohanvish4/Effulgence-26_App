import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/qrcode_repository.dart';
import 'qr_verification_state.dart';

class QrVerificationCubit extends Cubit<QrVerificationState> {
  final QrCodeRepository repository;

  QrVerificationCubit({required this.repository})
    : super(QrVerificationInitial());

  void startScanning() {
    emit(QrVerificationScanning());
  }

  Future<void> verifyQrCode(String qrData) async {
    emit(QrVerificationLoading());
    final result = await repository.verifyQrCode(qrData);
    result.fold(
      (failure) => emit(QrVerificationFailure(message: failure.message)),
      (response) => emit(QrVerificationSuccess(result: response)),
    );
  }

  void reset() {
    emit(QrVerificationInitial());
  }
}
