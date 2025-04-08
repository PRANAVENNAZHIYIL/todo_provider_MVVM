import 'package:flutter/foundation.dart';
import 'package:todo_task/data/models/todo_model.dart';

class TodosProvider with ChangeNotifier {
  final List<Todo> _todos = [];

  List<Todo> get todos => _todos.where((todo) => !todo.isCompleted).toList();
  List<Todo> get completedTodos =>
      _todos.where((todo) => todo.isCompleted).toList();

  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void removeTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  void toggleTodoStatus(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index >= 0) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      notifyListeners();
    }
  }

  void updateTodo(Todo updatedTodo) {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index >= 0) {
      _todos[index] = updatedTodo;
      notifyListeners();
    }
  }
}
