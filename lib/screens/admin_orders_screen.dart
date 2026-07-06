import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_order_provider.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminOrderProvider>().fetchAllOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<AdminOrderProvider>();
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الطلبات')),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => orderProvider.fetchAllOrders(),
              child: orderProvider.error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'حدث خطأ:\n${orderProvider.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  : orders.isEmpty
                      ? const Center(child: Text('لا توجد طلبات'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final user = order['users'] ?? {};
                        final items = List.from(order['order_items'] ?? []);
                        final date = DateTime.parse(order['created_at']);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            title: Text('طلب #${order['id'].toString().substring(0, 8)}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${user['name'] ?? 'مستخدم'} - ${order['total_amount']} ر.س'),
                                Text(DateFormat('yyyy-MM-dd HH:mm').format(date)),
                              ],
                            ),
                            trailing: _buildStatusBadge(order['status']),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'تغيير الحالة:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        _buildStatusButton('Processing', order, orderProvider),
                                        _buildStatusButton('Shipped', order, orderProvider),
                                        _buildStatusButton('Completed', order, orderProvider),
                                        _buildStatusButton('Cancelled', order, orderProvider),
                                      ],
                                    ),
                                    const Divider(),
                                    const Text(
                                      'المنتجات:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    ...items.map((item) {
                                      final product = item['products'] ?? {};
                                      return ListTile(
                                        title: Text(product['name'] ?? 'منتج'),
                                        subtitle: Text('${item['price']} ر.س x ${item['quantity']}'),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'Processing':
        color = Colors.orange;
        text = 'قيد التجهيز';
        break;
      case 'Shipped':
        color = Colors.blue;
        text = 'تم الشحن';
        break;
      case 'Completed':
        color = Colors.green;
        text = 'مكتمل';
        break;
      case 'Cancelled':
        color = Colors.red;
        text = 'ملغي';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusButton(String status, Map order, AdminOrderProvider provider) {
    final isCurrent = order['status'] == status;
    return ChoiceChip(
      label: Text(status),
      selected: isCurrent,
      onSelected: (selected) {
        if (selected && !isCurrent) {
          provider.updateOrderStatus(order['id'], status);
        }
      },
    );
  }
}
