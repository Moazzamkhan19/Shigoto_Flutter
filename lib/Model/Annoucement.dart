import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String announcementId;
  final String userId;
  final String message;
  final DateTime createdAt;

  AnnouncementModel({
    required this.announcementId,
    required this.userId,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "announcementId": announcementId,
      "userId": userId,
      "message": message,
      "createdAt": createdAt,
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      announcementId: map["announcementId"],
      userId: map["userId"],
      message: map["message"],
      createdAt: (map["createdAt"] as Timestamp).toDate(),
    );
  }
}

