import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../shared/models/order.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// Order verification card showing QR code and 6-digit code for simplified order flow
class OrderVerificationCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onRefresh;

  const OrderVerificationCard({
    super.key,
    required this.order,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (!order.isReadyForVerification) {
      return _buildNotReadyCard();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildQRCode(),
          const SizedBox(height: 20),
          _buildVerificationCode(),
          const SizedBox(height: 20),
          _buildOrderSummary(),
        ],
      ),
    );
  }

  Widget _buildNotReadyCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.hourglass_empty, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 12),
          Text(
            'Order Not Ready',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verification code will appear when order is confirmed',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                'CONFIRMED',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          order.timeSinceConfirmedFormatted,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildQRCode() {
    // Generate QR code data
    final qrData = order.qrData ?? _generateFallbackQRData();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              errorStateBuilder: (context, error) {
                return Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'QR Code Error',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            'PICKUP CODE',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _copyCodeToClipboard(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.formattedVerificationCode,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.copy, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              order.verificationInstructions,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.blue[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.substring(0, 8).toUpperCase()}',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                order.formattedTotal,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.businessName,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
          ),
          if (order.pickupTime != null) ...[
            const SizedBox(height: 4),
            Text(
              'Pickup: ${order.formattedPickupTime}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  String _generateFallbackQRData() {
    // Generate QR data if not available from database
    final qrDataMap = {
      'order_id': order.id,
      'verification_code': order.verificationCode,
      'business_id': order.businessId,
      'total_amount': order.totalAmount,
      'created_at': order.createdAt?.toIso8601String(),
    };
    return qrDataMap.toString(); // Simple fallback - in production use proper JSON
  }

  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: order.formattedVerificationCode));
    // Could show a snackbar here to confirm copy
  }
}