import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shigoto/Components/MyTextFields.dart';
import 'package:shigoto/Controller/ProjectMemberController.dart';
import 'package:shigoto/Model/User_Model.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class TeamMemberScreen extends StatefulWidget {
  final String projectId;

  const TeamMemberScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  State<TeamMemberScreen> createState() => _TeamMemberScreenState();
}

class _TeamMemberScreenState extends State<TeamMemberScreen> {
  final ProjectMemberController _projectMemberController =
      ProjectMemberController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String? projectOwnerId;

  @override
  void initState() {
    super.initState();
    _fetchOwnerId();
  }

  void _fetchOwnerId() async {
    projectOwnerId = await _projectMemberController.getProjectOwnerId(
      widget.projectId,
    );
    setState(() {});
  }

  bool get isOwner => projectOwnerId != null && projectOwnerId == currentUserId;

  void _showAddMemberDialog() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFD6E0FF),
          title: const Text("Add Member"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Mytextfields(
                  label: "Member Email",
                  icon: Icons.email,
                  controller: emailController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();

                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter an email")),
                  );
                  return;
                }
                String res = await _projectMemberController.addMemberByEmail(
                  widget.projectId,
                  email,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(res)));
              },
              child: const Text("Add", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
  Future<Widget> getUserProfilePic(String email) async {
    // Fetch user document from 'users' collection where email matches
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return CircleAvatar(
        radius: 30,
        child: Icon(Icons.person),
      ); // default avatar if no user found
    }

    final userDoc = querySnapshot.docs.first;
    final photoBase64 = userDoc['photoBase64'];

    if (photoBase64 == null || photoBase64.isEmpty) {
      return CircleAvatar(
        radius: 30,
        child: Icon(Icons.person),
      ); // default avatar if no photo
    }

    // Decode Base64 to Uint8List
    Uint8List imageBytes = base64Decode(photoBase64);

    return CircleAvatar(
      radius: 30,
      backgroundImage: MemoryImage(imageBytes),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.only(left: 33),
            child: Text(
              "Team Members",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              height: 500,
              width: 330,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: StreamBuilder<List<UserModel>>(
                stream: _projectMemberController.getProjectMembers(
                  widget.projectId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No members yet"));
                  }

                  final members = snapshot.data!;

                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        child: Dismissible(
                          key: Key(member.userId),
                          direction: isOwner
                              ? DismissDirection.endToStart
                              : DismissDirection.none,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) async {
                            if (isOwner) {
                              await _projectMemberController.removeMember(
                                widget.projectId,
                                member.userId,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${member.username} removed'),
                                ),
                              );
                            }
                          },
                          child: Card(
                            color: const Color(0xFFF5F7FB),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              leading: FutureBuilder<Widget>(
                                future: getUserProfilePic(member.email),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircleAvatar(
                                      radius: 34,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    );
                                  } else if (snapshot.hasError) {
                                    return CircleAvatar(
                                      radius: 34,
                                      child: Icon(Icons.error),
                                    );
                                  } else {
                                    return snapshot.data!;
                                  }
                                },
                              ),
                              title: Text(
                                member.username,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(member.email),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30), // space before button
          if (isOwner) // only owner can see the button
            Center(
              child: ElevatedButton(
                onPressed: _showAddMemberDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4169E1),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Add Member",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20), // bottom padding
        ],
      ),
    );
  }
}
