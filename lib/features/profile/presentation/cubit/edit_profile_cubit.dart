import 'package:effulgence26_mobile_app/features/profile/presentation/cubit/edit_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/edit_user_profile_repository.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final EditUserProfileRepository profileRepository;

  EditProfileCubit({required this.profileRepository}) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await profileRepository.getProfile();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }
  Future<void> updateProfile({
    String? name,
    int? mobile,
    String? imageUrl,
  }) async {
    emit(ProfileLoading());
    final result = await profileRepository.update(
      name: name,
      mobile: mobile,
      imageUrl: imageUrl,
    );
    result.fold(
          (failure) {
        emit(EditProfileError(message: failure.message));
      },
          (response) {
          emit(
            EditProfileRequestSuccessful(
              response
            ),
          );
      },
    );
  }


}
