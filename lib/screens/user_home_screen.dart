import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/task_provider.dart';
import 'user_tasks_screen.dart';
import 'user_groups_screen.dart';
import 'user_stars_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final groups = context.watch<GroupProvider>();
    final tasks = context.watch<TaskProvider>();

    final userGroups = groups.getGroupsByMember(auth.currentUser!.id);
    final userTasks = tasks.getUserTasks(auth.currentUser!.id);
    final pendingTasks =
        userTasks.where((t) => t.status == TaskStatus.pending).length;

    final screens = [
      _buildDashboard(context, auth, userGroups, userTasks),
      const UserGroupsScreen(),
      const UserTasksScreen(),
      const UserStarsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${userGroups.length}'),
              child: const Icon(Icons.group),
            ),
            label: 'Grupos',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$pendingTasks'),
              isLabelVisible: pendingTasks > 0,
              child: const Icon(Icons.task),
            ),
            label: 'Tareas',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${auth.currentUser!.accumulatedStars}'),
              child: const Icon(Icons.star),
            ),
            label: 'Estrellas',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    AuthProvider auth,
    List<dynamic> groups,
    List<dynamic> tasks,
  ) {
    final pendingTasks =
        tasks.where((t) => t.status == TaskStatus.pending).length;
    final completedTasks =
        tasks.where((t) => t.status == TaskStatus.completed).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.currentUser!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Usuario'),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 30),
                      Text(
                        '${auth.currentUser!.accumulatedStars}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Resumen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.group,
                  title: 'Grupos',
                  value: '${groups.length}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.pending_actions,
                  title: 'Pendientes',
                  value: '$pendingTasks',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  title: 'Completadas',
                  value: '$completedTasks',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.star,
                  title: 'Estrellas',
                  value: '${auth.currentUser!.accumulatedStars}',
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          if (pendingTasks > 0) ...[
            const SizedBox(height: 24),
            const Text(
              'Recordatorio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Tienes $pendingTasks tareas pendientes. ¡Recuerda completarlas dentro de las 48 horas!',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.task, color: Colors.green),
            title: const Text('Ver Mis Tareas'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Ver Mis Estrellas'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
