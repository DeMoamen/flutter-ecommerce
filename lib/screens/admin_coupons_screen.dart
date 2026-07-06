import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coupon_provider.dart';
import '../models/coupon.dart';
import 'package:intl/intl.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CouponProvider>().fetchCoupons();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CouponProvider>();
    final coupons = provider.coupons;

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الكوبونات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCouponDialog(context),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchCoupons(),
              child: coupons.isEmpty
                  ? const Center(child: Text('لا توجد كوبونات'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: coupons.length,
                      itemBuilder: (context, index) {
                        final coupon = coupons[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: coupon.isActive ? Colors.green : Colors.grey,
                              child: const Icon(Icons.local_offer, color: Colors.white),
                            ),
                            title: Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('خصم ${coupon.discountPercentage}%'),
                                Text('مرات الاستخدام: ${coupon.usedCount}${coupon.maxUses != null ? ' / ${coupon.maxUses}' : ''}'),
                                if (coupon.expiresAt != null)
                                  Text('ينتهي: ${DateFormat('yyyy-MM-dd').format(coupon.expiresAt!)}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: coupon.isActive,
                                  onChanged: (val) {
                                    provider.updateCoupon(
                                      Coupon(
                                        id: coupon.id,
                                        code: coupon.code,
                                        discountPercentage: coupon.discountPercentage,
                                        minOrderAmount: coupon.minOrderAmount,
                                        maxUses: coupon.maxUses,
                                        usedCount: coupon.usedCount,
                                        isActive: val,
                                        expiresAt: coupon.expiresAt,
                                        createdAt: coupon.createdAt,
                                      )
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteCoupon(context, provider, coupon),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _showCouponDialog(BuildContext context) {
    final codeController = TextEditingController();
    final discountController = TextEditingController();
    final minOrderController = TextEditingController(text: '0');
    final maxUsesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة كوبون'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'كود الخصم'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: discountController,
                decoration: const InputDecoration(labelText: 'نسبة الخصم (%)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: minOrderController,
                decoration: const InputDecoration(labelText: 'الحد الأدنى للطلب'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: maxUsesController,
                decoration: const InputDecoration(labelText: 'الحد الأقصى للاستخدام (اختياري)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.trim().isEmpty || discountController.text.isEmpty) return;
              
              final discount = double.tryParse(discountController.text);
              if (discount == null || discount <= 0 || discount > 100) return;
              
              final provider = context.read<CouponProvider>();
              final nav = Navigator.of(context);
              
              final newCoupon = Coupon(
                id: '',
                code: codeController.text.trim().toUpperCase(),
                discountPercentage: discount,
                minOrderAmount: double.tryParse(minOrderController.text) ?? 0,
                maxUses: int.tryParse(maxUsesController.text),
                usedCount: 0,
                isActive: true,
                createdAt: DateTime.now(),
              );
              
              final success = await provider.addCoupon(newCoupon);
              
              if (success && mounted) {
                nav.pop();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCoupon(BuildContext context, CouponProvider provider, Coupon coupon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الكوبون'),
        content: Text('هل أنت متأكد من حذف كوبون "${coupon.code}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deleteCoupon(coupon.id);
    }
  }
}
