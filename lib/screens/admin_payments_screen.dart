import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/payment_provider.dart';

class AdminPaymentsScreen extends StatelessWidget {
  const AdminPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final groups = context.watch<GroupProvider>();
    final payments = context.watch<PaymentProvider>();
    final adminGroups = groups.getGroupsByAdmin(auth.currentUser!.id);

    final allPayments = adminGroups
        .expand((group) => payments.getGroupPayments(group.id))
        .toList();

    final pendingPayments = allPayments
        .where((p) => p.status == PaymentStatus.pending)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Pendientes'),
              Tab(text: 'Historial'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPaymentList(context, pendingPayments, isPending: true),
                _buildPaymentList(
                  context,
                  allPayments
                      .where((p) => p.status != PaymentStatus.pending)
                      .toList(),
                  isPending: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList(
    BuildContext context,
    List<Payment> paymentList, {
    required bool isPending,
  }) {
    if (paymentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.payment : Icons.history,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isPending
                  ? 'No hay pagos pendientes'
                  : 'No hay historial de pagos',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: paymentList.length,
      itemBuilder: (context, index) {
        final payment = paymentList[index];
        return _buildPaymentCard(context, payment, isPending);
      },
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    Payment payment,
    bool isPending,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    Color statusColor;
    String statusText;

    switch (payment.status) {
      case PaymentStatus.approved:
        statusColor = Colors.blue;
        statusText = 'Aprobado';
        break;
      case PaymentStatus.rejected:
        statusColor = Colors.red;
        statusText = 'Rechazado';
        break;
      case PaymentStatus.paid:
        statusColor = Colors.green;
        statusText = 'Pagado';
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.type == PaymentType.total
                            ? 'Pago Total'
                            : 'Pago Parcial',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Solicitado: ${dateFormat.format(payment.requestedAt)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(statusText),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${payment.starsRequested} estrellas',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, color: Colors.green, size: 20),
                Text(
                  '\$${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (payment.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notas: ${payment.notes}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showRejectDialog(context, payment),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Rechazar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _approvePayment(context, payment),
                    child: const Text('Aprobar'),
                  ),
                ],
              ),
            ] else if (payment.status == PaymentStatus.approved) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _markAsPaid(context, payment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Marcar como Pagado'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _approvePayment(BuildContext context, Payment payment) {
    final auth = context.read<AuthProvider>();
    context
        .read<PaymentProvider>()
        .approvePayment(payment.id, auth.currentUser!.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pago aprobado')),
    );
  }

  void _markAsPaid(BuildContext context, Payment payment) {
    context.read<PaymentProvider>().markAsPaid(payment.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pago marcado como pagado')),
    );
  }

  void _showRejectDialog(BuildContext context, Payment payment) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Pago'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Motivo del rechazo',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final auth = context.read<AuthProvider>();
              context.read<PaymentProvider>().rejectPayment(
                    payment.id,
                    auth.currentUser!.id,
                    notesController.text,
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago rechazado')),
              );
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}
