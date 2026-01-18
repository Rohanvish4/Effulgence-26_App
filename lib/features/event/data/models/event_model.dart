import '../../domain/entities/event_entity.dart';

/// Event model for data layer
class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    super.coverImage,
    super.description,
    super.rules,
    required super.domain,
    super.eventRound,
    required super.eventType,
    super.teamConfig,
    required super.eventVenue,
    required super.eventTime,
    required super.registrationDeadline,
    required super.status,
    super.createdAt,
    super.updatedAt,
    super.endTime,
    required super.isDeleted,
  });

  /// Create from JSON
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      coverImage: json['coverImage'],
      description: json['description'],
      rules: json['rules'],
      domain: json['domain'] ?? '',
      eventRound: json['eventRound'] ?? 1,
      eventType: json['eventType'] ?? 'INDIVIDUAL',
      teamConfig: json['teamConfig'] != null
          ? TeamConfig(
              minSize: json['teamConfig']['minSize'] ?? 1,
              maxSize: json['teamConfig']['maxSize'] ?? 10,
            )
          : null,
      eventVenue: json['eventVenue'] ?? '',
      eventTime: json['eventTime'] != null
          ? DateTime.parse(json['eventTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null,
      registrationDeadline: json['registrationDeadline'] != null
          ? DateTime.parse(json['registrationDeadline'])
          : DateTime.now(),
      status: json['status'] ?? 'UPCOMING',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'coverImage': coverImage,
      'description': description,
      'rules': rules,
      'domain': domain,
      'eventRound': eventRound,
      'eventType': eventType,
      'teamConfig': teamConfig != null
          ? {'minSize': teamConfig!.minSize, 'maxSize': teamConfig!.maxSize}
          : null,
      'eventVenue': eventVenue,
      'eventTime': eventTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'status': status,
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with
  EventModel copyWith({
    String? id,
    String? title,
    String? coverImage,
    String? description,
    String? rules,
    String? domain,
    int? eventRound,
    String? eventType,
    TeamConfig? teamConfig,
    String? eventVenue,
    DateTime? eventTime,
    DateTime? endTime,
    DateTime? registrationDeadline,
    String? status,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      domain: domain ?? this.domain,
      eventRound: eventRound ?? this.eventRound,
      eventType: eventType ?? this.eventType,
      teamConfig: teamConfig ?? this.teamConfig,
      eventVenue: eventVenue ?? this.eventVenue,
      eventTime: eventTime ?? this.eventTime,
      endTime: endTime ?? this.endTime,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
