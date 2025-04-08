import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/data/models/todo_model.dart';
import 'package:todo_task/presentation/providers/todo_provider.dart';

class AddEditScreen extends StatefulWidget {
  final Todo? todoToEdit;

  const AddEditScreen({super.key, this.todoToEdit});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    if (widget.todoToEdit != null) {
      _title = widget.todoToEdit!.title;
      _description = widget.todoToEdit!.description;
      _date = widget.todoToEdit!.date;
    } else {
      _title = '';
      _description = '';
      _date = DateTime.now();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
          _date.year,
          _date.month,
          _date.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final todosProvider = Provider.of<TodosProvider>(context, listen: false);

      if (widget.todoToEdit == null) {
        // Add new todo
        todosProvider.addTodo(
          Todo(
            id: DateTime.now().toString(),
            title: _title,
            description: _description,
            date: _date,
          ),
        );
      } else {
        // Update existing todo
        todosProvider.updateTodo(
          widget.todoToEdit!.copyWith(
            title: _title,
            description: _description,
            date: _date,
          ),
        );
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.todoToEdit == null ? 'Add Todo' : 'Edit Todo',
          style: TextStyle(fontSize: screenWidth * 0.05),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(fontSize: screenWidth * 0.045),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) => _title = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _description,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(fontSize: screenWidth * 0.045),
                  ),
                  onSaved: (value) => _description = value ?? '',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(_date),
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(_date),
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: const Text('Select Time'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTodo,
                    child: Text(
                      widget.todoToEdit == null ? 'Add Todo' : 'Update Todo',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
