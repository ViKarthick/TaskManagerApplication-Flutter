import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'EditTaskScreen.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});
  @override
  Widget build(BuildContext context) {
    final String? userEmail = FirebaseAuth.instance.currentUser!.email;
    FirebaseFirestore db = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
      stream:
      db.collection('users')
          .doc(userEmail)
          .collection('tasks')
          .orderBy('priority', descending: true)
          .orderBy('lastDate').snapshots()
      ,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data?.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot task = snapshot.data!.docs[index];
            Timestamp timestamp = task['lastDate'];
            DateTime dateTime = timestamp.toDate();
            String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
            if(task['completion'] == 'Incomplete')
            {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ListTile(
                      title: Text(
                        task['taskName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          Text(
                            'Description: ${task['taskDescription']}',
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Priority: ${task['priority1']}',
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Last Date: $formattedDate',
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Completion Status: ${task['completion']}',
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit button
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditTaskScreen(
                                        userEmail: userEmail!,
                                        taskId: task.id,
                                        taskName: task['taskName'],
                                        taskDescription: task['taskDescription'],
                                        lastDate: task['lastDate'].toDate(),
                                        priority1: task['priority1'],
                                        completion: task['completion'],
                                      ),
                                ),
                              );
                            },
                          ),
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteTask(context, userEmail!, task.id,
                                  task['taskName']);
                            },
                          ),
                        ],
                      )
                  ),
                ),
              );
            }else {
              return Container(); // Or any other widget you want to return for complete tasks
            }
            return null;
          },
        );
      },
    );
  }
  Future<void> _deleteTask(BuildContext context, String userEmail, String taskId, String taskName) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Do you really want to delete the task $taskName?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to indicate cancel
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true to indicate confirm
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userEmail).collection('tasks').doc(taskId).delete();
      } catch (e) {
        print('Error deleting task: $e');
      }
    }
  }
}