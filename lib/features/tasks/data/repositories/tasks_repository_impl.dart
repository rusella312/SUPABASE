import 'package:buildausermanagement/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:buildausermanagement/features/tasks/domain/entities/task.dart';
import 'package:buildausermanagement/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource _remoteDataSource;

  TasksRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final taskModels = await _remoteDataSource.getAllTasks();
      return taskModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> createTask(String title, String description) async {
    try {
      final taskModel = await _remoteDataSource.createTask(title, description);
      return taskModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> getTaskDetails(String taskId) async {
    try {
      final taskModel = await _remoteDataSource.getTaskDetails(taskId);
      return taskModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    try {
      if (task.id == null) {
        throw Exception('Task ID is required for update');
      }
      final taskModel = await _remoteDataSource.updateTask(
        task.id!,
        task.title,
        task.description,
        task.completed,
      );
      return taskModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _remoteDataSource.deleteTask(taskId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> toggleTaskCompletion(String taskId) async {
    try {
      final task = await getTaskDetails(taskId);
      final updatedTask = task.copyWith(completed: !task.completed);
      return await updateTask(updatedTask);
    } catch (e) {
      rethrow;
    }
  }
}

