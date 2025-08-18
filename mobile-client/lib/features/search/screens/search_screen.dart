import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/deal_card.dart';
import '../../../shared/widgets/business_card.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/app_user.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../providers/search_provider.dart';
import '../models/search_filters.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_filters_widget.dart';
import '../widgets/quick_filters_widget.dart';
import '../widgets/search_results_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;
  bool _isSearching = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      await ref.read(searchNotifierProvider.notifier).getTrendingDeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load deals: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final filters = ref.read(searchFiltersNotifierProvider);
      await ref.read(searchNotifierProvider.notifier).searchDeals(
        query: query,
        filters: filters.hasActiveFilters ? filters : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _performNearbySearch() async {
    // In a real app, you'd get location permission and coordinates
    // For demo, using NYC coordinates
    const latitude = 40.7128;
    const longitude = -74.0060;

    setState(() => _isSearching = true);

    try {
      await ref.read(searchNotifierProvider.notifier).searchNearbyDeals(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nearby search failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchNotifierProvider.notifier).clearResults();
    ref.read(searchFiltersNotifierProvider.notifier).clearFilters();
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = ref.watch(searchNotifierProvider);
    final filters = ref.watch(searchFiltersNotifierProvider);

    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Deals'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Deals'),
              Tab(text: 'Restaurants'),
              Tab(text: 'Nearby'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
                color: filters.hasActiveFilters ? AppTheme.accentOrange : null,
              ),
              onPressed: _toggleFilters,
            ),
            if (_searchController.text.isNotEmpty || searchResult.hasResults)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [AppTheme.subtleShadow],
              ),
              child: SearchBarWidget(
                controller: _searchController,
                onSearch: _performSearch,
                isLoading: _isSearching,
                hintText: 'Search for deals, restaurants, cuisines...',
              ),
            ),

            // Filters (collapsible)
            if (_showFilters)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: SearchFiltersWidget(
                  filters: filters,
                  onFiltersChanged: (newFilters) {
                    ref.read(searchFiltersNotifierProvider.notifier)
                        .updateFilters(newFilters);
                    // Re-run search with new filters if there's a query
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  },
                ),
              ),

            // Quick Filters
            if (!_showFilters)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: QuickFiltersWidget(
                  onFilterSelected: (quickFilter) {
                    ref.read(searchFiltersNotifierProvider.notifier)
                        .updateFilters(quickFilter);
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    } else {
                      // Load data based on quick filter
                      _loadQuickFilterData(quickFilter);
                    }
                  },
                ),
              ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Deals Tab
                  _buildDealsTab(searchResult),
                  
                  // Restaurants Tab
                  _buildRestaurantsTab(searchResult),
                  
                  // Nearby Tab
                  _buildNearbyTab(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Consumer(
      builder: (context, ref, child) {
        final currentUserAsync = ref.watch(authenticatedUserProvider);
        
        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) {
              // Show minimal navigation for guest state
              return Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Center(
                    child: Text(
                      'Select a user to access navigation',
                      style: TextStyle(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }
            
            // Show appropriate navigation based on user type
            return CustomBottomNav(
              currentIndex: 1, // Search tab index
              currentUser: currentUser,
              onTap: (index) => _handleBottomNavTap(index, currentUser),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  void _handleBottomNavTap(int index, AppUser currentUser) {
    // Handle navigation based on user type and selected tab
    switch (index) {
      case 0:
        // Navigate to appropriate home screen
        if (currentUser.isBusiness) {
          context.go('/business-home');
        } else {
          context.go('/home');
        }
        break;
      case 1:
        // Already on search - do nothing
        break;
      case 2:
        if (currentUser.isBusiness) {
          context.go('/deals');
        } else {
          context.go('/favorites');
        }
        break;
      case 3:
        context.go('/orders');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  Widget _buildDealsTab(searchResult) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchResult.deals.isEmpty && searchResult.query != null) {
      return _buildEmptyState('No deals found for "${searchResult.query}"');
    }

    if (searchResult.deals.isEmpty) {
      return _buildTrendingDeals();
    }

    return SearchResultsWidget(
      searchResult: searchResult,
      onDealTap: (deal) => context.push('/deal/${deal.id}'),
      onBusinessTap: (business) => context.push('/business/${business.id}'),
    );
  }

  Widget _buildRestaurantsTab(searchResult) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search restaurants...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (query) async {
              setState(() => _isSearching = true);
              try {
                await ref.read(searchNotifierProvider.notifier)
                    .searchBusinesses(query);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Search failed: $e')),
                  );
                }
              } finally {
                setState(() => _isSearching = false);
              }
            },
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : searchResult.businesses.isEmpty
                  ? _buildEmptyState('Search for restaurants above')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: searchResult.businesses.length,
                      itemBuilder: (context, index) {
                        final business = searchResult.businesses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BusinessCard(
                            business: business,
                            onTap: () => context.push('/business/${business.id}'),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildNearbyTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _performNearbySearch,
            icon: const Icon(Icons.location_on),
            label: const Text('Find Deals Near Me'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
        Expanded(
          child: _buildDealsTab(ref.watch(searchNotifierProvider)),
        ),
      ],
    );
  }

  Widget _buildTrendingDeals() {
    return Consumer(
      builder: (context, ref, child) {
        final trendingAsync = ref.watch(trendingDealsProvider);
        
        return trendingAsync.when(
          data: (deals) => deals.isEmpty
              ? _buildEmptyState('No trending deals available')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Trending Deals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: deals.length,
                        itemBuilder: (context, index) {
                          final deal = deals[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DealCard(
                              deal: deal,
                              onTap: () => context.push('/deal/${deal.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildEmptyState('Failed to load trending deals'),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _loadQuickFilterData(SearchFilters quickFilter) async {
    setState(() => _isSearching = true);
    
    try {
      if (quickFilter.isExpiringSoon) {
        await ref.read(searchNotifierProvider.notifier).getExpiringSoonDeals();
      } else {
        await ref.read(searchNotifierProvider.notifier).searchDeals(
          query: '',
          filters: quickFilter,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load deals: $e')),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }
}