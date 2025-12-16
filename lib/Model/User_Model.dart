class UserModel {
  final String userId;
  final String username;
  final String email;
  final String? photoBase64;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.photoBase64,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'],
      username: map['username'],
      email: map['email'],
      photoBase64: map['photoBase64'], // ✅ FIXED
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'photoBase64': photoBase64,
    };
  }
}

