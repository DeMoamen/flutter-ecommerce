import 'package:flutter/foundation.dart';
import '../models/promo_banner.dart';
import '../services/supabase_service.dart';
import 'dart:io';

class BannerProvider with ChangeNotifier {
  List<PromoBanner> _banners = [];
  bool _isLoading = false;

  List<PromoBanner> get banners => _banners;
  bool get isLoading => _isLoading;

  BannerProvider() {
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.getAllBanners();
      _banners = data.map((json) => PromoBanner.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching banners: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBanner(PromoBanner banner, File? imageFile) async {
    try {
      String imageUrl = banner.imageUrl;
      if (imageFile != null) {
        imageUrl = await SupabaseService.uploadBannerImage(imageFile);
      }
      
      final data = banner.toJson();
      data.remove('id'); // DB will generate it
      data['image_url'] = imageUrl;

      final newBannerJson = await SupabaseService.addBanner(data);
      _banners.insert(0, PromoBanner.fromJson(newBannerJson));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding banner: $e');
      rethrow;
    }
  }

  Future<void> updateBanner(PromoBanner banner, File? imageFile) async {
    try {
      String imageUrl = banner.imageUrl;
      if (imageFile != null) {
        imageUrl = await SupabaseService.uploadBannerImage(imageFile);
      }
      
      final data = banner.toJson();
      data['image_url'] = imageUrl;
      
      await SupabaseService.updateBanner(banner.id, data);
      
      final index = _banners.indexWhere((b) => b.id == banner.id);
      if (index != -1) {
        _banners[index] = PromoBanner(
          id: banner.id,
          label: banner.label,
          title: banner.title,
          subtitle: banner.subtitle,
          imageUrl: imageUrl,
          productId: banner.productId,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating banner: $e');
      rethrow;
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      await SupabaseService.deleteBanner(id);
      _banners.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting banner: $e');
      rethrow;
    }
  }
}
