import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/task_provider.dart';

class UserTasksScreen extends StatelessWidget {
  const UserTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final groups = context.watch<GroupProvider>();
    final tasks = context.watch<TaskProvider>();
    final userGroups = groups.getGroupsByMember(auth.currentUser!.id);

    if (userGroups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Únete a un grupo para ver tareas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Get all tasks from user's groups
    final availableTasks = userGroups
        .expand((group) => tasks.getPendingTasks(group.id))
        .toList();

    final userTasks = tasks.getUserTasks(auth.currentUser!.id);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Disponibles'),
              Tab(text: 'Mis Tareas'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTaskList(context, availableTasks, isAvailable: true),
                _buildTaskList(context, userTasks, isAvailable: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<Task> taskList, {
    required bool isAvailable,
  }) {
    if (taskList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAvailable ? Icons.task_alt : Icons.check_circle_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isAvailable
                  ? 'No hay tareas disponibles'
                  : 'No tienes tareas asignadas',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        final task = taskList[index];
        return _buildTaskCard(context, task, isAvailable);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, bool isAvailable) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final timeLeft = task.deadline.difference(DateTime.now());
    final hoursLeft = timeLeft.inHours;

    Color urgencyColor = Colors.green;
    if (hoursLeft < 12) {
      urgencyColor = Colors.red;
    } else if (hoursLeft < 24) {
      urgencyColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    task.starReward,
                    (index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: urgencyColor),
                const SizedBox(width: 4),
                Text(
                  'Límite: ${dateFormat.format(task.deadline)}',
                  style: TextStyle(color: urgencyColor, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: urgencyColor),
                const SizedBox(width: 4),
                Text(
                  'Tiempo restante: ${hoursLeft}h',
                  style: TextStyle(
                    color: urgencyColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (task.status != TaskStatus.pending) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  task.status == TaskStatus.completed
                      ? 'Completada'
                      : 'Expirada',
                ),
                backgroundColor: task.status == TaskStatus.completed
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: task.status == TaskStatus.completed
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
            if (isAvailable && task.status == TaskStatus.pending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _completeTask(context, task),
                  icon: const Icon(Icons.check),
                  label: const Text('Marcar como Completada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _completeTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Marcar "${task.title}" como completada?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ganarás: '),
                ...List.generate(
                  task.starReward,
                  (index) => const Icon(Icons.star, color: Colors.amber),
                ),
                Text(' ${task.starReward} estrellas'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final auth = context.read<AuthProvider>();
              context
                  .read<TaskProvider>()
                  .completeTask(task.id, auth.currentUser!.id);
              auth.addStars(task.starReward);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '¡Tarea completada! Ganaste ${task.starReward} estrellas',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
