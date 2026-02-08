import 'package:equatable/equatable.dart';

class VerificationResponseEntity extends Equatable {
  final bool valid;
  final UserVerificationDetails? user;

  const VerificationResponseEntity({required this.valid, this.user});

  @override
  List<Object?> get props => [valid, user];
}

class UserVerificationDetails extends Equatable {
  final String name;
  final String email;
  final String registrationId;
  final String? imageUrl;
  final String collegeName;
  final bool isInternalUser;

  const UserVerificationDetails({
    required this.name,
    required this.email,
    required this.registrationId,
    this.imageUrl,
    required this.collegeName,
    required this.isInternalUser,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    registrationId,
    imageUrl,
    collegeName,
    isInternalUser,
  ];
}
