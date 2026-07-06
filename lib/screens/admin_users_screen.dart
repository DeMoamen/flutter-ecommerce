import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import 'package:intl/intl.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminProvider>().fetchUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final users = adminProvider.users;

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => adminProvider.fetchUsers(),
              child: users.isEmpty
                  ? const Center(child: Text('لا يوجد مستخدمين'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final dateStr = user['created_at'];
                        final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
                        final isAdmin = user['user_role'] == 'admin';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(user['name']?.substring(0, 1) ?? '?'),
                            ),
                            title: Text(user['name'] ?? 'بدون اسم'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['email'] ?? ''),
                                Text(
                                  'تاريخ التسجيل: ${DateFormat('yyyy-MM-dd').format(date)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              initialValue: user['user_role'] ?? 'user',
                              onSelected: (role) async {
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                final success = await adminProvider.updateUserRole(user['uid'], role);
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'تم تحديث الصلاحية' : 'فشل التحديث'),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'user',
                                  child: Text('مستخدم عادي'),
                                ),
                                const PopupMenuItem(
                                  value: 'admin',
                                  child: Text('مدير (Admin)'),
                                ),
                              ],
                              child: Chip(
                                label: Text(isAdmin ? 'Admin' : 'User'),
                                backgroundColor: isAdmin ? Colors.green.withOpacity(0.1) : null,
                                labelStyle: TextStyle(
                                  color: isAdmin ? Colors.green : null,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
