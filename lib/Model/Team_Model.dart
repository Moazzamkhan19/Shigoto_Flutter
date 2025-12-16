class TeamMemberModel {
  final String userId; // uid from FirebaseAuth
  final String username;
  final String projectId;
  final String role; // optional: member, admin, owner

  TeamMemberModel({
    required this.userId,
    required this.username,
    required this.projectId,
    this.role = "member",
  });

  factory TeamMemberModel.fromMap(Map<String, dynamic> map) {
    return TeamMemberModel(
      userId: map['userId'],
      username: map['username'],
      projectId: map['projectId'],
      role: map['role'] ?? "member",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'projectId': projectId,
      'role': role,
    };
  }
}
