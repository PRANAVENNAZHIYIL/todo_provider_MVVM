// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_task/presentation/views/login_page.dart';

class HomePageProvider extends ChangeNotifier {
  Future<void> logoutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTasksStream() {
    return FirebaseFirestore.instance
        .collection("tasks")
        .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }
}
