import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/deal_card.dart';
import '../../../shared/widgets/business_card.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../providers/search_provider.dart';
import '../models/search_filters.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_filters_widget.dart';
import '../widgets/search_results_widget.dart';
import '../../cart/widgets/floating_cart_bar.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  
  const SearchResultsScreen({
    super.key,
    this.initialQuery,
  });

  /// Create SearchResultsScreen from query parameter  
  factory SearchResultsScreen.fromQuery(Map<String, String> params) {
    return SearchResultsScreen(initialQuery: params['q']);
  }

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;
  bool _isSearching = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _tabController = TabController(length: 2, vsync: this);
    
    // Perform search if initial query is provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
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
      
      // Also search for businesses
      await ref.read(searchNotifierProvider.notifier).searchBusinesses(query);
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

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchNotifierProvider.notifier).clearResults();
    ref.read(searchFiltersNotifierProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = ref.watch(searchNotifierProvider);
    final filters = ref.watch(searchFiltersNotifierProvider);

    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Results'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Restaurants'),
              Tab(text: 'Food'),
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
        body: Stack(
          children: [
            Column(
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

                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Restaurants Tab
                      _buildRestaurantsTab(searchResult),
                      
                      // Food Tab (Deals)
                      _buildFoodTab(searchResult),
                    ],
                  ),
                ),
              ],
            ),
            // Floating cart bar positioned directly above bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const FloatingCartBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodTab(searchResult) {
    return _isSearching 
        ? const Center(child: CircularProgressIndicator())
        : searchResult.deals.isEmpty && _searchController.text.isNotEmpty
            ? _buildEmptyState('No food deals found for "${_searchController.text}"', Icons.restaurant_menu)
            : searchResult.deals.isEmpty
                ? _buildEmptyState('Enter a search term to find food deals', Icons.restaurant_menu)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: searchResult.deals.length,
                    itemBuilder: (context, index) {
                      final deal = searchResult.deals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DealCard(
                          deal: deal,
                          onTap: () => context.push('/deal/${deal.id}'),
                        ),
                      );
                    },
                  );
  }

  Widget _buildRestaurantsTab(searchResult) {
    return _isSearching
        ? const Center(child: CircularProgressIndicator())
        : searchResult.businesses.isEmpty && _searchController.text.isNotEmpty
            ? _buildEmptyState('No restaurants found for "${_searchController.text}"', Icons.restaurant)
            : searchResult.businesses.isEmpty
                ? _buildEmptyState('Enter a search term to find restaurants', Icons.restaurant)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: searchResult.businesses.length,
                    itemBuilder: (context, index) {
                      final business = searchResult.businesses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                            child: Icon(
                              Icons.restaurant,
                              color: AppTheme.primaryGreen,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            business.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (business.category?.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  business.category!,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                business.displayAddress,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              if (business.activeDeals > 0) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentOrange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${business.activeDeals} active deal${business.activeDeals == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => context.push('/business/${business.id}'),
                        ),
                      );
                    },
                  );
  }

  Widget _buildEmptyState(String message, [IconData? icon]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.search_off,
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
}