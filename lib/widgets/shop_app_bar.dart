import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';

/// Reusable AppBar for the E-Commerce app with:
/// - Dark/Light mode toggle
/// - Language toggle (AR / EN)
/// - Optional cart icon with badge
/// - Optional back button

class ShopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showCart;
  final bool showBack;
  final bool showNotifications;
  final int cartCount;
  final VoidCallback? onCartTap;
  final VoidCallback? onNotificationTap;
  final List<Widget>? actions;

  const ShopAppBar({
    super.key,
    this.title,
    this.showCart = false,
    this.showBack = false,
    this.showNotifications = false,
    this.cartCount = 0,
    this.onCartTap,
    this.onNotificationTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loc = AppLocalizations.of(context);
    final isDark = provider.isDark;
    final isArabic = provider.isArabic;
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: showBack,
      title: Text(
        title ?? loc.get('app_name'),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: theme.appBarTheme.titleTextStyle?.color,
        ),
      ),
      actions: [
        if (actions != null) ...actions!,

        // ── Notifications icon ──────────────────────────────────────────
        if (showNotifications)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: loc.get('notifications'),
            onPressed: onNotificationTap,
          ),

        // ── Cart icon ──────────────────────────────────────────────────
        if (showCart)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: loc.get('cart'),
                onPressed: onCartTap,
              ),
            ),
          ),

        // ── Language toggle ────────────────────────────────────────────
        Tooltip(
          message: loc.get('language'),
          child: GestureDetector(
            onTap: () => provider.toggleLanguage(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isArabic ? 'EN' : 'ع',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Dark / Light mode toggle ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                RotationTransition(turns: anim, child: child),
            child: IconButton(
              key: ValueKey(isDark),
              icon: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              ),
              tooltip: isDark ? loc.get('light_mode') : loc.get('dark_mode'),
              onPressed: () => provider.toggleTheme(),
            ),
          ),
        ),
      ],
    );
  }
}
