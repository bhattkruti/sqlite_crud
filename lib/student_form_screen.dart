import 'package:flutter/material.dart';

import 'database_helper.dart';

class StudentFormScreen extends StatefulWidget {
  final Map<String, dynamic>? student;

  const StudentFormScreen({
    super.key,
    this.student,
  });

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  // Database helper instance.
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  // Controllers for text fields.
  final TextEditingController studentIdController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // If student data is passed, this is Edit mode.
    if (widget.student != null) {
      studentIdController.text = widget.student!['studentId'];

      nameController.text = widget.student!['name'];
    }
  }

  @override
  void dispose() {
    studentIdController.dispose();
    nameController.dispose();

    super.dispose();
  }

  // CREATE operation
  Future<void> addStudent() async {
    await dbHelper.insertStudent(
      studentIdController.text,
      nameController.text,
    );

    Navigator.pop(context);
  }

  // UPDATE operation
  Future<void> updateStudent() async {
    await dbHelper.updateStudent(
      widget.student!['id'],
      studentIdController.text,
      nameController.text,
    );

    Navigator.pop(context);
  }

  // Saves either a new student or updated student.
  Future<void> saveStudent() async {
    // Basic validation.
    if (studentIdController.text.isEmpty || nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all fields'),
        ),
      );

      return;
    }

    if (widget.student == null) {
      // Add new student.
      await addStudent();
    } else {
      // Update existing student.
      await updateStudent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.student != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Student' : 'Add Student',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Student ID
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Student Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Save / Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveStudent,
                child: Text(
                  isEditMode ? 'Update' : 'Save',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
