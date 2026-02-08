import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/qrcode_repository.dart';
import 'qrcode_state.dart';

class QrCodeCubit extends Cubit<QrCodeState> {
  final QrCodeRepository repository;

  QrCodeCubit({required this.repository}) : super(QrCodeInitial());

  Future<void> getQrCode() async {
    emit(QrCodeLoading());
    final result = await repository.getQrCode();
    result.fold(
      (failure) => emit(QrCodeError(message: failure.message)),
      (qrCode) => emit(QrCodeLoaded(qrCode: qrCode)),
    );
  }
}
