import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  // Analytics
  Map<String, dynamic> _analytics = {};
  
  // Users
  List<Map<String, dynamic>> _users = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get analytics => _analytics;
  List<Map<String, dynamic>> get users => _users;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchAnalytics() async {
    _setLoading(true);
    _error = null;
    try {
      _analytics = await SupabaseService.getAdminAnalytics();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUsers() async {
    _setLoading(true);
    _error = null;
    try {
      _users = await SupabaseService.getAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    _setLoading(true);
    _error = null;
    try {
      await SupabaseService.updateUserRole(userId, role);
      // Update local state
      final index = _users.indexWhere((u) => u['uid'] == userId);
      if (index >= 0) {
        _users[index]['user_role'] = role;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
