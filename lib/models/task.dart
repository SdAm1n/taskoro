enum TaskPriority { low, medium, high }

enum TaskCategory { personal, work, shopping, health, study, other }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final TaskPriority priority;
  final TaskCategory category;
  final bool isCompleted;
  final DateTime createdAt;
  final List<String>? subtasks;
  final String? assignedTeamId;
  final List<String>? assignedMemberIds;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? locationAddress;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.subtasks,
    this.assignedTeamId,
    this.assignedMemberIds,
    this.latitude,
    this.longitude,
    this.locationName,
    this.locationAddress,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TaskPriority? priority,
    TaskCategory? category,
    bool? isCompleted,
    DateTime? createdAt,
    List<String>? subtasks,
    String? assignedTeamId,
    List<String>? assignedMemberIds,
    double? latitude,
    double? longitude,
    String? locationName,
    String? locationAddress,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      assignedMemberIds: assignedMemberIds ?? this.assignedMemberIds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
    );
  }

  // Method to convert Task to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'priority': priority.toString().split('.').last,
      'category': category.toString().split('.').last,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'subtasks': subtasks,
      'assignedTeamId': assignedTeamId,
      'assignedMemberIds': assignedMemberIds,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'locationAddress': locationAddress,
    };
  }

  // Method to create Task from Map (Firestore)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => TaskCategory.other,
      ),
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      subtasks:
          map['subtasks'] != null ? List<String>.from(map['subtasks']) : null,
      assignedTeamId: map['assignedTeamId'],
      assignedMemberIds:
          map['assignedMemberIds'] != null
              ? List<String>.from(map['assignedMemberIds'])
              : null,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      locationName: map['locationName'],
      locationAddress: map['locationAddress'],
    );
  }

  // Method to format priority as a string
  String getPriorityString() {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  // Method to format category as a string
  String getCategoryString() {
    switch (category) {
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.shopping:
        return 'Shopping';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.study:
        return 'Study';
      case TaskCategory.other:
        return 'Other';
    }
  }

  // Helper method to check if task is assigned to a team
  bool get isTeamTask => assignedTeamId != null;

  // Helper method to check if task is assigned to specific members
  bool get isAssignedToMembers =>
      assignedMemberIds != null && assignedMemberIds!.isNotEmpty;

  // Helper method to check if task is assigned to a specific member
  bool isAssignedToMember(String memberId) =>
      assignedMemberIds?.contains(memberId) ?? false;

  // Helper method to check if task has location
  bool get hasLocation => latitude != null && longitude != null;

  // Helper method to get formatted location
  String get formattedLocation {
    if (locationName != null && locationName!.isNotEmpty) {
      return locationName!;
    } else if (locationAddress != null && locationAddress!.isNotEmpty) {
      return locationAddress!;
    } else if (hasLocation) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    } else {
      return 'No location set';
    }
  }
}
