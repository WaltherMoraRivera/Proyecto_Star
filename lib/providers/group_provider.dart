import 'package:flutter/foundation.dart';
import '../models/group.dart';

class GroupProvider with ChangeNotifier {
  final List<Group> _groups = [];

  List<Group> get groups => _groups;

  Group? getGroupById(String groupId) {
    try {
      return _groups.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return null;
    }
  }

  List<Group> getGroupsByAdmin(String adminId) {
    return _groups
        .where((group) => group.administratorId == adminId)
        .toList();
  }

  List<Group> getGroupsByMember(String userId) {
    return _groups
        .where((group) => group.memberIds.contains(userId))
        .toList();
  }

  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  void updateGroup(Group group) {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      notifyListeners();
    }
  }

  void addMemberToGroup(String groupId, String userId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      if (!group.memberIds.contains(userId)) {
        _groups[index] = group.copyWith(
          memberIds: [...group.memberIds, userId],
        );
        notifyListeners();
      }
    }
  }

  void removeMemberFromGroup(String groupId, String userId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      _groups[index] = group.copyWith(
        memberIds: group.memberIds.where((id) => id != userId).toList(),
      );
      notifyListeners();
    }
  }

  void deleteGroup(String groupId) {
    _groups.removeWhere((group) => group.id == groupId);
    notifyListeners();
  }
}
