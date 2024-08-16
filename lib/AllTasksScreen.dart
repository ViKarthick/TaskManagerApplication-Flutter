import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userEmail = FirebaseAuth.instance.currentUser!.email;
    FirebaseFirestore db = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('users')
            .doc(userEmail)
            .collection('tasks')
            .orderBy('priority', descending: true)
            .orderBy('lastDate')
            .snapshots(),
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
              String formattedDate =
              DateFormat('dd-MM-yyyy').format(dateTime);
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}