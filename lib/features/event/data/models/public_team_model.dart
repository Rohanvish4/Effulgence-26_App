import '../../domain/entities/public_team_entity.dart';

class PublicTeamModel extends PublicTeamEntity {
  const PublicTeamModel({
    required super.id,
    required super.teamName,
    required super.members,
    required super.registeredAt,
  });

  factory PublicTeamModel.fromJson(Map<String, dynamic> json) {
    return PublicTeamModel(
      id: json['_id'] ?? '',
      teamName: json['teamName'] ?? 'Unknown Team',
      members:
          (json['teamMember'] as List<dynamic>?)
              ?.map((e) => TeamMemberModel.fromJson(e))
              .toList() ??
          [],
      registeredAt:
          DateTime.tryParse(json['registeredAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class TeamMemberModel extends TeamMemberEntity {
  const TeamMemberModel({
    required super.userId,
    required super.name,
    super.email,
    super.imageUrl,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      userId: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'],
      imageUrl: json['imageUrl'],
    );
  }
}
