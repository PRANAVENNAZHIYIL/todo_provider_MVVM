// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

    // If editing existing task, pre-fill the fields
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
    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        appBar: AppBar(
          title: Text(provider.isEditMode ? "Update Task" : "Add Task"),
        ),
        body: Consumer<AddProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: provider.titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        "Date: ${provider.selectedDate.toLocal().toString().split(' ')[0]}",
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: provider.selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            provider.setSelectedDate(picked);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (provider.isValid()) {
                        await provider.uploadTaskToDb();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.isEditMode
                                ? "Task updated successfully!"
                                : "Task added successfully!"),
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter title and description"),
                          ),
                        );
                      }
                    },
                    child:
                        Text(provider.isEditMode ? "Update Task" : "Add Task"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
