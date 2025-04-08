import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/presentation/providers/todo_provider.dart';
import 'package:todo_task/presentation/views/todo_add_edit_screen.dart';

import '../widgets/todo_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: _selectedIndex == 0 ? const TodoList() : const CompletedTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Todos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all),
            label: 'Completed',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = Provider.of<TodosProvider>(context).todos;
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(todo: todo);
      },
    );
  }
}

class CompletedTodoList extends StatelessWidget {
  const CompletedTodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final completedTodos = Provider.of<TodosProvider>(context).completedTodos;
    return ListView.builder(
      itemCount: completedTodos.length,
      itemBuilder: (context, index) {
        final todo = completedTodos[index];
        return TodoItem(todo: todo);
      },
    );
  }
}
