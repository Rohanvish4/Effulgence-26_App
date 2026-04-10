class PublicTeamEntity {
  final String id;
  final String teamName;
  final List<TeamMemberEntity> members;
  final DateTime registeredAt;

  const PublicTeamEntity({
    required this.id,
    required this.teamName,
    required this.members,
    required this.registeredAt,
  });

  // Computed properties
  int get memberCount => members.length;

  bool canJoin(int maxTeamSize) => memberCount < maxTeamSize;

  bool isMember(String userId) => members.any((m) => m.userId == userId);
}

class TeamMemberEntity {
  final String userId;
  final String name;
  final String? email;
  final String? imageUrl;

  const TeamMemberEntity({
    required this.userId,
    required this.name,
    this.email,
    this.imageUrl,
  });

  // Helper to get display initials
  String get initials {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return '??';

    final parts = trimmedName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '??';

    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    final singlePart = parts.first;
    final length = singlePart.length >= 2 ? 2 : 1;
    return singlePart.substring(0, length).toUpperCase();
  }
}
