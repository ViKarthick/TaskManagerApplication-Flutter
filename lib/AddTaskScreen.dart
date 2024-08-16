import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
              ),
            ),
            const SizedBox(height: 16.0), // Adding spacing here
            TextField(
              controller: _taskDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Task Description',
              ),
            ),
            const SizedBox(height: 16.0), // Adding spacing here
            const Text('Select Last Date:'),
            ElevatedButton(
              onPressed: () {
                _selectDate(context);
              },
              child: Text(_selectedDate != null ? _selectedDate.toString() : 'Choose a Date'),
            ),
            const SizedBox(height: 16.0), // Adding spacing here
            const Text('Select Priority:'),
            DropdownButton<String>(
              value: _selectedPriority,
              onChanged: (String? newValue) {
                setState(() {
                  // If newValue is null, treat it as a special case to clear the selection
                  if (newValue == null) {
                    _selectedPriority = null;
                  } else {
                    _selectedPriority = newValue;
                  }
                });
              },
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('Select'),
                ),
                DropdownMenuItem<String>(
                  value: 'High',
                  child: Text('High'),
                ),
                DropdownMenuItem<String>(
                  value: 'Medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem<String>(
                  value: 'Low',
                  child: Text('Low'),
                ),
              ],
            ),
            const SizedBox(height: 16.0), // Adding spacing here
            ElevatedButton(
              onPressed: () {
                _addTask(context);
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTask(BuildContext context) async {
    final String? userEmail = FirebaseAuth.instance.currentUser!.email;
    final String taskName = _taskNameController.text.trim();
    final String taskDescription = _taskDescriptionController.text.trim();

    // Check if any field is empty or if priority is not selected
    if (taskName.isEmpty ||
        taskDescription.isEmpty ||
        _selectedPriority == null ||
        _selectedDate == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please fill all fields.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the method
    }

    // Check if priority is 'Select'
    if (_selectedPriority == 'Select') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please choose a correct priority.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the method
    }

    // Check if task with the same name already exists
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('tasks')
        .where('taskName', isEqualTo: taskName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Task with the same name already exists
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Task with the same name already exists.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the method
    }

    // Task with the same name doesn't exist, all fields are filled, and priority is not 'Select', proceed to add the task
    try {
      await FirebaseFirestore.instance.collection('users').doc(userEmail).collection('tasks').add({
        'taskName': taskName,
        'taskDescription': taskDescription,
        'lastDate': Timestamp.fromDate(_selectedDate!),
        'priority1': _selectedPriority,
        'priority': _selectedPriority == 'High' ? 3 : _selectedPriority == 'Medium' ? 2 : 1,
        'completion': 'Incomplete',
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error adding task: $e');
    }
  }

}