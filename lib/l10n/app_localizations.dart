import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _strings = {
    'ar': {
      'app_name': 'متجر النجوم',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'full_name': 'الاسم الكامل',
      'phone': 'رقم الهاتف',
      'forgot_password': 'نسيت كلمة المرور؟',
      'no_account': 'ليس لديك حساب؟',
      'have_account': 'لديك حساب بالفعل؟',
      'register_now': 'سجّل الآن',
      'login_now': 'سجّل دخولك',
      'welcome_back': 'مرحباً بعودتك!',
      'welcome_subtitle': 'سجّل دخولك للمتابعة',
      'create_account': 'أنشئ حسابك',
      'create_subtitle': 'انضم إلينا وابدأ التسوق',
      'email_required': 'البريد الإلكتروني مطلوب',
      'email_invalid': 'البريد الإلكتروني غير صحيح',
      'password_required': 'كلمة المرور مطلوبة',
      'password_min': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      'name_required': 'الاسم مطلوب',
      'passwords_not_match': 'كلمتا المرور غير متطابقتين',
      'or_continue': 'أو تابع بـ',
      'language': 'English',
      'dark_mode': 'الوضع المظلم',
      'light_mode': 'الوضع المضيء',
      'shopping': 'تسوق',
      'profile': 'الملف الشخصي',
      'cart': 'السلة',
      'home_welcome': 'مرحباً،',
      'search_hint': 'ابحث عن منتجات...',
      'categories': 'التصنيفات',
      'featured': 'منتجات مميزة',
      'view_all': 'عرض الكل',
      'price': 'السعر',
      'add_to_cart': 'أضف إلى السلة',
      'total': 'المجموع',
      'checkout': 'اتمام الشراء',
      'no_items': 'لا توجد منتجات في السلة',
      'description': 'الوصف',
      'reviews': 'مراجعة',
      'select_size': 'اختر المقاس',
      'select_color': 'اختر اللون',
      'wishlist': 'المفضلة',
      'notifications': 'الإشعارات',
      'my_orders': 'طلباتي',
      'no_orders_yet': 'لا توجد طلبات حتى الآن',
    },
    'en': {
      'app_name': 'Star Shop',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email Address',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'full_name': 'Full Name',
      'phone': 'Phone Number',
      'forgot_password': 'Forgot Password?',
      'no_account': "Don't have an account?",
      'have_account': 'Already have an account?',
      'register_now': 'Register Now',
      'login_now': 'Login Now',
      'welcome_back': 'Welcome Back!',
      'welcome_subtitle': 'Sign in to continue',
      'create_account': 'Create Account',
      'create_subtitle': 'Join us and start shopping',
      'email_required': 'Email is required',
      'email_invalid': 'Enter a valid email address',
      'password_required': 'Password is required',
      'password_min': 'Password must be at least 6 characters',
      'name_required': 'Name is required',
      'passwords_not_match': 'Passwords do not match',
      'or_continue': 'Or continue with',
      'language': 'العربية',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'shopping': 'Shopping',
      'profile': 'Profile',
      'cart': 'Cart',
      'home_welcome': 'Hi,',
      'search_hint': 'Search products...',
      'categories': 'Categories',
      'featured': 'Featured Products',
      'view_all': 'View All',
      'price': 'Price',
      'add_to_cart': 'Add to Cart',
      'total': 'Total',
      'checkout': 'Checkout',
      'no_items': 'No items in cart',
      'description': 'Description',
      'reviews': 'Reviews',
      'select_size': 'Select Size',
      'select_color': 'Select Color',
      'wishlist': 'Wishlist',
      'notifications': 'Notifications',
      'my_orders': 'My Orders',
      'no_orders_yet': 'No orders yet',
    },
  };

  String get(String key) {
    final code = locale.languageCode;
    return _strings[code]?[key] ?? _strings['en']![key] ?? key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
