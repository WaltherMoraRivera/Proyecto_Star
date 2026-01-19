import 'package:flutter/foundation.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> getTasksByGroup(String groupId) {
    return _tasks.where((task) => task.groupId == groupId).toList();
  }

  List<Task> getPendingTasks(String groupId) {
    return _tasks
        .where((task) =>
            task.groupId == groupId && task.status == TaskStatus.pending)
        .toList();
  }

  List<Task> getCompletedTasks(String groupId) {
    return _tasks
        .where((task) =>
            task.groupId == groupId && task.status == TaskStatus.completed)
        .toList();
  }

  List<Task> getUserTasks(String userId) {
    return _tasks.where((task) => task.assignedUserId == userId).toList();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  void completeTask(String taskId, String userId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        assignedUserId: userId,
      );
      notifyListeners();
    }
  }

  void adjustStars(String taskId, int newStarReward) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(starReward: newStarReward);
      notifyListeners();
    }
  }

  void checkExpiredTasks() {
    bool hasChanges = false;
    for (var i = 0; i < _tasks.length; i++) {
      if (_tasks[i].isExpired()) {
        _tasks[i] = _tasks[i].copyWith(status: TaskStatus.expired);
        hasChanges = true;
      }
    }
    if (hasChanges) {
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }
}
