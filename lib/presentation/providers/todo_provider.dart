// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_task/data/repositories/todo_repository.dart';
import 'package:todo_task/presentation/views/login_page.dart';

import '../../data/models/todo_model.dart';

class TodosProvider extends ChangeNotifier {
  final TodoRepository _repository = TodoRepository();

  final List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Load and listen to todos (realtime updates)
  void loadTodos() {
    // setLoading(true);
    // _repository.streamTodos().listen((todoList) {
    //   _todos = todoList;
    //   setLoading(false);
    //   notifyListeners();
    // });
  }

  Future<void> addTodo(Todo todo) async {
    setLoading(true);
    await _repository.addTodo(todo);
    setLoading(false);
  }

  Future<void> updateTodo(Todo todo) async {
    setLoading(true);
    await _repository.updateTodo(todo);
    setLoading(false);
  }

  Future<void> deleteTodo(String id) async {
    setLoading(true);
    await _repository.deleteTodo(id);
    setLoading(false);
  }

  Future<void> toggleCompletion(Todo todo) async {
    await _repository.toggleCompletion(todo);
  }

  Future<void> shareTodo(String todoId, String receiverUid) async {
    await _repository.shareTodoWithUser(todoId, receiverUid);
  }
}
