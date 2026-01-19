import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/payment.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/payment_provider.dart';

class UserStarsScreen extends StatelessWidget {
  const UserStarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final groups = context.watch<GroupProvider>();
    final payments = context.watch<PaymentProvider>();
    final userGroups = groups.getGroupsByMember(auth.currentUser!.id);
    final userPayments = payments.getUserPayments(auth.currentUser!.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.star, size: 80, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text(
                    'Mis Estrellas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${auth.currentUser!.accumulatedStars}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (auth.currentUser!.accumulatedStars > 0 &&
                      userGroups.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showRequestPaymentDialog(context, userGroups),
                            icon: const Icon(Icons.payment),
                            label: const Text('Solicitar Pago'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
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
            'Historial de Pagos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (userPayments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay pagos solicitados',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...userPayments.map((payment) => _buildPaymentCard(payment)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (payment.status) {
      case PaymentStatus.approved:
        statusColor = Colors.blue;
        statusText = 'Aprobado';
        statusIcon = Icons.check_circle;
        break;
      case PaymentStatus.rejected:
        statusColor = Colors.red;
        statusText = 'Rechazado';
        statusIcon = Icons.cancel;
        break;
      case PaymentStatus.paid:
        statusColor = Colors.green;
        statusText = 'Pagado';
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.pending;
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
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${payment.requestedAt.day}/${payment.requestedAt.month}/${payment.requestedAt.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('${payment.starsRequested} estrellas'),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, color: Colors.green, size: 20),
                Text(
                  '\$${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              payment.type == PaymentType.total ? 'Pago Total' : 'Pago Parcial',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (payment.notes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payment.notes!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRequestPaymentDialog(BuildContext context, List<dynamic> groups) {
    final auth = context.read<AuthProvider>();
    String? selectedGroupId = groups.first.id;
    PaymentType paymentType = PaymentType.total;
    int starsToRequest = auth.currentUser!.accumulatedStars;
    final amountController = TextEditingController(text: '0.00');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Solicitar Pago'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grupo:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedGroupId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: groups.map((group) {
                      return DropdownMenuItem(
                        value: group.id,
                        child: Text(group.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGroupId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tipo de Pago:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<PaymentType>(
                    title: const Text('Pago Total'),
                    subtitle: Text(
                      '${auth.currentUser!.accumulatedStars} estrellas',
                    ),
                    value: PaymentType.total,
                    groupValue: paymentType,
                    onChanged: (value) {
                      setState(() {
                        paymentType = value!;
                        starsToRequest = auth.currentUser!.accumulatedStars;
                      });
                    },
                  ),
                  RadioListTile<PaymentType>(
                    title: const Text('Pago Parcial'),
                    subtitle: const Text('Especificar cantidad'),
                    value: PaymentType.partial,
                    groupValue: paymentType,
                    onChanged: (value) {
                      setState(() {
                        paymentType = value!;
                      });
                    },
                  ),
                  if (paymentType == PaymentType.partial) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: starsToRequest.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Estrellas a solicitar',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final stars = int.tryParse(value) ?? 0;
                        starsToRequest = stars;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto esperado (\$)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (starsToRequest > 0 &&
                      starsToRequest <= auth.currentUser!.accumulatedStars) {
                    final payment = Payment(
                      id: const Uuid().v4(),
                      userId: auth.currentUser!.id,
                      groupId: selectedGroupId!,
                      starsRequested: starsToRequest,
                      amount: double.tryParse(amountController.text) ?? 0.0,
                      type: paymentType,
                      requestedAt: DateTime.now(),
                    );
                    context.read<PaymentProvider>().addPayment(payment);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Solicitud de pago enviada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cantidad de estrellas inválida'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Solicitar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
