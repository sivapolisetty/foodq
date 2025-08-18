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
    final now = DateTime.now();
    
    // Debounce rapid taps
    if (_lastTapTime != null && now.difference(_lastTapTime!) < _tapDebounceTime) {
      debugPrint('🚫 Navigation tap debounced');
      return;
    }
    
    // Prevent tapping the same item
    if (index == widget.currentIndex) {
      return;
    }
    
    _lastTapTime = now;
    
    if (mounted && context.mounted) {
      try {
        widget.onTap?.call(index);
      } catch (e) {
        debugPrint('❌ Navigation tap error: $e');
      }
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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
    );
  }

  List<NavigationItem> _getNavigationItems() {
    if (widget.currentUser!.isBusiness) {
      return [
        NavigationItem(icon: Icons.analytics_rounded, label: 'Dashboard'),
        NavigationItem(icon: Icons.local_offer_rounded, label: 'Deals'),
        NavigationItem(icon: Icons.account_balance_wallet_rounded, label: 'Finances'),
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
    final primaryColor = const Color(0xFF4CAF50);
    final inactiveColor = const Color(0xFF9E9E9E);
    
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        key: label == 'Profile' ? const Key('profile-nav-button') : null,
        onTap: () => _handleTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: isSelected ? BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(1),
                child: Icon(
                  icon,
                  size: isSelected ? 22 : 20,
                  color: isSelected ? primaryColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 3),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 10 : 9,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? primaryColor : inactiveColor,
                    letterSpacing: 0.3,
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