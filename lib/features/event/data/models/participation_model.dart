import '../../domain/entities/participation_entity.dart';

/// Participation model for data layer
class ParticipationModel extends ParticipationEntity {
  const ParticipationModel({
    required super.id,
    required super.eventId,
    super.user,
    required super.teamMembers,
    super.teamName,
    required super.participationType,
    required super.registeredAt,
    required super.isPresent,
    super.markedPresentAt,
    super.rank,
    required super.score,
    required super.isQualified,
    super.remarks,
    super.isPublic,
  });

  /// Create from JSON
  factory ParticipationModel.fromJson(Map<String, dynamic> json) {
    return ParticipationModel(
      id: json['_id'] ?? json['id'] ?? '',
      eventId:
          json['event'] is Map
              ? (json['event']['_id'] ?? '')
              : (json['event'] ?? ''),
      user: _parseUser(json['user']),
      teamMembers: _parseTeamMembers(json['teamMember']),
      teamName: json['teamName'],
      participationType: json['participationType'] ?? 'INDIVIDUAL',
      registeredAt:
          json['registeredAt'] != null
              ? DateTime.parse(json['registeredAt'])
              : DateTime.now(),
      isPresent: json['isPresent'] ?? false,
      markedPresentAt:
          json['markedPresentAt'] != null
              ? DateTime.parse(json['markedPresentAt'])
              : null,
      rank: json['rank'],
      score: json['score'] ?? 0,
      isQualified: json['isQualified'] ?? false,
      remarks: json['remarks'],
      isPublic: json['isPublic'] ?? false,
    );
  }

  static ParticipationUser? _parseUser(dynamic userJson) {
    if (userJson is Map<String, dynamic>) {
      return ParticipationUser(
        id: userJson['_id'] ?? userJson['id'] ?? '',
        name: userJson['name'] ?? 'Unknown',
        email: userJson['email'] ?? '',
        mobile: userJson['mobile'] ?? '',
      );
    } else if (userJson is String && userJson.isNotEmpty) {
      // Fallback if we only receive an ID string
      return ParticipationUser(
        id: userJson,
        name: 'Unknown',
        email: '',
        mobile: '',
      );
    }
    return null;
  }

  static List<ParticipationUser> _parseTeamMembers(dynamic teamMembersJson) {
    if (teamMembersJson is List) {
      return teamMembersJson.map((member) {
        if (member is Map<String, dynamic>) {
          return ParticipationUser(
            id: member['_id'] ?? member['id'] ?? '',
            name: member['name'] ?? 'Unknown',
            email: member['email'] ?? '',
            mobile: member['mobile'] ?? '',
          );
        }
        if (member is String && member.isNotEmpty) {
          return ParticipationUser(
            id: member,
            name: 'Unknown',
            email: '',
            mobile: '',
          );
        }
        return const ParticipationUser(
          id: '',
          name: 'Unknown',
          email: '',
          mobile: '',
        );
      }).toList();
    }
    return [];
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'event': eventId,
      'user':
          user != null
              ? {
                '_id': user!.id,
                'name': user!.name,
                'email': user!.email,
                'mobile': user!.mobile,
              }
              : userId, // Fallback to ID string if that's what was there or empty
      'teamMember':
          teamMembers
              .map(
                (member) => {
                  '_id': member.id,
                  'name': member.name,
                  'email': member.email,
                  'mobile': member.mobile,
                },
              )
              .toList(),
      'teamName': teamName,
      'participationType': participationType,
      'registeredAt': registeredAt.toIso8601String(),
      'isPresent': isPresent,
      'markedPresentAt': markedPresentAt?.toIso8601String(),
      'rank': rank,
      'score': score,
      'isQualified': isQualified,
      'remarks': remarks,
      'isPublic': isPublic,
    };
  }
}
