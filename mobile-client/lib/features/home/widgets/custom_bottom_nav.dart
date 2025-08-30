import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../shared/models/app_user.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final AppUser? currentUser;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    this.onTap,
    this.currentUser,
  }) : super(key: key);

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  DateTime? _lastTapTime;
  static const Duration _tapDebounceTime = Duration(milliseconds: 500);

  void _handleTap(int index) {
    debugPrint('🔘 CustomBottomNav: Tap detected on index $index, currentIndex: ${widget.currentIndex}');
    final now = DateTime.now();
    
    // Debounce rapid taps
    if (_lastTapTime != null && now.difference(_lastTapTime!) < _tapDebounceTime) {
      debugPrint('🚫 Navigation tap debounced');
      return;
    }
    
    // Prevent tapping the same item
    if (index == widget.currentIndex) {
      debugPrint('🚫 Navigation tap blocked - same index');
      return;
    }
    
    _lastTapTime = now;
    
    if (mounted && context.mounted) {
      try {
        debugPrint('🎯 CustomBottomNav: Calling onTap with index $index');
        widget.onTap?.call(index);
      } catch (e) {
        debugPrint('❌ Navigation tap error: $e');
      }
    } else {
      debugPrint('❌ CustomBottomNav: Not mounted or context not mounted');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUser == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 72,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: const Color(0xFF9E9E9E),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final navItems = _getNavigationItems();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.08),
            width: 0.5,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Expanded(
                    child: _buildNavItem(
                      icon: item.icon,
                      label: item.label,
                      index: index,
                      isSelected: widget.currentIndex == index,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<NavigationItem> _getNavigationItems() {
    final items = widget.currentUser!.isBusiness ? [
      NavigationItem(icon: Icons.analytics_rounded, label: 'Dashboard'),
      NavigationItem(icon: Icons.local_offer_rounded, label: 'Deals'),
      NavigationItem(icon: Icons.qr_code_scanner_rounded, label: 'Scanner'),
      NavigationItem(icon: Icons.shopping_bag_rounded, label: 'Orders'),
      NavigationItem(icon: Icons.account_circle_rounded, label: 'Profile'),
    ] : [
      NavigationItem(icon: Icons.home_rounded, label: 'Home'),
      NavigationItem(icon: Icons.search_rounded, label: 'Search'),
      NavigationItem(icon: Icons.favorite_rounded, label: 'Favorites'),
      NavigationItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
      NavigationItem(icon: Icons.account_circle_rounded, label: 'Profile'),
    ];
    
    debugPrint('🔘 Navigation items generated: ${items.map((e) => e.label).toList()}');
    return items;
  }

  List<NavigationItem> _getNavigationItemsOld() {
    if (widget.currentUser!.isBusiness) {
      return [
        NavigationItem(icon: Icons.analytics_rounded, label: 'Dashboard'),
        NavigationItem(icon: Icons.local_offer_rounded, label: 'Deals'),
        NavigationItem(icon: Icons.qr_code_scanner_rounded, label: 'Scanner'),
        NavigationItem(icon: Icons.shopping_bag_rounded, label: 'Orders'),
        NavigationItem(icon: Icons.account_circle_rounded, label: 'Profile'),
      ];
    } else {
      return [
        NavigationItem(icon: Icons.home_rounded, label: 'Home'),
        NavigationItem(icon: Icons.search_rounded, label: 'Search'),
        NavigationItem(icon: Icons.favorite_rounded, label: 'Favorites'),
        NavigationItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
        NavigationItem(icon: Icons.account_circle_rounded, label: 'Profile'),
      ];
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    const primaryColor = Color(0xFF4CAF50);
    const inactiveColor = Color(0xFF9E9E9E);
    
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        key: label == 'Profile' ? const Key('profile-nav-button') : null,
        onTap: () => _handleTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: isSelected ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.12),
                primaryColor.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: isSelected ? BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ) : null,
                  child: Icon(
                    icon,
                    size: isSelected ? 24 : 22,
                    color: isSelected ? primaryColor : inactiveColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 10.5 : 9.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? primaryColor : inactiveColor,
                    letterSpacing: isSelected ? 0.2 : 0.1,
                    height: 1.1,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.label,
  });
}