import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shigoto/Model/Project_Model.dart';

class Projectcontroller {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //-------------------ADD-PROJECT-------------------------------//

  Future<String> addProject({
    required String projectTitle,
    required String description,
    required DateTime startdate,
    required DateTime enddate,
    required String ownerid,
    required String status,
  }) async {
    try {
      final docRef = _firestore.collection("projects").doc();
      final String autoId = docRef.id;

      ProjectModel project = ProjectModel(
        projectId: autoId,
        ownerId: ownerid,
        projectTitle: projectTitle,
        description: description,
        startDate: startdate,
        endDate: enddate,
        status: status,
      );

      // Save project
      await docRef.set(project.toMap());
      print("Firestore write SUCCESS");

      // Fetch owner username from users collection
      final userDoc = await _firestore.collection('users').doc(ownerid).get();
      final ownerUsername = userDoc.data()?['username'] ?? '';
      print(ownerUsername);

      // ✅ Add owner as a member automatically
      await _firestore.collection('project_members').doc().set({
        'projectId': autoId,
        'userId': ownerid,
        'userName': ownerUsername,
      });

      return autoId;

    } on FirebaseException catch (e) {
      print("FIREBASE ERROR: ${e.message}");
      return e.message ?? "FAILED TO SAVE";
    } catch (e) {
      print("Generic error: $e");
      return e.toString();
    }
  }

  //-------------------REMOVE PROJECT-----------------------//
  Future<String> deleteProject({
    required String userid,
    required String projectid,
  }) async {
    try {
      // DELETE FROM THE SAME COLLECTION YOU READ FROM
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectid)
          .delete();

      await FirebaseFirestore.instance
          .collection('project_members')
          .doc(projectid)
          .delete();

      return "Project deleted";
    } catch (e) {
      return "Error detected : $e";
    }
  }

  //-------------------UPDATE PROJECT----------------------//
  Future<String> updateProject({
    required String projectId,
    String? projectTitle,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (projectTitle != null) updateData['projectTitle'] = projectTitle;
      if (description != null) updateData['description'] = description;
      if (startDate != null) updateData['startDate'] = startDate;
      if (endDate != null) updateData['endDate'] = endDate;
      if (status != null) updateData['status'] = status;

      if (updateData.isEmpty) {
        return "Nothing to update";
      }

      await FirebaseFirestore.instance
          .collection("projects")
          .doc(projectId)
          .update(updateData);

      return "Project updated successfully";
    } catch (e) {
      return "Update error: $e";
    }
  }

  Stream<List<ProjectModel>> getUserProjects(String userId) {
    final projectsStream = FirebaseFirestore.instance
        .collection('projects')
        .snapshots();

    return projectsStream.asyncMap((snapshot) async {
      List<ProjectModel> userProjects = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final project = ProjectModel.fromMap(data);

        // Check if current user is owner
        if (project.ownerId == userId) {
          userProjects.add(project);
          continue;
        }

        // Check if current user is in project_members
        final membersQuery = await FirebaseFirestore.instance
            .collection('project_members')
            .where('projectId', isEqualTo: project.projectId)
            .where('userId', isEqualTo: userId)
            .get();

        if (membersQuery.docs.isNotEmpty) {
          userProjects.add(project);
        }
      }

      return userProjects;
    });
  }
  Future<void> updateProjectAnalytics(String projectId) async {
    final tasksSnapshot = await _firestore
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .get();

    int totalTasks = tasksSnapshot.docs.length;
    int completedTasks = tasksSnapshot.docs
        .where((doc) => doc['status'] == 'Completed')
        .length;

    double percent = totalTasks == 0
        ? 0
        : completedTasks / totalTasks;

    // Save analytics
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('analytics')
        .doc('status')
        .set({
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'percent': percent,
    }, SetOptions(merge: true));
  }






}