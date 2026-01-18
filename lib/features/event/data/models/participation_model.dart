import '../../domain/entities/participation_entity.dart';

/// Participation model for data layer
class ParticipationModel extends ParticipationEntity {
  const ParticipationModel({
    required super.id,
    required super.eventId,
    required super.userId,
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
  });

  /// Create from JSON
  factory ParticipationModel.fromJson(Map<String, dynamic> json) {
    return ParticipationModel(
      id: json['_id'] ?? json['id'] ?? '',
      eventId: json['event'] is Map
          ? (json['event']['_id'] ?? '')
          : (json['event'] ?? ''),
      userId: json['user'] is Map
          ? (json['user']['_id'] ?? '')
          : (json['user'] ?? ''),
      teamMembers: json['teamMember'] != null
          ? List<String>.from(json['teamMember'])
          : [],
      teamName: json['teamName'],
      participationType: json['participationType'] ?? 'INDIVIDUAL',
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'])
          : DateTime.now(),
      isPresent: json['isPresent'] ?? false,
      markedPresentAt: json['markedPresentAt'] != null
          ? DateTime.parse(json['markedPresentAt'])
          : null,
      rank: json['rank'],
      score: json['score'] ?? 0,
      isQualified: json['isQualified'] ?? false,
      remarks: json['remarks'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'event': eventId,
      'user': userId,
      'teamMember': teamMembers,
      'teamName': teamName,
      'participationType': participationType,
      'registeredAt': registeredAt.toIso8601String(),
      'isPresent': isPresent,
      'markedPresentAt': markedPresentAt?.toIso8601String(),
      'rank': rank,
      'score': score,
      'isQualified': isQualified,
      'remarks': remarks,
    };
  }
}
