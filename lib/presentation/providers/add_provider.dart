import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddProvider extends ChangeNotifier {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  bool isEditMode = false;
  DocumentReference? editDocRef;

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  bool isValid() {
    return titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  Future<void> uploadTaskToDb() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final data = {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'date': selectedDate,
      'creator': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (isEditMode && editDocRef != null) {
      await editDocRef!.update(data);
    } else {
      await FirebaseFirestore.instance.collection('tasks').add(data);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
