import 'package:flutter/material.dart';
import '../models/business.dart';
import '../models/deal.dart';
import '../services/business_service.dart';
import '../services/deal_service.dart';
import '../widgets/yindii_app_bar.dart';
import '../widgets/yindii_button.dart';
import '../widgets/yindii_bottom_nav.dart';
import '../widgets/deal_card.dart';
import '../widgets/yindii_input_field.dart';
import 'add_edit_deal_screen.dart';

class DealManagementScreen extends StatefulWidget {
  final BusinessService businessService;
  final DealService dealService;
  final String ownerId;

  const DealManagementScreen({
    Key? key,
    required this.businessService,
    required this.dealService,
    required this.ownerId,
  }) : super(key: key);

  @override
  State<DealManagementScreen> createState() => _DealManagementScreenState();
}

class _DealManagementScreenState extends State<DealManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Business> _businesses = [];
  bool _isLoading = true;
  String _error = '';
  int _selectedBusinessIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinesses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final businesses = await widget.businessService.getBusinessesForOwner(widget.ownerId);
      
      setState(() {
        _businesses = businesses;
        _isLoading = false;
        if (_businesses.isNotEmpty) {
          _tabController = TabController(
            length: _businesses.length,
            vsync: this,
          );
          _tabController.addListener(() {
            if (!_tabController.indexIsChanging) {
              setState(() {
                _selectedBusinessIndex = _tabController.index;
              });
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            )
          : _error.isNotEmpty
              ? _buildErrorState()
              : _businesses.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            YindiiButton(
              text: 'Try Again',
              onPressed: _loadBusinesses,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Businesses Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first business to start managing deals and connecting with customers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            YindiiButton(
              text: 'Create Business',
              onPressed: () {
                // Navigate to create business screen
                // Implementation depends on your routing
              },
              icon: Icons.add,
              width: 250,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          YindiiSliverAppBar(
            title: 'Deal Management',
            backgroundColor: const Color(0xFF2E7D32),
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2E7D32),
                      Color(0xFF388E3C),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 3,
                  ),
                ),
                labelColor: const Color(0xFF2E7D32),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                unselectedLabelColor: Colors.grey.shade600,
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                tabs: _businesses.map((business) => Tab(
                  text: business.name,
                )).toList(),
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: _businesses.map((business) => 
          _DealsTab(
            business: business,
            dealService: widget.dealService,
          ),
        ).toList(),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}

class _DealsTab extends StatefulWidget {
  final Business business;
  final DealService dealService;

  const _DealsTab({
    Key? key,
    required this.business,
    required this.dealService,
  }) : super(key: key);

  @override
  State<_DealsTab> createState() => _DealsTabState();
}

class _DealsTabState extends State<_DealsTab> {
  List<Deal> _deals = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();
  List<Deal> _filteredDeals = [];

  @override
  void initState() {
    super.initState();
    _loadDeals();
    _searchController.addListener(_filterDeals);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeals() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final deals = await widget.dealService.getDealsForBusiness(widget.business.id);
      
      setState(() {
        _deals = deals;
        _filteredDeals = deals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterDeals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDeals = _deals.where((deal) =>
        deal.title.toLowerCase().contains(query) ||
        (deal.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    });
  }

  Future<void> _deleteDeal(Deal deal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deal'),
        content: Text('Are you sure you want to delete "${deal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.dealService.deleteDeal(deal.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal deleted successfully')),
        );
        _loadDeals();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete deal: $e')),
        );
      }
    }
  }

  Future<void> _toggleDealStatus(Deal deal) async {
    try {
      await widget.dealService.toggleDealStatus(deal.id, !deal.isActive);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deal ${deal.isActive ? 'deactivated' : 'activated'} successfully',
          ),
        ),
      );
      _loadDeals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update deal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2E7D32),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load deals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 24),
              YindiiButton(
                text: 'Try Again',
                onPressed: _loadDeals,
                width: 200,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: YindiiSearchField(
            hint: 'Search deals...',
            controller: _searchController,
            onChanged: (_) => _filterDeals(),
            onClear: () {
              _searchController.clear();
              _filterDeals();
            },
          ),
        ),
        // Deals list
        Expanded(
          child: _filteredDeals.isEmpty
              ? _buildEmptyDealsState()
              : RefreshIndicator(
                  onRefresh: _loadDeals,
                  color: const Color(0xFF2E7D32),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredDeals.length,
                    itemBuilder: (context, index) {
                      final deal = _filteredDeals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DealCard(
                          deal: deal,
                          showActions: true,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditDealScreen(
                                  business: widget.business,
                                  dealService: widget.dealService,
                                  deal: deal,
                                ),
                              ),
                            ).then((_) => _loadDeals());
                          },
                          onDelete: () => _deleteDeal(deal),
                          onToggleStatus: () => _toggleDealStatus(deal),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyDealsState() {
    final hasSearchQuery = _searchController.text.isNotEmpty;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearchQuery ? Icons.search_off : Icons.local_offer_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              hasSearchQuery ? 'No deals found' : 'No deals yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasSearchQuery
                  ? 'Try adjusting your search terms'
                  : 'Create your first deal for ${widget.business.name}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            if (!hasSearchQuery)
              YindiiButton(
                text: 'Add Deal',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditDealScreen(
                        business: widget.business,
                        dealService: widget.dealService,
                      ),
                    ),
                  ).then((_) => _loadDeals());
                },
                icon: Icons.add,
                width: 200,
              ),
          ],
        ),
      ),
    );
  }
}