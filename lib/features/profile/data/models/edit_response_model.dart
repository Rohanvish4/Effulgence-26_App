import 'package:effulgence26_mobile_app/features/profile/data/models/user_profile_model.dart';
import 'package:effulgence26_mobile_app/features/profile/domain/entities/edit_response_entity.dart';

class EditResponseModel extends EditResponseEntity {
  const EditResponseModel({required super.user, required super.message});

  /// Create from JSON
  factory EditResponseModel.fromJson(Map<String, dynamic> json) {
    return EditResponseModel(
      user: json['user'] != null
          ? UserProfileModel.fromJson(json['user'])
          : null,
      message: json['message'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user != null ? (user as UserProfileModel).toJson() : null,
      'message': message,
    };
  }
}
