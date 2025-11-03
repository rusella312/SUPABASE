import 'package:buildausermanagement/features/tasks/domain/entities/task.dart';

class TaskModel {
  final String? id;
  final String title;
  final String description;
  final bool completed;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    this.completed = false,
  });

  // Convert from Supabase JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }

  // Convert to Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'completed': completed,
    };
  }

  // Convert to Entity
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      completed: completed,
    );
  }

  // Create from Entity
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      completed: task.completed,
    );
  }
}

