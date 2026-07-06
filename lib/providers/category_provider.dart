import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/supabase_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider() {
    fetchCategories();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await SupabaseService.getAllCategories();
      _categories = response.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addCategory(Category category) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await SupabaseService.addCategory(category.toInsertMap());
      _categories.add(Category.fromJson(response));
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    _setLoading(true);
    _error = null;
    try {
      await SupabaseService.updateCategory(category.id, category.toUpdateMap());
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index >= 0) {
        _categories[index] = category;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    _setLoading(true);
    _error = null;
    try {
      await SupabaseService.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
