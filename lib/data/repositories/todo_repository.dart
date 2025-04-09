import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/todo_model.dart';

class TodoRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference get _todoCollection => _firestore.collection('todos');

  /// Add a new todo to Firestore
  Future<void> addTodo(Todo todo) async {
    await _todoCollection.add(todo.toMap());
  }

  /// Update an existing todo
  Future<void> updateTodo(Todo todo) async {
    await _todoCollection.doc(todo.id).update(todo.toMap());
  }

  /// Delete a todo
  Future<void> deleteTodo(String todoId) async {
    await _todoCollection.doc(todoId).delete();
  }

  /// Toggle completion status
  Future<void> toggleCompletion(Todo todo) async {
    await _todoCollection
        .doc(todo.id)
        .update({'isCompleted': !todo.isCompleted});
  }

  /// Listen to all todos created by or shared with the current user
  Stream<List<Todo>> streamTodos() {
    final userId = _auth.currentUser!.uid;

    return _todoCollection
        .where('sharedWith', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Todo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Get a todo by ID
  Future<Todo> getTodoById(String id) async {
    final doc = await _todoCollection.doc(id).get();
    return Todo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Share task with another user (by email -> get UID from email)
  Future<void> shareTodoWithUser(String todoId, String receiverUid) async {
    final doc = await _todoCollection.doc(todoId).get();
    if (!doc.exists) return;

    final currentList = List<String>.from(doc['sharedWith'] ?? []);
    if (!currentList.contains(receiverUid)) {
      currentList.add(receiverUid);
      await _todoCollection.doc(todoId).update({'sharedWith': currentList});
    }
  }
}
