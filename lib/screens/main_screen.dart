import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // إعادة جلب المنتجات والتصنيفات بعد تسجيل الدخول (باستخدام جلسة المستخدم الحالية)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const WishlistScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final cartProvider = context.watch<CartProvider>();
    final isArabic = provider.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBody: false, // الشاشة تنتهي فوق التاب بار مباشرة ولا تنزل خلفه
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: theme.colorScheme.surface.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) => setState(() => _selectedIndex = index),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: theme.colorScheme.secondary,
                  unselectedItemColor: theme.hintColor.withOpacity(0.4),
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  showUnselectedLabels: true,
                  items: [
                    BottomNavigationBarItem(
                      icon: _buildIcon(Icons.home_outlined, Icons.home_rounded, 0),
                      label: loc.get('shopping'),
                    ),
                    BottomNavigationBarItem(
                      icon: _buildIcon(Icons.favorite_border_rounded, Icons.favorite_rounded, 1),
                      label: loc.get('wishlist') ?? 'Wishlist',
                    ),
                    BottomNavigationBarItem(
                      icon: cartProvider.itemCount == 0 
                        ? _buildIcon(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, 2)
                        : Badge(
                            backgroundColor: theme.colorScheme.secondary,
                            label: Text('${cartProvider.itemCount}', style: TextStyle(color: theme.colorScheme.onSecondary)),
                            child: _buildIcon(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, 2),
                          ),
                      label: loc.get('cart'),
                    ),
                    BottomNavigationBarItem(
                      icon: _buildIcon(Icons.person_outline_rounded, Icons.person_rounded, 3),
                      label: loc.get('profile'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData outline, IconData filled, int index) {
    bool isSelected = _selectedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.secondary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(isSelected ? filled : outline),
    );
  }
}
