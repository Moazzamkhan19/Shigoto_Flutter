import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Task_Model.dart';
import 'package:shigoto/Controller/ProjectController.dart';

class TaskController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String tasksCollection = 'tasks';
  Projectcontroller projectcontroller=Projectcontroller();

  Future<bool> addTask({
    required String projectId,
    required String taskName,
    required String description,
    required String status,
    required int priority,
    required String ownerId,
    required List<String> assignedTo,
    DateTime? dueDate,
  }) async {
    try {
      final taskDoc = _firestore.collection(tasksCollection).doc();
      final taskId = taskDoc.id;

      final task = TaskModel(
        taskId: taskId,
        projectId: projectId,
        taskName: taskName,
        status: status,
        description: description,
        dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
        priority: priority,
        ownerId: ownerId,
        assignedTo: assignedTo,
      );

      // 1. Add task
      await taskDoc.set(task.toMap());

      // 2. Update analytics (✔ correct place)
      Projectcontroller().updateProjectAnalytics(projectId);

      return true;
    } catch (e) {
      print('Error adding task: $e');
      return false;
    }
  }

  Stream<List<TaskModel>>? getProjectTasks(String projectId) {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.data()))
        .toList());
  }

  Future<Map<String, String>> getUserNames(List<String> userIds) async {
    Map<String, String> userMap = {};
    for (var id in userIds) {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        userMap[id] = doc.data()?['username'] ?? 'Unknown';
      } else {
        userMap[id] = 'Unknown';
      }
    }
    return userMap;
  }
  Future<bool> updateTask({
    required String taskId,
    required String projectId,
    required String taskName,
    required String description,
    required String status,
    required int priority,
    required List<String> assignedTo,
    required DateTime? dueDate,
  }) async {
    try {
      final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);

      // 1. Get old status
      final oldTaskSnapshot = await taskRef.get();
      final oldStatus = oldTaskSnapshot['status'];

      // 2. Update the task fields
      await taskRef.update({
        'taskName': taskName,
        'description': description,
        'status': status,
        'priority': priority,
        'assignedTo': assignedTo,
        'dueDate': dueDate,
      });

      // 3. If status changed → update counters
      if (oldStatus != status) {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(projectId)
            .update({
          'totalTasks': FieldValue.increment(0), // unchanged
          if (oldStatus == "Not Started") 'notStartedTasks': FieldValue.increment(-1),
          if (oldStatus == "In Progress") 'inProgressTasks': FieldValue.increment(-1),
          if (oldStatus == "Completed") 'completedTasks': FieldValue.increment(-1),

          if (status == "Not Started") 'notStartedTasks': FieldValue.increment(1),
          if (status == "In Progress") 'inProgressTasks': FieldValue.increment(1),
          if (status == "Completed") 'completedTasks': FieldValue.increment(1),
        });
      }

      return true;
    } catch (e) {
      print("Task update failed: $e");
      return false;
    }
  }
  Stream<Map<String, dynamic>> getProjectCompletion(String projectId) {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      int total = snapshot.docs.length;
      int completed = snapshot.docs.where((doc) => doc['isCompleted'] == true).length;

      double percent = total == 0 ? 0.0 : completed / total;

      return {
        "total": total,
        "completed": completed,
        "percent": percent,
      };
    });
  }

  Stream<List<TaskModel>> getAllUserTasks(String userId) {
    return FirebaseFirestore.instance
        .collection("tasks")
        .where("userId", isEqualTo: userId)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => TaskModel.fromMap(doc.data())).toList());
  }

  Future<bool> removeTask(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .delete();
      return true;
    } catch (e) {
      print("Failed to remove task: $e");
      return false;
    }
  }



}
