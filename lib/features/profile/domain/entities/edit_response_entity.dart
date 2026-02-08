import 'package:effulgence26_mobile_app/features/profile/domain/entities/user_profile_entity.dart';

class EditResponseEntity {
  final UserProfileEntity? user;
  final String message;

  const EditResponseEntity({this.user, required this.message});
}
