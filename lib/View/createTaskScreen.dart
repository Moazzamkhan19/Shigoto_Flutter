import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Controller/TaskController.dart';

class CreateTaskScreen extends StatefulWidget {
  final String projectId;
  final String ownerId;

  const CreateTaskScreen({super.key, required this.projectId, required this.ownerId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final TaskController _taskController = TaskController();

  List<Map<String, String>> assigneeData = [];
  List<String> selectedAssignees = [];

  final Map<String, IconData> statusData = {
    "Pending": Icons.hourglass_bottom_outlined,
    "In Progress": Icons.update_outlined,
    "Completed": Icons.check_circle_outline,
  };
  String? selectedStatus = "Pending";

  final Map<String, int> priorityData = {
    "High": 2,
    "Medium": 1,
    "Low": 0,
  };
  String? selectedPriority = "Medium";

  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    fetchProjectMembers();
  }

  Future<void> fetchProjectMembers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('project_members')
          .where('projectId', isEqualTo: widget.projectId)
          .get();

      final members = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': data['userId']?.toString() ?? '',
          'name': data['userName']?.toString() ?? '',
        };
      }).where((member) => member['uid']!.isNotEmpty && member['name']!.isNotEmpty).toList();

      setState(() => assigneeData = members);
    } catch (e) {
      print("Error fetching members: $e");
    }
  }

  void _selectAssignees() async {
    if (assigneeData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No members found for this project")),
      );
      return;
    }

    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final tempSelected = List<String>.from(selectedAssignees);
        return AlertDialog(
          title: Text("Select Assignees"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                // "All Members" checkbox
                StatefulBuilder(
                  builder: (context, setState) => CheckboxListTile(
                    value: tempSelected.contains('ALL'),
                    title: Text('All Members'),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          tempSelected.clear(); // clear current selections
                          tempSelected.addAll(assigneeData.map((m) => m['uid']!)); // add all member UIDs
                          tempSelected.add('ALL'); // mark 'ALL' selected
                        } else {
                          tempSelected.remove('ALL');
                        }
                      });
                    },
                  ),
                ),
                // Individual members
                ...assigneeData.map((member) {
                  final uid = member['uid']!;
                  final name = member['name']!;
                  return StatefulBuilder(
                    builder: (context, setState) => CheckboxListTile(
                      value: tempSelected.contains(uid),
                      title: Text(name),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) tempSelected.add(uid);
                          else tempSelected.remove(uid);
                          // Uncheck "All" if not all members selected
                          if (tempSelected.contains('ALL') && tempSelected.length - 1 != assigneeData.length) {
                            tempSelected.remove('ALL');
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, selectedAssignees),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempSelected),
              child: Text("OK"),
            ),
          ],
        );
      },
    );

    if (selected != null) setState(() => selectedAssignees = selected);
  }

  void _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => dueDate = picked);
  }

  void _createTask() async {
    if (titleController.text.trim().isEmpty || selectedAssignees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill the title and select assignees")),
      );
      return;
    }

    // If "ALL" selected, assign to all project members
    final assigned = selectedAssignees.contains('ALL')
        ? assigneeData.map((m) => m['uid']!).toList()
        : selectedAssignees;

    final success = await _taskController.addTask(
      projectId: widget.projectId,
      taskName: titleController.text.trim(),
      description: descController.text.trim(),
      status: selectedStatus ?? "Pending",
      priority: priorityData[selectedPriority!]!,
      ownerId: widget.ownerId,
      assignedTo: assigned,
      dueDate: dueDate,
    );

    if (success) Navigator.pop(context);
    else
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create task")),
      );
  }

  Widget buildDropdown<T>(String label, T? value, Map<String, T> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value.toString(),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Task", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.edit_note_outlined),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 15),
            Text("Assignees", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: _selectAssignees,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: Text(selectedAssignees.isEmpty
                  ? "Select Assignees"
                  : "Selected (${selectedAssignees.length})"),
            ),
            SizedBox(height: 15),
            buildDropdown("Status", selectedStatus, statusData, (val) => setState(() => selectedStatus = val)),
            SizedBox(height: 15),
            buildDropdown("Priority", selectedPriority, priorityData.map((k, v) => MapEntry(k, k)), (val) => setState(() => selectedPriority = val)),
            SizedBox(height: 15),
            Text("Due Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: _pickDueDate,
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
              child: Text(dueDate == null
                  ? "Pick Due Date"
                  : "${dueDate!.toLocal().toString().split(" ")[0]}"),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4169E1),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text("Create Task", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }
}
