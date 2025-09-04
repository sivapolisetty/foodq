import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/business.dart';
import '../../../services/business_service.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../search/services/search_service.dart';
import '../../location/providers/location_provider.dart';
import '../../home/widgets/enhanced_deal_card.dart';

class BusinessDetailsScreen extends ConsumerStatefulWidget {
  final String businessId;
  
  const BusinessDetailsScreen({
    Key? key,
    required this.businessId,
  }) : super(key: key);

  @override
  ConsumerState<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  Business? _business;
  List<DealWithDistance> _deals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBusinessDetails();
  }

  Future<void> _loadBusinessDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final businessService = BusinessService();
      final searchService = SearchService();
      final locationState = ref.read(locationProvider);
      
      print('🏢 Loading business details for ID: ${widget.businessId}');
      
      // Load real business data from API
      final businessData = await businessService.getBusinessById(widget.businessId);
      
      if (businessData == null) {
        setState(() {
          _error = 'Business not found';
          _isLoading = false;
        });
        return;
      }
      
      print('🏢 Loaded business: ${businessData.name}');
      _business = businessData;

      // Load deals for this business
      if (locationState.position != null) {
        final lat = locationState.position!.latitude;
        final lng = locationState.position!.longitude;
        print('🏢 Loading deals for business: ${widget.businessId}');
        
        final dealsData = await searchService.getNearbyDealsWithDistance(
          userLatitude: lat,
          userLongitude: lng,
          radiusMiles: 50.0,
          limit: 20,
          businessId: widget.businessId,
        );
        _deals = dealsData;
        print('🏢 Loaded ${_deals.length} deals for business');
      }

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      print('💥 Error loading business details: $e');
      setState(() {
        _error = 'Failed to load business details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53935),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBusinessDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_business == null) {
      return const Center(
        child: Text('Business not found'),
      );
    }

    return CustomScrollView(
      slivers: [
        // App bar with cover image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: const Color(0xFF4CAF50),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => NavigationHelper.safePopOrGoHome(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Cover image
                if (_business!.coverImageUrl?.isNotEmpty == true)
                  Image.network(
                    _business!.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF4CAF50),
                      child: const Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Container(
                    color: const Color(0xFF4CAF50),
                    child: const Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Business information
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business header
                Row(
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _business!.logoUrl?.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _business!.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.restaurant,
                                  size: 40,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Color(0xFF4CAF50),
                            ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Business name and rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _business!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_business!.category?.isNotEmpty == true)
                            Text(
                              _business!.category!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF757575),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 20,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _business!.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${_business!.reviewCount} reviews)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Description
                if (_business!.description?.isNotEmpty == true) ...[
                  Text(
                    _business!.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF424242),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Contact information
                _buildContactInfo(),
                
                const SizedBox(height: 32),
                
                // Deals section
                Text(
                  'Available Deals (${_deals.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Deals list
        if (_deals.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 2.3,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return SizedBox(
                    width: 280,
                    child: EnhancedDealCard(
                      dealWithDistance: _deals[index],
                      onTap: () => context.go('/deal-details?id=${_deals[index].deal.id}'),
                    ),
                  );
                },
                childCount: _deals.length,
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No deals available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new deals!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          
          // Address
          if (_business!.address?.isNotEmpty == true)
            _buildContactItem(
              Icons.location_on,
              _business!.address!,
            ),
          
          // Phone
          if (_business!.phone?.isNotEmpty == true)
            _buildContactItem(
              Icons.phone,
              _business!.phone!,
            ),
          
          // Email
          if (_business!.email?.isNotEmpty == true)
            _buildContactItem(
              Icons.email,
              _business!.email!,
            ),
          
          // Website
          if (_business!.website?.isNotEmpty == true)
            _buildContactItem(
              Icons.web,
              _business!.website!,
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }
}