import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/task_provider.dart';

class AdminTasksScreen extends StatefulWidget {
  const AdminTasksScreen({super.key});

  @override
  State<AdminTasksScreen> createState() => _AdminTasksScreenState();
}

class _AdminTasksScreenState extends State<AdminTasksScreen> {
  String? _selectedGroupId;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final groups = context.watch<GroupProvider>();
    final tasks = context.watch<TaskProvider>();
    final adminGroups = groups.getGroupsByAdmin(auth.currentUser!.id);

    if (adminGroups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Crea un grupo primero para gestionar tareas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    _selectedGroupId ??= adminGroups.first.id;
    final groupTasks = tasks.getTasksByGroup(_selectedGroupId!);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedGroupId,
              decoration: const InputDecoration(
                labelText: 'Seleccionar Grupo',
                border: OutlineInputBorder(),
              ),
              items: adminGroups.map((group) {
                return DropdownMenuItem(
                  value: group.id,
                  child: Text(group.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value;
                });
              },
            ),
          ),
          Expanded(
            child: groupTasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay tareas en este grupo',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: groupTasks.length,
                    itemBuilder: (context, index) {
                      final task = groupTasks[index];
                      return _buildTaskCard(context, task);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskDialog(context, _selectedGroupId!),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Tarea'),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    Color statusColor;
    String statusText;

    switch (task.status) {
      case TaskStatus.completed:
        statusColor = Colors.green;
        statusText = 'Completada';
        break;
      case TaskStatus.expired:
        statusColor = Colors.red;
        statusText = 'Expirada';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
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
                  children: [
                    ...List.generate(
                      task.starReward,
                      (index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'adjust',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Ajustar Estrellas'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'adjust') {
                          _showAdjustStarsDialog(context, task);
                        } else if (value == 'delete') {
                          context.read<TaskProvider>().deleteTask(task.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Límite: ${dateFormat.format(task.deadline)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(statusText),
              backgroundColor: statusColor.withOpacity(0.2),
              labelStyle: TextStyle(color: statusColor),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustStarsDialog(BuildContext context, Task task) {
    int newStars = task.starReward;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar Estrellas'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tarea: ${task.title}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < newStars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          newStars = index + 1;
                        });
                      },
                    );
                  }),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TaskProvider>().adjustStars(task.id, newStars);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estrellas ajustadas')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context, String groupId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int starReward = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nueva Tarea'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Recompensa en Estrellas:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < starReward ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              starReward = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    Text('$starReward estrella${starReward > 1 ? 's' : ''}'),
                    const SizedBox(height: 16),
                    const Text(
                      'Las tareas tienen un plazo de 48 horas para completarse',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final now = DateTime.now();
                final task = Task(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  description: descriptionController.text,
                  starReward: starReward,
                  groupId: groupId,
                  createdAt: now,
                  deadline: now.add(const Duration(hours: 48)),
                );
                context.read<TaskProvider>().addTask(task);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarea creada exitosamente')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}
