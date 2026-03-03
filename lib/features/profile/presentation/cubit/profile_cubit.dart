import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/user_profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserProfileRepository profileRepository;

  ProfileCubit({required this.profileRepository}) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await profileRepository.getProfile();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> logout() async {
    emit(ProfileLoading());
    final result = await profileRepository.logout();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(ProfileLoggedOut()),
    );
  }

  Future<void> updateProfile({
    String? name,
    int? mobile,
    String? imageUrl,
    File? imageFile,
    String? collegeName,
  }) async {
    emit(ProfileUpdateLoading());

    String? finalImageUrl = imageUrl;

    if (imageFile != null) {
      final uploadResult = await profileRepository.uploadProfileImage(
        imageFile,
      );

      final failureOrUrl = uploadResult.fold(
        (failure) => failure,
        (url) => url,
      );

      if (failureOrUrl is! String) {
        // It failed
        emit(ProfileUpdateError((failureOrUrl as dynamic).message));
        return;
      }
      finalImageUrl = failureOrUrl;
    }

    final result = await profileRepository.updateProfile(
      name: name,
      mobile: mobile,
      imageUrl: finalImageUrl,
      collegeName: collegeName,
    );
    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message)),
      (response) => emit(ProfileUpdateSuccess(response)),
    );
  }

  Future<void> submitPayment({
    required File receiptImage,
    required String utrNumber,
  }) async {
    emit(ProfilePaymentSubmitting());

    final result = await profileRepository.submitPaymentDetails(
      receiptImage: receiptImage,
      utrNumber: utrNumber,
    );

    result.fold((failure) => emit(ProfilePaymentError(failure.message)), (_) {
      emit(ProfilePaymentSuccess());
      loadProfile(); // Refresh profile to get updated status
    });
  }

  Future<void> loadReferrals() async {
    emit(ProfileReferralsLoading());
    final result = await profileRepository.getMyReferrals();
    result.fold(
      (failure) => emit(ProfileReferralsError(failure.message)),
      (referrals) => emit(ProfileReferralsLoaded(referrals)),
    );
  }
}
