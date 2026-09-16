import 'package:flutter/material.dart';
import 'package:sqlite_crud/student_form_screen.dart';

import 'database_helper.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  // Get the shared DatabaseHelper instance.
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  // Stores student records loaded from SQLite.
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();

    // Load students when the screen opens.
    loadStudents();
  }

  // READ operation
  // Fetches all students from SQLite.
  Future<void> loadStudents() async {
    final data = await dbHelper.getStudents();

    setState(() {
      students = data;
    });
  }

  // DELETE operation
  // Deletes a student from SQLite.
  Future<void> deleteStudent(int id) async {
    await dbHelper.deleteStudent(id);

    // Refresh the list after deleting.
    await loadStudents();
  }

  // Shows confirmation dialog before deleting.
  void showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Student?'),
          content: const Text(
            'Are you sure you want to delete this student?',
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),

            // Delete button
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await deleteStudent(id);
              },
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Opens the Add Student screen.
  Future<void> addStudent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudentFormScreen(),
      ),
    );

    // Refresh list after returning from the form.
    await loadStudents();
  }

  // Opens the Edit Student screen.
  Future<void> editStudent(
    Map<String, dynamic> student,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentFormScreen(
          student: student,
        ),
      ),
    );

    // Refresh list after editing.
    await loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
      ),

      body: students.isEmpty

          // Display message when there are no records.
          ? const Center(
              child: Text(
                'No students found',
                style: TextStyle(fontSize: 18),
              ),
            )

          // Display SQLite records.
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      '${student['id']}',
                    ),
                  ),

                  title: Text(
                    student['studentId'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    student['name'],
                  ),

                  // Edit button
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          editStudent(student);
                        },
                      ),

                      // Delete button
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          showDeleteDialog(
                            student['id'],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

      // Add Student button
      floatingActionButton: FloatingActionButton(
        onPressed: addStudent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
