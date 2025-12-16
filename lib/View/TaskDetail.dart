import 'package:flutter/material.dart';
import 'package:shigoto/Controller/ProjectController.dart';
import '../Controller/taskController.dart';
import '../Model/Task_Model.dart';

class TaskDetail extends StatefulWidget {
  final TaskModel task;
  final String projectId;

  const TaskDetail({
    super.key,
    required this.task,
    required this.projectId,
  });

  @override
  State<TaskDetail> createState() => _TaskDetailState(); // <-- MUST HAVE THIS
}
class _TaskDetailState extends State<TaskDetail> {
  final TaskController _taskController = TaskController();
  Map<String, String>? userNames;
  String? selectedAssignee;
  int _selectedIndex = 0;

  // Local editable task
  late TaskModel _editableTask;

  @override
  void initState() {
    super.initState();
    _editableTask = widget.task; // Initialize editable task
    _loadUserNames();
  }

  void _loadUserNames() async {
    List<String> ids = [_editableTask.ownerId, ..._editableTask.assignedTo];
    final namesMap = await _taskController.getUserNames(ids);
    setState(() {
      userNames = namesMap;
      if (_editableTask.assignedTo.isNotEmpty) {
        selectedAssignee = namesMap[_editableTask.assignedTo.first];
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/Dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/Upcoming');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/Settings');
        break;
    }
  }

  String getPriorityText(int priority) {
    switch (priority) {
      case 0:
        return "Low";
      case 1:
        return "Intermediate";
      case 2:
        return "High";
      default:
        return "Unknown";
    }
  }

  void _showAssigneesDialog(List<String> assignees) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Assigned Users",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: assignees.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blueAccent),
                      const SizedBox(width: 10),
                      Text(
                        assignees[index],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // ---------------- Edit Task Dialog ----------------
  void _showEditTaskDialog() {
    Projectcontroller projectcontroller=Projectcontroller();
    final TextEditingController nameController =
    TextEditingController(text: _editableTask.taskName);
    final TextEditingController descriptionController =
    TextEditingController(text: _editableTask.description);
    DateTime? selectedDueDate = _editableTask.dueDate;
    int selectedPriority = _editableTask.priority;
    String selectedStatus = _editableTask.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit Task",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Task Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: "Priority"),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text("Low")),
                    DropdownMenuItem(value: 1, child: Text("Intermediate")),
                    DropdownMenuItem(value: 2, child: Text("High")),
                  ],
                  onChanged: (value) {
                    selectedPriority = value!;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: "Status"),
                  items: const [
                    DropdownMenuItem(value: "Pending", child: Text("Pending")),
                    DropdownMenuItem(
                        value: "In Progress", child: Text("In Progress")),
                    DropdownMenuItem(
                        value: "Completed", child: Text("Completed")),
                  ],
                  onChanged: (value) {
                    selectedStatus = value!;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Due Date: "),
                    TextButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDueDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                          "${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await _taskController.updateTask(
                  projectId: widget.projectId,
                  taskId: _editableTask.taskId,
                  taskName: nameController.text,
                  description: descriptionController.text,
                  status: selectedStatus,
                  priority: selectedPriority,
                  assignedTo: _editableTask.assignedTo,
                  dueDate: selectedDueDate,
                );

                if (success) {
                  setState(() {
                    // Replace editable task with updated version
                    _editableTask = TaskModel(
                      taskId: _editableTask.taskId,
                      projectId: _editableTask.projectId,
                      taskName: nameController.text,
                      description: descriptionController.text,
                      status: selectedStatus,
                      priority: selectedPriority,
                      ownerId: _editableTask.ownerId,
                      assignedTo: _editableTask.assignedTo,
                      dueDate: selectedDueDate!,
                    );
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to update task")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userNames == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final ownerName = userNames![_editableTask.ownerId] ?? _editableTask.ownerId;
    final assigneeNames = _editableTask.assignedTo
        .map((id) => userNames![id] ?? id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: null,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 35),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: const [
                Icon(Icons.task, size: 38, color: Colors.blueAccent),
                SizedBox(width: 10),
                Text(
                  "Task Detail",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Task Card
            Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Title
                    Text(
                      "Task Name: ${_editableTask.taskName}",
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    // Status & Priority
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_editableTask.status,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                              "Priority: ${getPriorityText(_editableTask.priority)}",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Description
                    Text("Description:",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(_editableTask.description,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 25),
                    // Owner
                    Row(
                      children: [
                        const Text("Created By: ",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(ownerName, style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Assignees
                    Row(
                      children: [
                        const Text("Assignees: ",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _showAssigneesDialog(assigneeNames),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 18),
                          ),
                          child: const Text(
                            "View",
                            style:
                            TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Due Date
                    Row(
                      children: [
                        const Text("Due Date: ",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(
                            "${_editableTask.dueDate.day}/${_editableTask.dueDate.month}/${_editableTask.dueDate.year}",
                            style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Buttons
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _showEditTaskDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade300,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                          ),
                          child: const Text("Edit Task",style: TextStyle(color: Colors.black),),
                        ),
                        const SizedBox(width: 20),

                      ],
                    ),
                  ],
                ),
              ),
            ),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Upcoming'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: Colors.lightBlueAccent,
      ),
    );
  }
}
