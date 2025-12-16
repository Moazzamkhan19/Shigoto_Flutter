import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/User_Model.dart';

class ProjectMemberController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all members of a project
  Stream<List<UserModel>> getProjectMembers(String projectId) {
    return _firestore
        .collection('project_members')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<UserModel> members = [];
      for (var doc in snapshot.docs) {
        final userId = doc['userId'];

        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (!userDoc.exists) continue;
        members.add(UserModel.fromMap(userDoc.data()!));
      }
      return members;
    });
  }

  /// Add a member to project by email and store name as well
  Future<String> addMemberByEmail(String projectId, String email) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) return "User not found";

      final userDoc = userQuery.docs.first;
      final userId = userDoc['userId'];
      final userName = userDoc['username'] ?? "";  // <-- FIXED HERE

      // Check if already a member
      final existing = await _firestore
          .collection('project_members')
          .where('projectId', isEqualTo: projectId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return "User already a member";

      await _firestore.collection('project_members').doc().set({
        'projectId': projectId,
        'userId': userId,
        'userName': userName,
      });

      return "Member added successfully";
    } catch (e) {
      print(e);
      return "Error: $e";
    }
  }


  /// Remove a member from project
  Future<void> removeMember(String projectId, String userId) async {
    final query = await _firestore
        .collection('project_members')
        .where('projectId', isEqualTo: projectId)
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in query.docs) {
      await _firestore.collection('project_members').doc(doc.id).delete();
    }
  }

  Future<String?> getProjectOwnerId(String projectId) async {
    try {
      final doc = await _firestore.collection('projects').doc(projectId).get();
      if (!doc.exists) return null;
      return doc['ownerId'] as String?;
    } catch (e) {
      print("Error fetching ownerId: $e");
      return null;
    }
  }
}
