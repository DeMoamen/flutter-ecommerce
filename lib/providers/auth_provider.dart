import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client = SupabaseService.client;
  
  User? _user;
  Map<String, dynamic>? _userData;
  String? _role;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  String? get role => _role;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _role == 'admin';

  AuthProvider() {
    _user = _client.auth.currentUser;
    if (_user != null) {
      _loadUser();
    }

    _client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        _user = session?.user;
        if (_user != null) {
          await _loadUser();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _userData = null;
        _role = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUser() async {
    await Future.wait([
      _fetchUserData(),
      _fetchUserRole(),
    ]);
  }

  Future<void> _fetchUserData() async {
    if (_user == null) return;
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('uid', _user!.id)
          .maybeSingle();
      if (response != null) {
        _userData = response;
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _fetchUserRole() async {
    if (_user == null) return;
    try {
      debugPrint('Fetching role for user ID: ${_user!.id}');
      final response = await _client
          .from('users')
          .select('user_role')
          .eq('uid', _user!.id)
          .maybeSingle();
      debugPrint('Role query response: $response');
      if (response != null) {
        _role = response['user_role'] as String?;
        debugPrint('User role loaded: $_role');
      } else {
        debugPrint('No profile found for user');
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;
      await _loadUser();
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _user = response.user;
        
        try {
          await _client.from('users').insert({
            'uid': response.user!.id,
            'name': name,
            'email': email,
            'phone': phone,
            'created_at': DateTime.now().toIso8601String(),
            'photo_url': null,
            'user_role': 'user',
          });
        } catch (e) {
          // إذا كان الخطأ هو تكرار المفتاح (بسبب وجود Database Trigger في Supabase ينشئ المستخدم تلقائياً)
          // نقوم بعمل تحديث (Update) للبيانات بدلاً من الإضافة (Insert)
          if (e is PostgrestException && e.code == '23505') {
            await _client.from('users').update({
              'name': name,
              'phone': phone,
            }).eq('uid', response.user!.id);
          } else {
            rethrow;
          }
        }

        await _loadUser();
        notifyListeners();
      }
      
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Error during signup insert: $e');
      return 'An unexpected error occurred: $e';
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_user == null) return 'User not logged in';
    try {
      await _client
          .from('users')
          .update({
            'name': name,
            'phone': phone,
          })
          .eq('uid', _user!.id);
      await _fetchUserData();
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return 'فشل تحديث الملف الشخصي';
    }
  }

  Future<String?> uploadProfilePicture(String imagePath) async {
    if (_user == null) return 'User not logged in';
    try {
      final file = File(imagePath);
      final fileExt = file.path.split('.').last.toLowerCase();
      final fileName = '${_user!.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // Upload to 'avatars' bucket
      await _client.storage.from('avatars').upload(
        fileName,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      
      // Get public URL
      final publicUrl = _client.storage.from('avatars').getPublicUrl(fileName);
      
      // Update users table
      await _client.from('users').update({'photo_url': publicUrl}).eq('uid', _user!.id);
      
      await _fetchUserData();
      notifyListeners();
      return null;
    } on StorageException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return 'An unexpected error occurred';
    }
  }
}
