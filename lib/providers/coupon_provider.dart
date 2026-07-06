import 'package:flutter/material.dart';
import '../models/coupon.dart';
import '../services/supabase_service.dart';

class CouponProvider with ChangeNotifier {
  List<Coupon> _coupons = [];
  bool _isLoading = false;
  String? _error;

  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CouponProvider() {
    fetchCoupons();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchCoupons() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await SupabaseService.getAllCoupons();
      _coupons = response.map((json) => Coupon.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addCoupon(Coupon coupon) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await SupabaseService.addCoupon(coupon.toInsertMap());
      _coupons.add(Coupon.fromJson(response));
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCoupon(Coupon coupon) async {
    _setLoading(true);
    _error = null;
    try {
      await SupabaseService.updateCoupon(coupon.id, coupon.toUpdateMap());
      final index = _coupons.indexWhere((c) => c.id == coupon.id);
      if (index >= 0) {
        _coupons[index] = coupon;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteCoupon(String id) async {
    _setLoading(true);
    _error = null;
    try {
      await SupabaseService.deleteCoupon(id);
      _coupons.removeWhere((c) => c.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
