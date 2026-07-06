import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/banner_provider.dart';
import '../models/promo_banner.dart';

class AdminBannersScreen extends StatelessWidget {
  const AdminBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerProvider = context.watch<BannerProvider>();
    final banners = bannerProvider.banners;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العروض والبانرات'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showBannerDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة عرض'),
      ),
      body: bannerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : banners.isEmpty
              ? const Center(child: Text('لا توجد عروض حالياً.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          if (banner.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                banner.imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ListTile(
                            title: Text(banner.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(banner.subtitle),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showBannerDialog(context, banner: banner),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(context, banner),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PromoBanner banner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف العرض'),
        content: const Text('هل أنت متأكد من حذف هذا العرض؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<BannerProvider>().deleteBanner(banner.id);
    }
  }

  void _showBannerDialog(BuildContext context, {PromoBanner? banner}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: BannerForm(banner: banner),
      ),
    );
  }
}

class BannerForm extends StatefulWidget {
  final PromoBanner? banner;
  const BannerForm({super.key, this.banner});

  @override
  State<BannerForm> createState() => _BannerFormState();
}

class _BannerFormState extends State<BannerForm> {
  final _formKey = GlobalKey<FormState>();
  late String label;
  late String title;
  late String subtitle;
  String? imageUrl;
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    label = widget.banner?.label ?? 'PREMIUM COLLECTION';
    title = widget.banner?.title ?? '';
    subtitle = widget.banner?.subtitle ?? '';
    imageUrl = widget.banner?.imageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_imageFile == null && (imageUrl == null || imageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار صورة')));
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final newBanner = PromoBanner(
        id: widget.banner?.id ?? '',
        label: label,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl ?? '',
      );

      if (widget.banner == null) {
        await context.read<BannerProvider>().addBanner(newBanner, _imageFile);
      } else {
        await context.read<BannerProvider>().updateBanner(newBanner, _imageFile);
      }
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.banner == null ? 'إضافة عرض جديد' : 'تعديل العرض',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  image: _imageFile != null
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : (imageUrl != null && imageUrl!.isNotEmpty)
                          ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                          : null,
                ),
                child: (_imageFile == null && (imageUrl == null || imageUrl!.isEmpty))
                    ? const Center(child: Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey))
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: label,
              decoration: const InputDecoration(labelText: 'الملصق (مثال: PREMIUM COLLECTION)'),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              onSaved: (v) => label = v!,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: title,
              decoration: const InputDecoration(labelText: 'العنوان الرئيسي'),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              onSaved: (v) => title = v!,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: subtitle,
              decoration: const InputDecoration(labelText: 'العنوان الفرعي'),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              onSaved: (v) => subtitle = v!,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
