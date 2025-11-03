import 'package:buildausermanagement/main.dart';
import 'package:buildausermanagement/features/tasks/data/models/task_model.dart';

abstract class TasksRemoteDataSource {
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel> createTask(String title, String description);
  Future<TaskModel> getTaskDetails(String taskId);
  Future<TaskModel> updateTask(String id, String title, String description, bool completed);
  Future<void> deleteTask(String taskId);
}

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  TasksRemoteDataSourceImpl();

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('🔍 Intentando cargar tareas para usuario: $userId');
      
      final response = await supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ Tareas cargadas exitosamente: ${(response as List).length}');
      
      return (response as List)
          .map((task) => TaskModel.fromJson(task as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error cargando tareas: $e');
      // Si el error es sobre tabla no encontrada, dar un mensaje más claro
      if (e.toString().contains('Could not find the table') || 
          e.toString().contains('PGRST205')) {
        throw Exception('La tabla tasks no existe en Supabase. Por favor ejecuta el SQL en Supabase SQL Editor.');
      }
      rethrow;
    }
  }

  @override
  Future<TaskModel> createTask(String title, String description) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await supabase
          .from('tasks')
          .insert({
            'user_id': userId,
            'title': title,
            'description': description,
            'completed': false,
          })
          .select()
          .single();

      return TaskModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TaskModel> getTaskDetails(String taskId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await supabase
          .from('tasks')
          .select()
          .eq('id', taskId)
          .eq('user_id', userId)
          .single();

      return TaskModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TaskModel> updateTask(String id, String title, String description, bool completed) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await supabase
          .from('tasks')
          .update({
            'title': title,
            'description': description,
            'completed': completed,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .single();

      return TaskModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await supabase
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }
}

