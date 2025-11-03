import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildausermanagement/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:buildausermanagement/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:buildausermanagement/features/tasks/domain/entities/task.dart';
import 'package:buildausermanagement/features/tasks/domain/repositories/tasks_repository.dart';

// Provider para TasksRemoteDataSource
final tasksRemoteDataSourceProvider = Provider<TasksRemoteDataSource>((ref) {
  return TasksRemoteDataSourceImpl();
});

// Provider para TasksRepository
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final remoteDataSource = ref.watch(tasksRemoteDataSourceProvider);
  return TasksRepositoryImpl(remoteDataSource);
});

// Provider principal para las tareas
final tasksProvider = StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  final tasksRepository = ref.watch(tasksRepositoryProvider);
  return TasksNotifier(tasksRepository);
});

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TasksRepository _tasksRepository;

  TasksNotifier(this._tasksRepository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _tasksRepository.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createTask(String title, String description) async {
    try {
      final newTask = await _tasksRepository.createTask(title, description);
      state.whenData((tasks) {
        state = AsyncValue.data([newTask, ...tasks]);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(String taskId, String title, String description) async {
    final tasks = state.valueOrNull;
    if (tasks == null) return;

    final task = tasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));
    
    try {
      final updatedTask = await _tasksRepository.updateTask(
        task.copyWith(title: title, description: description),
      );

      final newTasks = [
        for (final t in tasks)
          if (t.id == taskId) updatedTask else t,
      ];
      state = AsyncValue.data(newTasks);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksRepository.deleteTask(taskId);
      state.whenData((tasks) {
        state = AsyncValue.data(tasks.where((task) => task.id != taskId).toList());
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> getTaskDetails(String taskId) async {
    try {
      return await _tasksRepository.getTaskDetails(taskId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final tasks = state.valueOrNull;
    if (tasks == null) return;

    try {
      final updatedTask = await _tasksRepository.toggleTaskCompletion(taskId);
      state.whenData((currentTasks) {
        final newTasks = [
          for (final t in currentTasks)
            if (t.id == taskId) updatedTask else t,
        ];
        state = AsyncValue.data(newTasks);
      });
    } catch (e) {
      rethrow;
    }
  }
}

