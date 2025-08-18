import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/order.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../providers/order_provider.dart';
import '../widgets/enhanced_order_card.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    
    return currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null) {
          return _buildNoUserSelected();
        }
        
        return _buildOrdersContent(currentUser);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildNoUserSelected() {
    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Select a user profile first',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/profile'),
                child: const Text('Go to Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersContent(AppUser currentUser) {
    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentUser.isBusiness ? 'Business Orders' : 'My Orders'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'All'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOrdersList(currentUser, OrderFilter.active),
            _buildOrdersList(currentUser, OrderFilter.completed),
            _buildOrdersList(currentUser, OrderFilter.all),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(currentUser),
      ),
    );
  }

  Widget _buildOrdersList(AppUser currentUser, OrderFilter filter) {
    return Consumer(
      builder: (context, ref, child) {
        final ordersAsync = currentUser.isBusiness
            ? ref.watch(businessOrdersProvider(currentUser.businessId!))
            : ref.watch(customerOrdersProvider(currentUser.id));

        return ordersAsync.when(
          data: (orders) {
            final filteredOrders = _filterOrders(orders, filter);
            
            if (filteredOrders.isEmpty) {
              return _buildEmptyState(filter, currentUser.isBusiness);
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (currentUser.isBusiness) {
                  await ref.refresh(businessOrdersProvider(currentUser.businessId!).future);
                } else {
                  await ref.refresh(customerOrdersProvider(currentUser.id).future);
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return EnhancedOrderCard(
                    order: order,
                    isBusinessView: currentUser.isBusiness,
                    onTap: () => _onOrderTap(order),
                  );
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) {
            // Enhanced error handling with debug info
            debugPrint('🚨 Orders Screen Error: $error');
            debugPrint('🚨 Stack Trace: $stackTrace');
            
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (currentUser.isBusiness) {
                              ref.invalidate(businessOrdersProvider(currentUser.businessId!));
                            } else {
                              ref.invalidate(customerOrdersProvider(currentUser.id));
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            debugPrint('🔧 User ID: ${currentUser.id}');
                            debugPrint('🔧 Is Business: ${currentUser.isBusiness}');
                            debugPrint('🔧 Business ID: ${currentUser.businessId}');
                          },
                          icon: const Icon(Icons.bug_report),
                          label: const Text('Debug Info'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'If this issue persists, try switching users and back, or restart the app.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(OrderFilter filter, bool isBusinessView) {
    String message;
    IconData icon;
    
    switch (filter) {
      case OrderFilter.active:
        message = isBusinessView 
          ? 'No active orders from customers'
          : 'No active orders yet';
        icon = Icons.pending_actions;
        break;
      case OrderFilter.completed:
        message = isBusinessView 
          ? 'No completed orders yet'
          : 'No completed orders yet';
        icon = Icons.check_circle_outline;
        break;
      case OrderFilter.all:
        message = isBusinessView 
          ? 'No orders received yet'
          : 'No orders placed yet';
        icon = Icons.receipt_long;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (!isBusinessView) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Browse Deals'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Order> _filterOrders(List<Order> orders, OrderFilter filter) {
    switch (filter) {
      case OrderFilter.active:
        return orders.where((order) => order.isActive).toList();
      case OrderFilter.completed:
        return orders.where((order) => 
          order.status == OrderStatus.delivered || 
          order.status == OrderStatus.cancelled
        ).toList();
      case OrderFilter.all:
        return orders;
    }
  }

  void _onOrderTap(Order order) {
    if (!mounted || !context.mounted) return;
    
    try {
      context.pushNamed('orderDetails', extra: order);
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
    }
  }

  Widget _buildBottomNavigation(AppUser currentUser) {
    return CustomBottomNav(
      currentIndex: 3, // Orders tab
      currentUser: currentUser,
      onTap: (index) => _handleBottomNavTap(context, index, currentUser),
    );
  }

  void _handleBottomNavTap(BuildContext context, int index, AppUser currentUser) {
    if (!mounted || !context.mounted) return;
    
    // Prevent navigation if already on the target screen
    if (index == 3) return; // Already on orders screen
    
    try {
      switch (index) {
        case 0:
          if (currentUser.isBusiness) {
            context.go('/business-home');
          } else {
            context.go('/home');
          }
          break;
        case 1:
          context.go('/search');
          break;
        case 2:
          if (currentUser.isBusiness) {
            context.go('/deals');
          } else {
            context.go('/favorites');
          }
          break;
        case 4:
          context.go('/profile');
          break;
      }
    } catch (e) {
      debugPrint('❌ Bottom nav navigation error: $e');
    }
  }
}

enum OrderFilter { active, completed, all }