import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isCompleted;
  final String ownerId;
  final List<String> sharedWith;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
    required this.ownerId,
    this.sharedWith = const [],
  });

  factory Todo.fromMap(Map<String, dynamic> map, String docId) {
    return Todo(
      id: docId,
      title: map['title'],
      description: map['description'],
      date: (map['date'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
      ownerId: map['ownerId'],
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'isCompleted': isCompleted,
      'ownerId': ownerId,
      'sharedWith': sharedWith,
    };
  }

  Todo copyWith({
    String? title,
    String? description,
    DateTime? date,
    bool? isCompleted,
    List<String>? sharedWith,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      ownerId: ownerId,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }
}
