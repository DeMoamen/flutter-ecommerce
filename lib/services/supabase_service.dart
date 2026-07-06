import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class SupabaseService {
 
 
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://xryaartwlmrzmkgdoild.supabase.co',
      anonKey: 'sb_publishable_qI4IqV4MN1eK9Fzr0UHCbQ_YdguywBI',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  // ── User Role ────────────────────────────────────────────────────────────
  static Future<String?> getUserRole() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await client
        .from('users')
        .select('user_role')
        .eq('uid', userId)
        .maybeSingle();

    return response?['user_role'] as String?;
  }

  // ── Products - Read (Public) ─────────────────────────────────────────────
  static Future<List<Product>> getAllProducts() async {
    final response = await client
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  // ── Products - Create (Admin Only) ───────────────────────────────────────
  static Future<Product> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    String category = 'General',
    bool isFeatured = false,
  }) async {
    final response = await client.from('products').insert({
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'is_featured': isFeatured,
    }).select().single();

    return Product.fromJson(response);
  }

  // ── Products - Update (Admin Only) ───────────────────────────────────────
  static Future<Product> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    String category = 'General',
    bool isFeatured = false,
  }) async {
    final response = await client
        .from('products')
        .update({
          'name': name,
          'description': description,
          'price': price,
          'image_url': imageUrl,
          'category': category,
          'is_featured': isFeatured,
        })
        .eq('id', id)
        .select()
        .single();

    return Product.fromJson(response);
  }

  // ── Products - Delete (Admin Only) ───────────────────────────────────────
  static Future<void> deleteProduct(String id) async {
    await client.from('products').delete().eq('id', id);
  }

  // ── Storage - Upload Product Image (Admin Only) ──────────────────────────
  static Future<String> uploadProductImage(File imageFile) async {
    final fileExt = imageFile.path.split('.').last.toLowerCase();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}.$fileExt';

    await client.storage.from('products').upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    return client.storage.from('products').getPublicUrl(fileName);
  }

  // ── Storage - Delete Product Image (Admin Only) ──────────────────────────
  static Future<void> deleteProductImage(String imageUrl) async {
    try {
      final fileName = imageUrl.split('/').last;
      await client.storage.from('products').remove([fileName]);
    } catch (e) {
      debugPrint('Failed to delete image: $e');
    }
  }

  // ── Cart (Per User) ──────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final response = await client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    await client.from('cart_items').insert({
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  static Future<void> updateCartItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await client.from('cart_items').delete().eq('id', cartItemId);
    } else {
      await client
          .from('cart_items')
          .update({'quantity': quantity}).eq('id', cartItemId);
    }
  }

  static Future<void> removeFromCart(String cartItemId) async {
    await client.from('cart_items').delete().eq('id', cartItemId);
  }

  static Future<void> clearCart(String userId) async {
    await client.from('cart_items').delete().eq('user_id', userId);
  }

  // ── Wishlist (Per User) ──────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getWishlistItems(String userId) async {
    final response = await client
        .from('wishlist_items')
        .select('*, products(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    await client.from('wishlist_items').insert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  static Future<void> removeFromWishlist(String wishlistItemId) async {
    await client.from('wishlist_items').delete().eq('id', wishlistItemId);
  }

  static Future<bool> isInWishlist({
    required String userId,
    required String productId,
  }) async {
    final response = await client
        .from('wishlist_items')
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();
    return response != null;
  }

  // ── Orders (Per User) ────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final response = await client
          .from('orders')
          .select('*, order_items(*, products(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e, stacktrace) {
      debugPrint('Exception in getUserOrders: $e');
      debugPrint('Stacktrace: $stacktrace');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String orderId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    final orderData = {
      'id': orderId,
      'user_id': userId,
      'total_amount': totalAmount,
      'status': 'Processing',
      'created_at': DateTime.now().toIso8601String(),
    };

    final orderResponse = await client
        .from('orders')
        .insert(orderData)
        .select()
        .single();

    for (final item in items) {
      await client.from('order_items').insert({
        'order_id': orderId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price': item['price'],
      });
    }

    return orderResponse as Map<String, dynamic>;
  }

  static Future<void> cancelOrder(String orderId) async {
    await client
        .from('orders')
        .update({'status': 'Cancelled'}).eq('id', orderId);
  }

  // ==========================================
  // Admin Methods - Orders
  // ==========================================

  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      // First try to get orders with user details if the relation exists
      try {
        final response = await client
            .from('orders')
            .select('''
              *,
              users (name, email),
              order_items(
                quantity,
                price,
                products(id, name, image_url)
              )
            ''')
            .order('created_at', ascending: false);
        return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (e) {
        debugPrint('Failed to join users table in getAllOrders, falling back to basic orders. Error: $e');
        // Fallback: just get the orders without the users table if relation is missing
        final response = await client
            .from('orders')
            .select('''
              *,
              order_items(
                quantity,
                price,
                products(id, name, image_url)
              )
            ''')
            .order('created_at', ascending: false);
        return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e, stacktrace) {
      debugPrint('Exception in getAllOrders: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception('Failed to get all orders: $e');
    }
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await client
          .from('orders')
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // ==========================================
  // Admin Methods - Users
  // ==========================================

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      // نستخدم دالة RPC لتجاوز حماية RLS وجلب كل المستخدمين إذا كان الشخص أدمن
      final response = await client.rpc('get_admin_users_list');
      if (response != null) {
        return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }
  
  static Future<void> updateUserRole(String userId, String role) async {
    try {
      // نستخدم دالة RPC لتجاوز حماية RLS وتحديث الصلاحية إذا كان الطالب أدمن
      final response = await client.rpc('update_user_role', params: {
        'target_user_id': userId,
        'new_role': role,
      });
      
      if (response == false) {
        throw Exception('You do not have permission to perform this action.');
      }
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // ==========================================
  // Admin Methods - Analytics
  // ==========================================

  static Future<Map<String, dynamic>> getAdminAnalytics() async {
    try {
      final response = await client.rpc('get_admin_analytics');
      if (response != null && response is List && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }
      return {
        'total_products': 0,
        'total_orders': 0,
        'total_users': 0,
        'total_revenue': 0,
        'pending_orders': 0,
        'completed_orders': 0,
        'active_coupons': 0,
      };
    } catch (e) {
      throw Exception('Failed to get admin analytics: $e');
    }
  }

  // ==========================================
  // Admin Methods - Categories
  // ==========================================

  static Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final response = await client
          .from('categories')
          .select('*')
          .order('name', ascending: true);
      return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  static Future<Map<String, dynamic>> addCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await client
          .from('categories')
          .insert(categoryData)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  static Future<void> updateCategory(String id, Map<String, dynamic> categoryData) async {
    try {
      await client
          .from('categories')
          .update(categoryData)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  static Future<void> deleteCategory(String id) async {
    try {
      await client
          .from('categories')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // ==========================================
  // Admin Methods - Coupons
  // ==========================================

  static Future<List<Map<String, dynamic>>> getAllCoupons() async {
    try {
      final response = await client
          .from('coupons')
          .select('*')
          .order('created_at', ascending: false);
      return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      throw Exception('Failed to get coupons: $e');
    }
  }

  static Future<Map<String, dynamic>> addCoupon(Map<String, dynamic> couponData) async {
    try {
      final response = await client
          .from('coupons')
          .insert(couponData)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to add coupon: $e');
    }
  }

  static Future<void> updateCoupon(String id, Map<String, dynamic> couponData) async {
    try {
      await client
          .from('coupons')
          .update(couponData)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update coupon: $e');
    }
  }

  static Future<void> deleteCoupon(String id) async {
    try {
      await client
          .from('coupons')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete coupon: $e');
    }
  }

  // ==========================================
  // Reviews Methods
  // ==========================================

  static Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    try {
      final response = await client
          .from('product_reviews')
          .select('*')
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Failed to get product reviews: $e');
      return [];
    }
  }

  static Future<bool> hasUserPurchasedProduct(String userId, String productId) async {
    try {
      // Check if there is a completed/delivered order containing this product for this user
      final response = await client
          .from('orders')
          .select('id, status, order_items!inner(product_id)')
          .eq('user_id', userId)
          .eq('order_items.product_id', productId)
          .neq('status', 'Cancelled') // Assumes non-cancelled orders count, or you could strictly check for 'Delivered'
          .limit(1)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      debugPrint('Error checking purchase history: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> addReview({
    required String productId,
    required String userId,
    required double rating,
    required String comment,
  }) async {
    try {
      // Fetch user name to store it directly with the review
      String userName = 'مستخدم';
      try {
        final userData = await client
            .from('users')
            .select('name')
            .eq('uid', userId)
            .maybeSingle();
        if (userData != null && userData['name'] != null && (userData['name'] as String).isNotEmpty) {
          userName = userData['name'];
        }
      } catch (_) {
        // ignore, use default name
      }

      final response = await client
          .from('product_reviews')
          .insert({
            'product_id': productId,
            'user_id': userId,
            'user_name': userName,
            'rating': rating,
            'comment': comment,
          })
          .select('*')
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // ==========================================
  // Admin Methods - Banners
  // ==========================================

  static Future<List<Map<String, dynamic>>> getAllBanners() async {
    try {
      final response = await client
          .from('banners')
          .select('*')
          .order('created_at', ascending: false);
      return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Failed to get banners: $e');
      return []; // Return empty list if table doesn't exist yet
    }
  }

  static Future<Map<String, dynamic>> addBanner(Map<String, dynamic> bannerData) async {
    try {
      final response = await client
          .from('banners')
          .insert(bannerData)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to add banner: $e');
    }
  }

  static Future<void> updateBanner(String id, Map<String, dynamic> bannerData) async {
    try {
      await client
          .from('banners')
          .update(bannerData)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update banner: $e');
    }
  }

  static Future<void> deleteBanner(String id) async {
    try {
      await client
          .from('banners')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete banner: $e');
    }
  }

  static Future<String> uploadBannerImage(File imageFile) async {
    final fileExt = imageFile.path.split('.').last.toLowerCase();
    final fileName =
        'banner_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await client.storage.from('banners').upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    return client.storage.from('banners').getPublicUrl(fileName);
  }
}
