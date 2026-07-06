import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/shop_app_bar.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'wishlist_screen.dart';
import 'orders_screen.dart';
import 'admin_dashboard.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: const ShopAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 32),
            
            // Premium Account Status Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFAA771C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VIP Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Exclusive rewards & free shipping', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            if (authProvider.isAdmin) ...[
              _ProfileGroup(
                title: 'Admin Tools',
                items: [
                  _ProfileItem(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Admin Dashboard',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboard()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            _ProfileGroup(
              title: 'Account Settings',
              items: [
                _ProfileItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
                _ProfileItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'My Orders',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                ),
                _ProfileItem(
                  icon: Icons.favorite_outline_rounded,
                  label: 'Favorites',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WishlistScreen()),
                    );
                  },
                ),
                _ProfileItem(
                  icon: Icons.location_on_outlined,
                  label: 'Addresses',
                  onTap: () {},
                ),
                _ProfileItem(
                  icon: Icons.payment_rounded,
                  label: 'Payments',
                  onTap: () {},
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _ProfileItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              color: Colors.redAccent,
              showArrow: false,
              isDestructive: true,
              onTap: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            
            // Add padding at the bottom so we can scroll past the floating bottom bar
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _ProfileGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _ProfileGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.hintColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i != items.length - 1)
                  Divider(height: 1, indent: 60, endIndent: 20, color: theme.dividerColor.withOpacity(0.5)),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatefulWidget {
  const _ProfileHeader();

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    final error = await context.read<AuthProvider>().uploadProfilePicture(pickedFile.path);

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع الصورة بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final userData = authProvider.userData;
    
    final name = userData?['name'] ?? 'Guest';
    final email = userData?['email'] ?? (authProvider.user?.email ?? 'No email');
    final photoUrl = userData?['photo_url'];

    // Encode name properly for the URL
    final encodedName = Uri.encodeComponent(name);
    final defaultAvatar = 'https://ui-avatars.com/api/?name=$encodedName&background=random';

    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.secondary, width: 2), // Gold border
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  )
                ]
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: NetworkImage(photoUrl != null && photoUrl.toString().isNotEmpty ? photoUrl : defaultAvatar),
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint('Error loading image: $exception');
                },
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
                    ]
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(color: theme.hintColor, fontSize: 15),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool showArrow;
  final bool isDestructive;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.showArrow = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;
    
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: 16,
                color: isDestructive ? Colors.redAccent : null,
              ),
            ),
          ),
          if (showArrow)
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.hintColor.withOpacity(0.5)),
        ],
      ),
    );

    if (isDestructive) {
      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: content,
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: content,
    );
  }
}
