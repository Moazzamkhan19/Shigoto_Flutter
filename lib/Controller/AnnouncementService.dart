import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shigoto/Model/Annoucement.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collectionName = "announcements";

  /// ------------------ ADD ANNOUNCEMENT ------------------ ///
  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(announcement.announcementId)
          .set(announcement.toMap());

      print("Announcement added successfully.");
    } catch (e) {
      print("Error adding announcement: $e");
    }
  }

  /// ------------------ GET ANNOUNCEMENTS (STREAM) ------------------ ///
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _firestore
        .collection(collectionName)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromMap(doc.data()))
          .toList();
    });
  }
}
