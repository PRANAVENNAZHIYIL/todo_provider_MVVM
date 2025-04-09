// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/presentation/providers/add_provider.dart';

class AddPage extends StatefulWidget {
  final DocumentSnapshot? editData;

  const AddPage({super.key, this.editData});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late AddProvider provider;

  @override
  void initState() {
    super.initState();
    provider = AddProvider();

    if (widget.editData != null) {
      final data = widget.editData!.data() as Map<String, dynamic>;
      provider.titleController.text = data['title'] ?? '';
      provider.descriptionController.text = data['description'] ?? '';

      final dynamic rawDate = data['date'];
      if (rawDate is Timestamp) {
        provider.setSelectedDate(rawDate.toDate());
      } else if (rawDate is DateTime) {
        provider.setSelectedDate(rawDate);
      }

      provider.isEditMode = true;
      provider.editDocRef = widget.editData!.reference;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            provider.isEditMode ? "Update Task" : "Create New Task",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: mq.size.width * 0.055,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.deepPurple,
          actions: [
            if (provider.isEditMode)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(mq.size.width * 0.06),
          child: Consumer<AddProvider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, provider, mq),
                  SizedBox(height: mq.size.height * 0.03),
                  _buildTitleField(mq),
                  SizedBox(height: mq.size.height * 0.025),
                  _buildDescriptionField(mq),
                  SizedBox(height: mq.size.height * 0.025),
                  _buildDatePicker(context, provider, mq),
                  SizedBox(height: mq.size.height * 0.04),
                  _buildSubmitButton(context, provider, mq),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AddProvider provider, MediaQueryData mq) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider.isEditMode ? "Update your task" : "What's your plan?",
          style: TextStyle(
            fontSize: mq.size.width * 0.045,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: mq.size.height * 0.01),
        const Divider(
          thickness: 1,
          color: Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildTitleField(MediaQueryData mq) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Task Title",
          style: TextStyle(
            fontSize: mq.size.width * 0.042,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: mq.size.height * 0.01),
        TextField(
          controller: provider.titleController,
          decoration: InputDecoration(
            hintText: "Enter task title",
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: mq.size.width * 0.04,
              vertical: mq.size.height * 0.018,
            ),
          ),
          style: TextStyle(fontSize: mq.size.width * 0.04),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(MediaQueryData mq) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
            fontSize: mq.size.width * 0.042,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: mq.size.height * 0.01),
        TextField(
          controller: provider.descriptionController,
          decoration: InputDecoration(
            hintText: "Enter task description",
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: mq.size.width * 0.04,
              vertical: mq.size.height * 0.018,
            ),
          ),
          maxLines: 4,
          style: TextStyle(fontSize: mq.size.width * 0.04),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
      BuildContext context, AddProvider provider, MediaQueryData mq) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Due Date",
          style: TextStyle(
            fontSize: mq.size.width * 0.042,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: mq.size.height * 0.01),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: provider.selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.deepPurple,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              provider.setSelectedDate(picked);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: mq.size.width * 0.04,
              vertical: mq.size.height * 0.018,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.deepPurple, size: 20),
                SizedBox(width: mq.size.width * 0.03),
                Text(
                  DateFormat('MMM dd, yyyy').format(provider.selectedDate),
                  style: TextStyle(fontSize: mq.size.width * 0.04),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, AddProvider provider, MediaQueryData mq) {
    return ElevatedButton(
      onPressed: () async {
        if (provider.isValid()) {
          await provider.uploadTaskToDb();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.isEditMode
                    ? "Task updated successfully!"
                    : "Task added successfully!",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.deepPurple,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Please enter title and description",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: EdgeInsets.symmetric(vertical: mq.size.height * 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        provider.isEditMode ? "UPDATE TASK" : "CREATE TASK",
        style: TextStyle(
          fontSize: mq.size.width * 0.045,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await provider.editDocRef?.delete();
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Task deleted successfully"),
                  backgroundColor: Colors.deepPurple,
                ),
              );
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
