import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/AllTasksScreen.dart';
import 'package:untitled/CompletedTasksScreen.dart';
import 'package:untitled/LoginScreen.dart';
import 'AddTaskScreen.dart';
import 'ToDoList.dart';


class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'all_tasks',
                  child: Text('All Tasks'),
                ),
                const PopupMenuItem(
                  value: 'completed_tasks',
                  child: Text('Completed Tasks'),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Log Out'),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 'all_tasks')
              {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const AllTasksScreen()));
              }
              else if (value == 'completed_tasks')
              {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const CompletedTasksScreen()));
              } else if (value == 'logout') {
                _logout(context);
              }
            },
          ),
        ],
      ),
      body: const TodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }
}