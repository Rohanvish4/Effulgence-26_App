import 'package:effulgence26_mobile_app/features/profile/data/models/edit_response_model.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity profile;
  const ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final EditResponseModel response;
  const ProfileUpdateSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ProfileUpdateError extends ProfileState {
  final String message;
  const ProfileUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileLoggedOut extends ProfileState {}

class ProfilePaymentSubmitting extends ProfileState {}

class ProfilePaymentSuccess extends ProfileState {}

class ProfilePaymentError extends ProfileState {
  final String message;
  const ProfilePaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
