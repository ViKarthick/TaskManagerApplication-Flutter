import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTaskScreen extends StatefulWidget {
  final String userEmail;
  final String taskId;
  final String taskName;
  final String taskDescription;
  final DateTime lastDate;
  final String priority1;
  final String completion;
  const EditTaskScreen({super.key,
    required this.userEmail,
    required this.taskId,
    required this.taskName,
    required this.taskDescription,
    required this.lastDate,
    required this.priority1,
    required this.completion,
  });

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen>
{
  late TextEditingController _taskNameController;
  late TextEditingController _taskDescriptionController;
  late DateTime _selectedDate;
  late String _selectedPriority;
  late String _completionState;
  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.taskName);
    _taskDescriptionController = TextEditingController(text: widget.taskDescription);
    _selectedDate = widget.lastDate;
    _selectedPriority = widget.priority1;
    _completionState = widget.completion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _taskNameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
              enabled: _isTaskNameEditable(),
            ),
            TextFormField(
              controller: _taskDescriptionController,
              decoration: const InputDecoration(labelText: 'Task Description'),
              enabled: _isTaskDescriptionEditable(),
            ),
            const SizedBox(height: 16.0),
            Text('Last Date: ${_selectedDate.toString()}'), // Display the selected date
            ElevatedButton(
              onPressed: _selectDate,
              child: const Text('Select Date'),
            ),
            DropdownButton<String>(
              value: _selectedPriority,
              onChanged: _isPriorityEditable() ? (String? newValue) {
                setState(() {
                    _selectedPriority = newValue!;
                });
              } : null,
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
            const SizedBox(height: 16.0),
            Text('Completion State: ${_completionState.toString()}'), // Display the selected date
            DropdownButton<String>(
              value: _completionState,
              onChanged: (String? newValue) {
                setState(() {
                  _completionState = newValue!;
                });
              },
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'Incomplete',
                  child: Text('Incomplete'),
                ),
                DropdownMenuItem<String>(
                  value: 'Completed',
                  child: Text('Complete'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isTaskNameEditable() {
    return widget.priority1 != 'High';
  }

  bool _isTaskDescriptionEditable() {
    return widget.priority1 != 'High' && widget.priority1 != 'Medium';
  }

  bool _isPriorityEditable() {
    return widget.priority1 != 'High';
  }

  bool _isDateEditable()
  {
    return widget.priority1 != 'High' && widget.priority1 != 'Medium';
  }

  void _selectDate() async
  {
    if(_isDateEditable())
    {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null && pickedDate != _selectedDate) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    }
  }

  void _saveChanges() async {
    // Implement logic to save changes to Firestore
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('users').doc(widget.userEmail).collection('tasks').doc(widget.taskId).update({
        'taskName': _taskNameController.text,
        'taskDescription': _taskDescriptionController.text,
        'lastDate': _selectedDate,
        'priority1': _selectedPriority,
        'priority': _selectedPriority == 'High' ? 3 : _selectedPriority == 'Medium' ? 2 : 1,
        'completion':_completionState,
      });
      Navigator.pop(context); // Navigate back after saving changes
    } catch (e) {
      print('Error updating task: $e');
    }
  }
}
