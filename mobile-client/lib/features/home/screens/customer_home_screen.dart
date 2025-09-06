import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/app_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../auth/widgets/restaurant_owner_cta_card.dart';
import '../providers/enhanced_home_provider.dart';
import '../../location/providers/location_provider.dart';
import '../../location/widgets/location_header.dart';
import '../widgets/business_card_widget.dart';
import '../widgets/enhanced_deal_card.dart';
import '../../cart/widgets/floating_cart_bar.dart';


class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    print('🔄 Loading initial location-based data...');
    ref.read(enhancedHomeProvider.notifier).loadNearbyContent();
  }

  void _onScroll() {
    // For now, we don't have pagination for location-based content
    // This can be added later if needed
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️  BUILD: CustomerHomeScreen.build() called');
    final enhancedHomeState = ref.watch(enhancedHomeProvider);
    print('🏗️  BUILD: enhancedHomeState - isLoadingDeals: ${enhancedHomeState.isLoadingDeals}, deals: ${enhancedHomeState.nearbyDeals.length}');
    final currentUserAsync = ref.watch(currentAuthUserProvider);
    print('🏗️  BUILD: currentUserAsync state: ${currentUserAsync.runtimeType}');
    
    return currentUserAsync.when(
      data: (currentUser) {
        print('🏗️  BUILD: currentUserAsync.data - user: ${currentUser?.name}, isBusiness: ${currentUser?.isBusiness}');
        if (currentUser == null) {
          print('🏗️  BUILD: No user - showing no user state');
          return _buildNoUserState();
        }
        if (currentUser.isBusiness) {
          print('🏗️  BUILD: Business user - showing business state');
          return _buildBusinessUserState();
        }
        print('🏗️  BUILD: Customer user - showing customer home content');
        return _buildCustomerHomeContent(enhancedHomeState, currentUser);
      },
      loading: () {
        print('🏗️  BUILD: currentUserAsync.loading - showing auth loading');
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
        );
      },
      error: (error, stack) {
        print('🏗️  BUILD: currentUserAsync.error - $error');
        return _buildErrorState(error);
      },
    );
  }

  Widget _buildCustomerHomeContent(EnhancedHomeState enhancedHomeState, AppUser currentUser) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await ref.read(enhancedHomeProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location header
                  LocationHeader(
                    onLocationChanged: () {
                      // Refresh nearby content when location changes
                      ref.read(enhancedHomeProvider.notifier).loadNearbyContent();
                    },
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  _buildStandaloneSearchBar(),
                  const SizedBox(height: 24),
                  // Category icons
                  _buildCategoryIcons(),
                  
                  const SizedBox(height: 24),
                  
                  // Location-based sections
                  _buildLocationBasedSections(enhancedHomeState),
                  
                  // Loading indicator
                  if (enhancedHomeState.isLoadingDeals || enhancedHomeState.isLoadingBusinesses)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                      ),
                    ),
                        
                  const SizedBox(height: 180), // Extra space for bottom nav and cart bar
                ],
              ),
            ),
          ),
          // Floating cart bar positioned directly above bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // Sit directly on top of bottom navigation
            child: const FloatingCartBar(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(currentUser),
    );
  }


  Widget _buildCategoryIcons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryIcon(
            'Pickup Now',
            const Color(0xFFFF6B35), // Orange like Yindii
            Icons.access_time_filled,
            () => _handleCategoryTap('pickup_now'),
          ),
          _buildCategoryIcon(
            'Near Me',
            const Color(0xFF4A90E2), // Blue like Yindii
            Icons.location_on,
            () => _handleCategoryTap('near_me'),
          ),
          _buildCategoryIcon(
            'Top Deals',
            const Color(0xFFFFC107), // Yellow like Yindii
            Icons.local_offer,
            () => _handleCategoryTap('top_deals'),
          ),
          _buildCategoryIcon(
            'Best Reviews',
            const Color(0xFF4CAF50), // Green like Yindii
            Icons.star,
            () => _handleCategoryTap('best_reviews'),
          ),
          _buildCategoryIcon(
            'Meals',
            const Color(0xFF9C27B0), // Purple like Yindii
            Icons.restaurant_menu,
            () => _handleCategoryTap('meals'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String label, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainCarouselBanner() {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PageView.builder(
            itemCount: 3, // 3 different promotional slides
            itemBuilder: (context, index) => _buildPromoSlide(index),
          ),
        ),
      ),
    );
  }

  Widget _buildStandaloneSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for meal and restaurant...',
          hintStyle: const TextStyle(
            color: Color(0xFFB0B0B0),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onTap: () {
          // Navigate to search results screen when field is tapped
          context.push('/search-results');
        },
        onSubmitted: (query) {
          // Navigate to search results screen with the search query
          if (query.isNotEmpty) {
            context.push('/search-results?q=${Uri.encodeQueryComponent(query)}');
          } else {
            context.push('/search-results');
          }
        },
        onChanged: (query) {
          // Real-time search as user types
          if (query.isEmpty) {
            ref.read(enhancedHomeProvider.notifier).clearSearch();
          }
        },
      ),
    );
  }

  
  Widget _buildPromoSlide(int index) {
    final promoData = [
      {
        'title': 'SUPER DEALS',
        'subtitle': 'Up to 70% OFF',
        'description': 'on selected meals',
        'images': [
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=150',
          'https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=150',
          'https://images.unsplash.com/photo-1604382355076-af4b0eb60143?w=150',
          'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=150',
        ],
        'discounts': ['-40%', '-35%', '-50%', '-30%'],
        'gradient': [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      },
      {
        'title': 'FLASH SALE',
        'subtitle': 'Save Big Today',
        'description': 'limited time only',
        'images': [
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=150',
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=150',
          'https://images.unsplash.com/photo-1559054663-e52010bf52f2?w=150',
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=150',
        ],
        'discounts': ['-60%', '-45%', '-55%', '-40%'],
        'gradient': [Color(0xFFE91E63), Color(0xFFAD1457)],
      },
      {
        'title': 'WEEKEND SPECIAL',
        'subtitle': 'Best Picks',
        'description': 'for the weekend',
        'images': [
          'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=150',
          'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=150',
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=150',
          'https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=150',
        ],
        'discounts': ['-25%', '-30%', '-35%', '-20%'],
        'gradient': [Color(0xFF673AB7), Color(0xFF3F51B5)],
      },
    ];
    
    final data = promoData[index];
    final gradient = data['gradient'] as List<Color>;
    final images = data['images'] as List<String>;
    final discounts = data['discounts'] as List<String>;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomPaint(
                painter: DotPatternPainter(),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Left side - Text content
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['title'] as String,
                          style: const TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['subtitle'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        data['description'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Right side - Food images
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildFoodImageCard(images[0], discounts[0]),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFoodImageCard(images[1], discounts[1]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFoodImageCard(images[2], discounts[2]),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFoodImageCard(images[3], discounts[3]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImageCard(String imageUrl, String discount) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restaurant, color: Colors.white),
                );
              },
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                discount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLocationBasedSections(EnhancedHomeState enhancedHomeState) {
    print('🎨 UI_BUILD: _buildLocationBasedSections called');
    print('🎨 UI_BUILD: isLoadingDeals: ${enhancedHomeState.isLoadingDeals}');
    print('🎨 UI_BUILD: isLoadingBusinesses: ${enhancedHomeState.isLoadingBusinesses}');
    print('🎨 UI_BUILD: nearbyDeals.length: ${enhancedHomeState.nearbyDeals.length}');
    print('🎨 UI_BUILD: nearbyBusinesses.length: ${enhancedHomeState.nearbyBusinesses.length}');
    
    final notifier = ref.read(enhancedHomeProvider.notifier);
    
    // Check if we're showing search results
    if (notifier.isShowingSearchResults) {
      return _buildSearchResults(enhancedHomeState);
    }
    
    // Show loading state for initial load
    if ((enhancedHomeState.isLoadingDeals || enhancedHomeState.isLoadingBusinesses) &&
        enhancedHomeState.nearbyDeals.isEmpty && 
        enhancedHomeState.nearbyBusinesses.isEmpty) {
      print('🎨 UI_BUILD: Showing loading spinner');
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
      );
    }
    
    // Show error state
    if (enhancedHomeState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFE53935),
              ),
              const SizedBox(height: 16),
              Text(
                enhancedHomeState.error!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(enhancedHomeProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurants Near You section
        if (enhancedHomeState.nearbyBusinesses.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Restaurants Near You',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: enhancedHomeState.nearbyBusinesses.length,
            itemBuilder: (context, index) {
              final businessWithDistance = enhancedHomeState.nearbyBusinesses[index];
              return BusinessCardWidget(
                businessWithDistance: businessWithDistance,
                onTap: () => _handleBusinessTap(businessWithDistance.business.id),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
        
        // Deals Near You section
        if (enhancedHomeState.nearbyDeals.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Deals Near You',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 380,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: enhancedHomeState.nearbyDeals.length,
              itemBuilder: (context, index) {
                final dealWithDistance = enhancedHomeState.nearbyDeals[index];
                return EnhancedDealCard(
                  dealWithDistance: dealWithDistance,
                  onTap: () => _handleDealTap(dealWithDistance.deal.id),
                );
              },
            ),
          ),
        ],
        
        // Empty state when no nearby content
        if (enhancedHomeState.nearbyDeals.isEmpty && enhancedHomeState.nearbyBusinesses.isEmpty) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Color(0xFFBDBDBD),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No nearby businesses found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF757575),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try expanding your search radius or check back later!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9E9E9E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResults(EnhancedHomeState enhancedHomeState) {
    final searchResults = enhancedHomeState.searchResults!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search results header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Search Results for "${enhancedHomeState.searchQuery}"',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${searchResults.totalResults} results found',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Restaurants in search results
        if (searchResults.businesses.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Restaurants (${searchResults.businesses.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchResults.businesses.length,
            itemBuilder: (context, index) {
              final businessWithDistance = searchResults.businesses[index];
              return BusinessCardWidget(
                businessWithDistance: businessWithDistance,
                onTap: () => _handleBusinessTap(businessWithDistance.business.id),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
        
        // Deals in search results
        if (searchResults.deals.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Deals (${searchResults.deals.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 380,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: searchResults.deals.length,
              itemBuilder: (context, index) {
                final dealWithDistance = searchResults.deals[index];
                return EnhancedDealCard(
                  dealWithDistance: dealWithDistance,
                  onTap: () => _handleDealTap(dealWithDistance.deal.id),
                );
              },
            ),
          ),
        ],
        
        // No search results
        if (searchResults.businesses.isEmpty && searchResults.deals.isEmpty) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Color(0xFFBDBDBD),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF757575),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try different keywords or check your spelling.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9E9E9E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBecomePartnerLink() {
    return const RestaurantOwnerCtaCompact();
  }

  void _handleCategoryTap(String category) {
    // Handle category navigation with location-aware search
    final enhancedNotifier = ref.read(enhancedHomeProvider.notifier);
    switch (category) {
      case 'pickup_now':
        enhancedNotifier.search('pickup');
        break;
      case 'near_me':
        // This will show nearby content without search query
        enhancedNotifier.clearSearch();
        break;
      case 'top_deals':
        enhancedNotifier.search('discount deal');
        break;
      case 'best_reviews':
        enhancedNotifier.search('popular');
        break;
      case 'meals':
        enhancedNotifier.search('food meal');
        break;
    }
  }

  void _handleBusinessTap(String businessId) {
    // Navigate to business details page
    context.go('/business/$businessId');
  }

  void _handleDealTap(String dealId) {
    // Navigate to deal details page
    context.go('/deal-details/$dealId');
  }

  Widget _buildNoUserState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'foodq',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Loading your account...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessUserState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business,
                size: 64,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Business User Detected',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Switch to the business dashboard\nto manage your deals and orders',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/business-home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dashboard, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Business Dashboard',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53935),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(currentAuthUserProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(AppUser currentUser) {
    return CustomBottomNav(
      currentIndex: 0, // Home tab index
      currentUser: currentUser,
      onTap: (index) => _handleBottomNavTap(index, currentUser),
    );
  }



  void _handleBottomNavTap(int index, AppUser currentUser) {
    switch (index) {
      case 0:
        // Already on customer home
        break;
      case 1:
        context.go('/search-results');
        break;
      case 2:
        context.go('/favorites');
        break;
      case 3:
        context.go('/orders');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

}

class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    const dotRadius = 2.0;
    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Add some randomness to make it look more organic
        final offsetX = x + (y % 2 == 0 ? 0 : spacing / 2);
        canvas.drawCircle(Offset(offsetX, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}