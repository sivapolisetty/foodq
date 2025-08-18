import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/business.dart';
import '../../../shared/models/order.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../../orders/services/order_service.dart';

class OrderPlacementBottomSheet extends ConsumerStatefulWidget {
  final Deal deal;
  final Business? business;
  final Function(Order) onOrderPlaced;

  const OrderPlacementBottomSheet({
    Key? key,
    required this.deal,
    required this.business,
    required this.onOrderPlaced,
  }) : super(key: key);

  @override
  ConsumerState<OrderPlacementBottomSheet> createState() => _OrderPlacementBottomSheetState();
}

class _OrderPlacementBottomSheetState extends ConsumerState<OrderPlacementBottomSheet> {
  int quantity = 1;
  DateTime? selectedPickupTime;
  String specialInstructions = '';
  PaymentMethod selectedPaymentMethod = PaymentMethod.cash;
  bool isLoading = false;
  String? errorMessage;

  final TextEditingController _instructionsController = TextEditingController();
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    // Set default pickup time to 30 minutes from now (in UTC to ensure it's always in the future)
    selectedPickupTime = DateTime.now().toUtc().add(const Duration(minutes: 30));
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDealSummary(),
                  const SizedBox(height: 24),
                  _buildQuantitySelector(),
                  const SizedBox(height: 24),
                  _buildPickupTimeSelector(),
                  const SizedBox(height: 24),
                  _buildPaymentMethodSelector(),
                  const SizedBox(height: 24),
                  _buildSpecialInstructions(),
                  const SizedBox(height: 24),
                  _buildOrderSummary(),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(),
                  ],
                ],
              ),
            ),
          ),
          _buildOrderButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Place Order',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pickup only • ${widget.business?.name ?? 'Restaurant'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDealSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.deal.imageUrl != null && widget.deal.imageUrl!.isNotEmpty
                ? Image.network(
                    widget.deal.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
                  )
                : _buildFallbackImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.deal.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${widget.deal.originalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${widget.deal.discountedPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.restaurant,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuantityButton(
              icon: Icons.remove,
              onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                quantity.toString(),
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildQuantityButton(
              icon: Icons.add,
              onPressed: quantity < widget.deal.quantityAvailable && quantity < 10
                  ? () => setState(() => quantity++)
                  : null,
            ),
            const Spacer(),
            Text(
              '${widget.deal.quantityAvailable} available',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.primary : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildPickupTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Time',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectPickupTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedPickupTime != null
                        ? _formatPickupTime(selectedPickupTime!)
                        : 'Select pickup time',
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: PaymentMethod.values.map((method) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildPaymentMethodOption(method),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(PaymentMethod method) {
    final isSelected = selectedPaymentMethod == method;
    return InkWell(
      onTap: () => setState(() => selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPaymentMethodIcon(method),
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _getPaymentMethodText(method),
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Instructions (Optional)',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _instructionsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any special requests for your order...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: (value) => specialInstructions = value,
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = widget.deal.discountedPrice * quantity;
    final total = subtotal; // No additional fees for pickup orders

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal ($quantity × \$${widget.deal.discountedPrice.toStringAsFixed(2)})',
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton() {
    final total = widget.deal.discountedPrice * quantity;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isLoading ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Place Order • \$${total.toStringAsFixed(2)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _selectPickupTime() async {
    final now = DateTime.now();
    final minTime = now.add(const Duration(minutes: 15)); // Minimum 15 minutes from now
    final maxTime = now.add(const Duration(hours: 12)); // Maximum 12 hours from now

    final date = await showDatePicker(
      context: context,
      initialDate: selectedPickupTime ?? minTime,
      firstDate: minTime,
      lastDate: maxTime,
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedPickupTime ?? minTime),
      );

      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        if (selectedDateTime.isAfter(minTime)) {
          setState(() {
            // Convert to UTC to ensure consistency with server time
            selectedPickupTime = selectedDateTime.toUtc();
          });
        } else {
          _showError('Pickup time must be at least 15 minutes from now');
        }
      }
    }
  }

  Future<void> _placeOrder() async {
    if (selectedPickupTime == null) {
      _showError('Please select a pickup time');
      return;
    }

    final currentUser = ref.read(authenticatedUserProvider).value;
    if (currentUser == null) {
      _showError('User not found. Please login again.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final orderData = {
        'customer_id': currentUser.id,
        'deal_id': widget.deal.id,
        'business_id': widget.deal.businessId,
        'quantity': quantity,
        'unit_price': widget.deal.discountedPrice,
        'total_amount': widget.deal.discountedPrice * quantity,
        'pickup_time': selectedPickupTime!.toUtc().toIso8601String(),
        'pickup_instructions': specialInstructions.isNotEmpty ? specialInstructions : null,
        'payment_method': selectedPaymentMethod.name,
        'special_requests': _instructionsController.text.isNotEmpty ? _instructionsController.text : null,
      };

      debugPrint('🛒 PLACING ORDER: $orderData');
      final order = await _orderService.createOrder(orderData);
      debugPrint('✅ ORDER SUCCESS: ID=${order.id}');
      
      if (mounted) {
        debugPrint('📞 CALLING CALLBACK: order=${order.id}');
        
        // Dismiss the modal immediately before calling navigation callback
        Navigator.of(context).pop();
        
        // Small delay to ensure modal is fully dismissed before navigation
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            debugPrint('🚀 TRIGGERING NAVIGATION CALLBACK');
            widget.onOrderPlaced(order);
          }
        });
      }
      
    } catch (e) {
      debugPrint('❌ ORDER PLACEMENT ERROR: $e');
      debugPrint('❌ ERROR TYPE: ${e.runtimeType}');
      
      String errorMessage = 'Failed to place order';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = 'Failed to place order: ${e.toString()}';
      }
      
      _showError(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  String _formatPickupTime(DateTime dateTime) {
    // Convert UTC time to local time for display
    final localDateTime = dateTime.toLocal();
    final now = DateTime.now();
    final isToday = localDateTime.day == now.day && 
                   localDateTime.month == now.month && 
                   localDateTime.year == now.year;
    final isTomorrow = localDateTime.day == now.add(const Duration(days: 1)).day && 
                      localDateTime.month == now.add(const Duration(days: 1)).month && 
                      localDateTime.year == now.add(const Duration(days: 1)).year;

    String dateStr;
    if (isToday) {
      dateStr = 'Today';
    } else if (isTomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${localDateTime.month}/${localDateTime.day}';
    }

    final timeStr = TimeOfDay.fromDateTime(localDateTime).format(context);
    return '$dateStr at $timeStr';
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.digital:
        return Icons.phone_android;
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.digital:
        return 'Digital';
    }
  }
}