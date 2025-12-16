import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final String projectId;
  final String taskName;
  final String status; // pending, in_progress, completed
  final String description;
  final DateTime dueDate;
  final int priority; // 0 = low, 1 = medium, 2 = high
  final String ownerId;
  final List<String> assignedTo; // List of user IDs


  TaskModel({
    required this.taskId,
    required this.projectId,
    required this.taskName,
    required this.status,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.ownerId,
    required this.assignedTo,

  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      taskId: map['taskId'] ?? '',
      projectId: map['projectId'] ?? '',
      taskName: map['taskName'] ?? '',
      status: map['status'] ?? 'Pending',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      priority: map['priority'] ?? 0,
      ownerId: map['ownerId'] ?? '',
      assignedTo: List<String>.from(map['assignedTo'] ?? []),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'projectId': projectId,
      'taskName': taskName,
      'status': status,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'ownerId': ownerId,
      'assignedTo': assignedTo,
    };
  }
}
