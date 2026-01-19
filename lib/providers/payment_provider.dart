import 'package:flutter/foundation.dart';
import '../models/payment.dart';

class PaymentProvider with ChangeNotifier {
  final List<Payment> _payments = [];

  List<Payment> get payments => _payments;

  List<Payment> getPendingPayments(String groupId) {
    return _payments
        .where((payment) =>
            payment.groupId == groupId &&
            payment.status == PaymentStatus.pending)
        .toList();
  }

  List<Payment> getUserPayments(String userId) {
    return _payments.where((payment) => payment.userId == userId).toList();
  }

  List<Payment> getGroupPayments(String groupId) {
    return _payments.where((payment) => payment.groupId == groupId).toList();
  }

  void addPayment(Payment payment) {
    _payments.add(payment);
    notifyListeners();
  }

  void updatePayment(Payment payment) {
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _payments[index] = payment;
      notifyListeners();
    }
  }

  void approvePayment(String paymentId, String adminId) {
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      _payments[index] = _payments[index].copyWith(
        status: PaymentStatus.approved,
        processedAt: DateTime.now(),
        processedBy: adminId,
      );
      notifyListeners();
    }
  }

  void rejectPayment(String paymentId, String adminId, String notes) {
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      _payments[index] = _payments[index].copyWith(
        status: PaymentStatus.rejected,
        processedAt: DateTime.now(),
        processedBy: adminId,
        notes: notes,
      );
      notifyListeners();
    }
  }

  void markAsPaid(String paymentId) {
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      _payments[index] = _payments[index].copyWith(
        status: PaymentStatus.paid,
      );
      notifyListeners();
    }
  }

  void deletePayment(String paymentId) {
    _payments.removeWhere((payment) => payment.id == paymentId);
    notifyListeners();
  }
}
