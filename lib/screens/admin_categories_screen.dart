import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CategoryProvider>().fetchCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة التصنيفات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchCategories(),
              child: categories.isEmpty
                  ? const Center(child: Text('لا توجد تصنيفات'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.folder),
                            ),
                            title: Text(category.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showCategoryDialog(context, category: category),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteCategory(context, provider, category),
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

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final nameController = TextEditingController(text: category?.name);
    String selectedIcon = category?.iconName ?? 'category';

    final List<Map<String, dynamic>> availableIcons = [
      {'name': 'category', 'icon': Icons.category_rounded},
      {'name': 'directions_run', 'icon': Icons.directions_run_rounded},
      {'name': 'checkroom', 'icon': Icons.checkroom_rounded},
      {'name': 'watch', 'icon': Icons.watch_rounded},
      {'name': 'shopping_bag', 'icon': Icons.shopping_bag_rounded},
      {'name': 'phone_iphone', 'icon': Icons.phone_iphone_rounded},
      {'name': 'laptop', 'icon': Icons.laptop_mac_rounded},
      {'name': 'chair', 'icon': Icons.chair_rounded},
      {'name': 'sports_esports', 'icon': Icons.sports_esports_rounded},
      {'name': 'face', 'icon': Icons.face_retouching_natural_rounded},
      {'name': 'book', 'icon': Icons.menu_book_rounded},
      {'name': 'fastfood', 'icon': Icons.fastfood_rounded},
    ];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(category == null ? 'إضافة تصنيف' : 'تعديل تصنيف'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'اسم التصنيف'),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('اختر أيقونة:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: availableIcons.map((iconData) {
                      final isSelected = selectedIcon == iconData['name'];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedIcon = iconData['name'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(iconData['icon'] as IconData, color: isSelected ? Colors.blue : Colors.grey),
                        ),
                      );
                    }).toList(),
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
                  if (nameController.text.trim().isEmpty) return;
                  
                  final provider = context.read<CategoryProvider>();
                  final nav = Navigator.of(context);
                  
                  bool success;
                  if (category == null) {
                    final newCategory = Category(
                      id: '',
                      name: nameController.text.trim(),
                      iconName: selectedIcon,
                      createdAt: DateTime.now(),
                    );
                    success = await provider.addCategory(newCategory);
                  } else {
                    final updatedCategory = Category(
                      id: category.id,
                      name: nameController.text.trim(),
                      iconName: selectedIcon,
                      createdAt: category.createdAt,
                    );
                    success = await provider.updateCategory(updatedCategory);
                  }
                  
                  if (success && mounted) {
                    nav.pop();
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, CategoryProvider provider, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التصنيف'),
        content: Text('هل أنت متأكد من حذف تصنيف "${category.name}"؟'),
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
      await provider.deleteCategory(category.id);
    }
  }
}
