import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool get isAdministrator =>
      _currentUser?.role == UserRole.administrator;

  void login(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void addStars(int stars) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        accumulatedStars: _currentUser!.accumulatedStars + stars,
      );
      notifyListeners();
    }
  }

  void deductStars(int stars) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        accumulatedStars: _currentUser!.accumulatedStars - stars,
      );
      notifyListeners();
    }
  }
}
