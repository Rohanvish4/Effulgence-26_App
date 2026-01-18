import 'user_entity.dart';

/// Auth response entity
class AuthResponseEntity {
  final String? token;
  final UserEntity? user;
  final String message;

  const AuthResponseEntity({this.token, this.user, required this.message});
}
