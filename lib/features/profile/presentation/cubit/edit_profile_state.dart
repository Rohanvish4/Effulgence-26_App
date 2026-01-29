import 'package:effulgence26_mobile_app/features/profile/domain/entities/EditResponseEntity.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override 
  List <Object?> get props => [];
}

class ProfileInitial extends EditProfileState{}

class ProfileLoading extends EditProfileState{}

class ProfileLoaded extends EditProfileState {
  final UserProfileEntity profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object?> get props =>[profile];
}
class EditProfileRequestInitial extends EditProfileState{}
class EditProfileRequestSent extends EditProfileState{}
class EditProfileRequestSuccessful extends EditProfileState{
  final EditResponseEntity editResult;
  const EditProfileRequestSuccessful(this.editResult);
  @override
  List<Object?> get props => [editResult.user, editResult.message];
}
class ProfileError extends EditProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];

}
class EditProfileError extends EditProfileState{
  final String message;
  const EditProfileError({required this.message});
  @override
  List<Object?> get props => [message];
}
