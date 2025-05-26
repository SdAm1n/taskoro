enum TeamRole { owner, admin, member }

class Team {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<TeamMember> members;
  final DateTime createdAt;
  final DateTime updatedAt;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  Team copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<TeamMember>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Method to convert Team to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'members': members.map((member) => member.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Method to create Team from Map (Firestore)
  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      ownerId: map['ownerId'],
      members:
          map['members'] != null
              ? List<TeamMember>.from(
                map['members'].map((member) => TeamMember.fromMap(member)),
              )
              : [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // Get member count
  int get memberCount => members.length;

  // Check if user is owner
  bool isOwner(String userId) => ownerId == userId;

  // Check if user is admin or owner
  bool isAdminOrOwner(String userId) {
    if (isOwner(userId)) return true;
    return members.any(
      (member) => member.userId == userId && member.role == TeamRole.admin,
    );
  }

  // Get member by user ID
  TeamMember? getMember(String userId) {
    try {
      return members.firstWhere((member) => member.userId == userId);
    } catch (e) {
      return null;
    }
  }
}

class TeamMember {
  final String userId;
  final String email;
  final String displayName;
  final TeamRole role;
  final DateTime joinedAt;
  final bool isActive;

  TeamMember({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.joinedAt,
    this.isActive = true,
  });

  TeamMember copyWith({
    String? userId,
    String? email,
    String? displayName,
    TeamRole? role,
    DateTime? joinedAt,
    bool? isActive,
  }) {
    return TeamMember(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Method to convert TeamMember to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'role': role.toString().split('.').last,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  // Method to create TeamMember from Map (Firestore)
  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      userId: map['userId'],
      email: map['email'],
      displayName: map['displayName'],
      role: TeamRole.values.firstWhere(
        (role) => role.toString().split('.').last == map['role'],
        orElse: () => TeamRole.member,
      ),
      joinedAt: DateTime.fromMillisecondsSinceEpoch(map['joinedAt']),
      isActive: map['isActive'] ?? true,
    );
  }

  // Get role display name
  String getRoleDisplayName() {
    switch (role) {
      case TeamRole.owner:
        return 'Owner';
      case TeamRole.admin:
        return 'Admin';
      case TeamRole.member:
        return 'Member';
    }
  }
}

// Team invitation model for email invites
class TeamInvitation {
  final String id;
  final String teamId;
  final String teamName;
  final String inviterUserId;
  final String inviterName;
  final String inviteeEmail;
  final TeamRole role;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isAccepted;
  final bool isExpired;

  TeamInvitation({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.inviterUserId,
    required this.inviterName,
    required this.inviteeEmail,
    required this.role,
    required this.createdAt,
    required this.expiresAt,
    this.isAccepted = false,
    this.isExpired = false,
  });

  TeamInvitation copyWith({
    String? id,
    String? teamId,
    String? teamName,
    String? inviterUserId,
    String? inviterName,
    String? inviteeEmail,
    TeamRole? role,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isAccepted,
    bool? isExpired,
  }) {
    return TeamInvitation(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      inviterUserId: inviterUserId ?? this.inviterUserId,
      inviterName: inviterName ?? this.inviterName,
      inviteeEmail: inviteeEmail ?? this.inviteeEmail,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isAccepted: isAccepted ?? this.isAccepted,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  // Method to convert TeamInvitation to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamId': teamId,
      'teamName': teamName,
      'inviterUserId': inviterUserId,
      'inviterName': inviterName,
      'inviteeEmail': inviteeEmail,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'isAccepted': isAccepted,
      'isExpired': isExpired,
    };
  }

  // Method to create TeamInvitation from Map (Firestore)
  factory TeamInvitation.fromMap(Map<String, dynamic> map) {
    return TeamInvitation(
      id: map['id'],
      teamId: map['teamId'],
      teamName: map['teamName'],
      inviterUserId: map['inviterUserId'],
      inviterName: map['inviterName'],
      inviteeEmail: map['inviteeEmail'],
      role: TeamRole.values.firstWhere(
        (role) => role.toString().split('.').last == map['role'],
        orElse: () => TeamRole.member,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt']),
      isAccepted: map['isAccepted'] ?? false,
      isExpired: map['isExpired'] ?? false,
    );
  }

  // Check if invitation is still valid
  bool get isValid =>
      !isAccepted && !isExpired && DateTime.now().isBefore(expiresAt);
}
