
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of all tasks
  Stream<QuerySnapshot> getTasksStream() {
    return _firestore.collection('tasks')
        .orderBy('dueDate') // optional, to show upcoming first
        .snapshots();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
      case 'not started':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Tasks"),
        centerTitle: true,
        backgroundColor: const Color(0xFF4169E1),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/Dashboard');
          },
          icon: const Icon(Icons.arrow_back, size: 30),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No upcoming tasks."));
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index].data() as Map<String, dynamic>;

              final String taskName = task['taskName'] ?? '';
              final String description = task['description'] ?? '';
              final String projectId = task['projectId'] ?? '';
              final String status = task['status'] ?? '';
              final Timestamp dueDateTs = task['dueDate'];
              final dueDate = dueDateTs.toDate();

              return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: const Color(0xFFEAF0FF),
                  margin: const EdgeInsets.only(bottom: 15),
                  child:ListTile(
                    title: Text(taskName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: getProjectName(projectId),
                          builder: (context, snapshot) {
                            final projectName =
                            snapshot.connectionState == ConnectionState.done && snapshot.hasData
                                ? snapshot.data
                                : 'Loading project...';
                            return Text("Project: $projectName");
                          },
                        ),
                        Text("Due: ${dueDate.day}-${dueDate.month}-${dueDate.year}"),
                        Text(
                          "Status: $status",
                          style: TextStyle(
                            color: getStatusColor(status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )

              );
            },
          );
        },
      ),
    );
  }
  Future<String> getProjectName(String projectId) async {
    final doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      return data['projectTitle'] ?? 'Unknown Project';
    }
    return 'Unknown Project';
  }

}

