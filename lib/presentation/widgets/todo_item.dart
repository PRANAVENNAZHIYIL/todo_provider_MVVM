// ignore_for_file: use_build_context_synchronously

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
    final screenSize = MediaQuery.of(context).size;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenSize.width * 0.03),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm Action',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.04,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.04,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.04,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFloatingSnackBar(BuildContext context, String message) {
    final screenSize = MediaQuery.of(context).size;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          right: screenSize.width * 0.05,
          left: screenSize.width * 0.05,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Dismissible(
      key: ValueKey(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: screenSize.width * 0.05),
        child: Icon(Icons.delete,
            color: Colors.white, size: screenSize.width * 0.06),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showConfirmationDialog(
          context, 'Are you sure you want to delete this todo?'),
      onDismissed: (direction) {
        Provider.of<TodosProvider>(context, listen: false).removeTodo(todo.id);
        _showFloatingSnackBar(context, '"${todo.title}" deleted');
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.02,
          vertical: screenSize.height * 0.005,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenSize.width * 0.02),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.03),
          child: Row(
            children: [
              Transform.scale(
                scale: screenSize.width > 600 ? 1.3 : 1.0,
                child: Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) => _handleStatusChange(context),
                ),
              ),
              SizedBox(width: screenSize.width * 0.02),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditScreen(todoToEdit: todo),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: screenSize.width * 0.04 * textScaleFactor,
                          fontWeight: FontWeight.w500,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted ? Colors.grey : Colors.black,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.005),
                      Text(
                        todo.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: screenSize.width * 0.035 * textScaleFactor,
                          color: Colors.grey[700],
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.005),
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(todo.date),
                        style: TextStyle(
                          fontSize: screenSize.width * 0.03 * textScaleFactor,
                          color: Colors.grey,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit,
                        size: screenSize.width * 0.06, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditScreen(todoToEdit: todo),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete,
                        size: screenSize.width * 0.06, color: Colors.red),
                    onPressed: () => _handleDelete(context),
                  ),
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.change_circle,
                  //     size: screenSize.width * 0.06,
                  //     color: todo.isCompleted ? Colors.orange : Colors.green,
                  //   ),
                  //   onPressed: () => _handleStatusChange(context),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
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
      _showFloatingSnackBar(
        context,
        todo.isCompleted ? 'Todo marked incomplete' : 'Todo marked complete',
      );
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Are you sure you want to delete this todo?',
    );

    if (confirmed == true) {
      Provider.of<TodosProvider>(context, listen: false).removeTodo(todo.id);
      _showFloatingSnackBar(context, '"${todo.title}" deleted');
    }
  }
}
