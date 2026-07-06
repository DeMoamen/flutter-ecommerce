import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AdminOrderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchAllOrders() async {
    _setLoading(true);
    _error = null;
    try {
      _orders = await SupabaseService.getAllOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    _setLoading(true);
    _error = null;
    try {
      await SupabaseService.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((o) => o['id'] == orderId);
      if (index >= 0) {
        _orders[index]['status'] = status;
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
