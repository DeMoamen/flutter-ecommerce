import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await SupabaseService.getAllProducts();
      debugPrint('DEBUG: Fetched ${_products.length} products from Supabase');
      debugPrint('DEBUG: Featured products count = ${_products.where((p) => p.isFeatured).length}');
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    String category = 'General',
    bool isFeatured = false,
  }) async {
    final newProduct = await SupabaseService.addProduct(
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      isFeatured: isFeatured,
    );
    _products.insert(0, newProduct);
    notifyListeners();
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    String category = 'General',
    bool isFeatured = false,
  }) async {
    final updatedProduct = await SupabaseService.updateProduct(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      isFeatured: isFeatured,
    );
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    await SupabaseService.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  List<Product> get products => [..._products];

  List<Product> get featuredProducts {
    return _products.where((p) => p.isFeatured).toList();
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((p) => p.id == id);
  }

  List<Product> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return _products.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
             p.category.toLowerCase().contains(lowerQuery) ||
             p.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
