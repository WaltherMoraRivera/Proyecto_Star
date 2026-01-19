import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/task_provider.dart';
import '../providers/payment_provider.dart';
import 'admin_groups_screen.dart';
import 'admin_tasks_screen.dart';
import 'admin_payments_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final groups = context.watch<GroupProvider>();
    final tasks = context.watch<TaskProvider>();
    final payments = context.watch<PaymentProvider>();

    final adminGroups = groups.getGroupsByAdmin(auth.currentUser!.id);
    final pendingPaymentsCount = adminGroups
        .expand((group) => payments.getPendingPayments(group.id))
        .length;

    final screens = [
      _buildDashboard(context, adminGroups, tasks, payments),
      const AdminGroupsScreen(),
      const AdminTasksScreen(),
      const AdminPaymentsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
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
            icon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${adminGroups.length}'),
              child: const Icon(Icons.group),
            ),
            label: 'Grupos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.task),
            label: 'Tareas',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$pendingPaymentsCount'),
              isLabelVisible: pendingPaymentsCount > 0,
              child: const Icon(Icons.payment),
            ),
            label: 'Pagos',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    List<dynamic> groups,
    TaskProvider tasks,
    PaymentProvider payments,
  ) {
    final auth = context.read<AuthProvider>();
    int totalTasks = 0;
    int completedTasks = 0;
    int pendingPayments = 0;

    for (var group in groups) {
      final groupTasks = tasks.getTasksByGroup(group.id);
      totalTasks += groupTasks.length;
      completedTasks += tasks.getCompletedTasks(group.id).length;
      pendingPayments += payments.getPendingPayments(group.id).length;
    }

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
                        const Text('Administrador'),
                      ],
                    ),
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
                  icon: Icons.task,
                  title: 'Tareas',
                  value: '$totalTasks',
                  color: Colors.green,
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
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.payment,
                  title: 'Pagos Pendientes',
                  value: '$pendingPayments',
                  color: Colors.red,
                ),
              ),
            ],
          ),
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
            leading: const Icon(Icons.add_circle, color: Colors.blue),
            title: const Text('Crear Nuevo Grupo'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_task, color: Colors.green),
            title: const Text('Agregar Tarea'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment, color: Colors.orange),
            title: const Text('Revisar Pagos'),
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
