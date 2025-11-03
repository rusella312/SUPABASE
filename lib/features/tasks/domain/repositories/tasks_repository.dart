import 'package:buildausermanagement/features/tasks/domain/entities/task.dart';

abstract class TasksRepository {
  Future<List<Task>> getAllTasks();
  Future<Task> createTask(String title, String description);
  Future<Task> getTaskDetails(String taskId);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<Task> toggleTaskCompletion(String taskId);
}

