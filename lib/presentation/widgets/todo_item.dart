import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/data/models/todo_model.dart';
import 'package:todo_task/presentation/providers/todo_provider.dart';

import '../views/todo_add_edit_screen.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  Future<bool?> _showConfirmationDialog(
      BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Action'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleStatusChange(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      todo.isCompleted
          ? 'Mark this todo as incomplete?'
          : 'Mark this todo as complete?',
    );

    if (confirmed == true) {
      Provider.of<TodosProvider>(context, listen: false)
          .toggleTodoStatus(todo.id);
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Are you sure you want to delete this todo?',
    );

    if (confirmed == true) {
      Provider.of<TodosProvider>(context, listen: false).removeTodo(todo.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${todo.title}" deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showConfirmationDialog(
          context,
          'Are you sure you want to delete this todo?',
        );
      },
      onDismissed: (direction) {
        Provider.of<TodosProvider>(context, listen: false).removeTodo(todo.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => _handleStatusChange(context),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(todo.description),
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(todo.date),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // IconButton(
              //   icon: const Icon(Icons.change_circle, color: Colors.blue),
              //   tooltip: 'Quick complete',
              //   onPressed: () => _handleStatusChange(context),
              // ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit todo',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditScreen(
                        todoToEdit: todo,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete todo',
                onPressed: () => _handleDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
