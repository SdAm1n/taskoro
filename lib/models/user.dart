class AppUser {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? settings;

  AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.settings,
  });

  AppUser copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
  }) {
    return AppUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
    );
  }

  // Method to convert AppUser to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'settings': settings,
    };
  }

  // Method to create AppUser from Map (Firestore)
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      displayName: map['displayName'] ?? '',
      email: map['email'],
      photoUrl: map['photoUrl'],
      createdAt:
          map['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
              : DateTime.now(),
      settings: map['settings'],
    );
  }

  // Create a default/empty user
  factory AppUser.empty() {
    return AppUser(
      id: '',
      displayName: '',
      email: '',
      photoUrl: null,
      createdAt: DateTime.now(),
      settings: {},
    );
  }
}
