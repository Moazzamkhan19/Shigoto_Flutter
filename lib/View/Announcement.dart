import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Components/MyTextFields.dart';
import 'package:shigoto/Model/Annoucement.dart';
import 'package:shigoto/Controller/AnnouncementService.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final AnnouncementService _service = AnnouncementService();

  void _AnnoucementDialogBox() {
    TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFD6E0FF),
          title: const Text("Do An Announcement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Mytextfields(
                label: "Enter Announcement",
                controller: messageController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                if (messageController.text.trim().isEmpty) return;

                final user = FirebaseAuth.instance.currentUser;

                final announcement = AnnouncementModel(
                  announcementId: FirebaseFirestore.instance.collection("announcements").doc().id,
                  userId: user!.uid,
                  message: messageController.text.trim(),
                  createdAt: DateTime.now(),
                );

                await _service.addAnnouncement(announcement);

                Navigator.pop(context);
              },
              child: const Text("Done", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // 🔥 Fetch username for each announcement
  Future<String> getUserName(String userId) async {
    final snap = await FirebaseFirestore.instance.collection("users").doc(userId).get();
    if (snap.exists) {
      return snap.data()!["username"] ?? "Unknown User";
    }
    return "Unknown User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 35),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<AnnouncementModel>>(
          stream: _service.getAnnouncements(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4169E1)),
              );
            }

            final announcements = snapshot.data!;

            return ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final ann = announcements[index];

                return FutureBuilder<String>(
                  future: getUserName(ann.userId),
                  builder: (context, userSnap) {
                    final userName = userSnap.data ?? "Loading...";

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: const Color(0xFFEAF0FF),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        title: Text(
                          ann.message,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "By: $userName",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ann.createdAt.toString(),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _AnnoucementDialogBox,
        backgroundColor: const Color(0xFF4169E1),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}


