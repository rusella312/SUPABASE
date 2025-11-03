import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

@freezed
class Task with _$Task {
  const Task._();
  
  const factory Task({
    String? id, // UUID de Supabase
    required String title,
    required String description,
    @Default(false) bool completed,
  }) = _Task;

  // Convert Task to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
    };
  }

  // Create Task from Map for JSON deserialization
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      completed: map['completed'] as bool? ?? false,
    );
  }
}

