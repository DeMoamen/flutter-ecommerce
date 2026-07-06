import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/supabase_service.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  bool _hasPurchased = false;
  double _averageRating = 0.0;
  String? _lastError;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get hasPurchased => _hasPurchased;
  double get averageRating => _averageRating;
  String? get lastError => _lastError;

  Future<void> fetchProductReviews(String productId, String? userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.getProductReviews(productId);
      _reviews = data.map((json) => Review.fromJson(json)).toList();
      
      _calculateAverageRating();

      if (userId != null) {
        _hasPurchased = await SupabaseService.hasUserPurchasedProduct(userId, productId);
      } else {
        _hasPurchased = false;
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateAverageRating() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      return;
    }
    double total = 0;
    for (var r in _reviews) {
      total += r.rating;
    }
    _averageRating = total / _reviews.length;
  }

  Future<bool> addReview({
    required String productId,
    required String userId,
    required double rating,
    required String comment,
  }) async {
    _lastError = null;
    try {
      final data = await SupabaseService.addReview(
        productId: productId,
        userId: userId,
        rating: rating,
        comment: comment,
      );
      
      final newReview = Review.fromJson(data);
      _reviews.insert(0, newReview);
      _calculateAverageRating();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding review: $e');
      _lastError = e.toString();
      return false;
    }
  }
}
