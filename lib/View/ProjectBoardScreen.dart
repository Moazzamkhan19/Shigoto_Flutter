import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Controller/taskController.dart';
import '../Model/Task_Model.dart';
import 'TaskDetail.dart';
import 'createTaskScreen.dart';
import 'TeamMembersScreen.dart';

class Projectboardscreen extends StatefulWidget {
  final String projectId; // Project ID passed to this screen

  const Projectboardscreen({super.key, required this.projectId});

  @override
  State<Projectboardscreen> createState() => _ProjectboardscreenState();
}

class _ProjectboardscreenState extends State<Projectboardscreen> {
  int _selectedIndex = 0;
  final TaskController _taskController = TaskController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/Dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/Announcement');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/Upcoming');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/Settings');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: null,
        leading: IconButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/Dashboard'),
          icon: Icon(Icons.arrow_back, size: 35),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Project Board ",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 5),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamMemberScreen(
                          projectId: widget.projectId,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.group, size: 30, color: Colors.blueAccent),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Dynamic tasks GridView
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 1,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: StreamBuilder<List<TaskModel>>(
                    stream: _taskController.getProjectTasks(widget.projectId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("No tasks yet"));
                      }

                      final tasks = snapshot.data!;
                      return GridView.builder(
                        itemCount: tasks.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.3, // Old aspect ratio
                        ),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskDetail(task: task,projectId: widget.projectId),
                                ),
                              );
                            },
                            child: _buildCardView(task.taskName),
                          );

                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateTaskScreen(
                            projectId: widget.projectId,
                            ownerId: FirebaseAuth.instance.currentUser!.uid,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4169E1),
                    ),
                    child: Text(
                      "Add New Task",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF4169E1),
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Announcement'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Upcoming'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: Colors.lightBlueAccent,
      ),
    );
  }

  // Old GridView Card UI preserved
  Widget _buildCardView(String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
