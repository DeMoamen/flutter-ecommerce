import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    final List<Map<String, String>> notifications = [
      {
        'title': 'Order Shipped!',
        'body': 'Your order #12345 has been shipped and is on its way.',
        'time': '2 hours ago',
        'icon': 'shipping'
      },
      {
        'title': 'New Flash Sale!',
        'body': 'Get up to 50% off on all summer collections.',
        'time': '5 hours ago',
        'icon': 'sale'
      },
      {
        'title': 'Price Drop',
        'body': 'A product in your wishlist is now 10% cheaper!',
        'time': 'Yesterday',
        'icon': 'price'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('notifications')),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 80, color: theme.hintColor.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: theme.hintColor)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          notif['icon'] == 'shipping'
                              ? Icons.local_shipping_rounded
                              : notif['icon'] == 'sale'
                                  ? Icons.flash_on_rounded
                                  : Icons.trending_down_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['title']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif['body']!,
                              style: TextStyle(color: theme.hintColor, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notif['time']!,
                              style: TextStyle(color: theme.hintColor.withOpacity(0.6), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
