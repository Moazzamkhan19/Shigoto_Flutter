import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String projectId;
  final String ownerId;
  final String projectTitle;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;



  ProjectModel({
    required this.projectId,
    required this.ownerId,
    required this.projectTitle,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
  /// Convert Firestore map → Model
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      projectId: map['projectId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      projectTitle: map['projectTitle'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: map['status'] ?? '',
    );
  }

  /// Convert Model → Firestore map
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'ownerId': ownerId,
      'projectTitle': projectTitle,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
    };
  }
}

