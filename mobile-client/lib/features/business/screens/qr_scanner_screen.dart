import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/models/app_user.dart';
import '../../orders/services/order_service.dart';
import '../../orders/providers/order_provider.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../../home/widgets/custom_bottom_nav.dart';

/// QR Scanner screen for restaurants to verify and complete orders
class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  String? _lastScannedCode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('📷 QRScannerScreen: Building full scanner interface...');
    
    return OverflowSafeWrapper(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Scan Order QR Code'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => _controller.toggleTorch(),
              icon: ValueListenableBuilder(
                valueListenable: _controller.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () => _controller.switchCamera(),
              icon: ValueListenableBuilder(
                valueListenable: _controller.cameraFacingState,
                builder: (context, state, child) {
                  switch (state) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Camera view
            MobileScanner(
              controller: _controller,
              onDetect: _onQRCodeDetected,
            ),
            // Scanning overlay
            _buildScanningOverlay(),
            // Processing indicator
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
        bottomNavigationBar: _buildScannerBottomBar(),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner indicators
            Positioned(
              top: -1,
              left: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.primary, width: 4),
                    left: BorderSide(color: AppColors.primary, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.primary, width: 4),
                    right: BorderSide(color: AppColors.primary, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              left: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.primary, width: 4),
                    left: BorderSide(color: AppColors.primary, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              right: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.primary, width: 4),
                    right: BorderSide(color: AppColors.primary, width: 4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Verifying Order...',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _onQRCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isEmpty || _isProcessing) return;
    
    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    
    // Prevent duplicate scans
    if (_lastScannedCode == code) return;
    _lastScannedCode = code;
    
    _processQRCode(code);
  }

  Future<void> _processQRCode(String qrData) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Parse QR code data
      Map<String, dynamic> qrInfo;
      try {
        qrInfo = json.decode(qrData) as Map<String, dynamic>;
      } catch (e) {
        // If JSON parsing fails, treat as verification code
        await _processVerificationCode(qrData.trim().toUpperCase());
        return;
      }

      // Extract order information
      final String? orderId = qrInfo['order_id'];
      final String? verificationCode = qrInfo['verification_code'];

      if (orderId != null || verificationCode != null) {
        await _verifyOrder(
          orderId: orderId,
          verificationCode: verificationCode,
          qrData: qrData,
        );
      } else {
        _showError('Invalid QR code format');
      }
    } catch (e) {
      _showError('Failed to process QR code: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _lastScannedCode = null;
        });
      }
    }
  }

  Future<void> _processVerificationCode(String code) async {
    if (code.length != 6) {
      _showError('Verification code must be 6 characters');
      return;
    }

    await _verifyOrder(verificationCode: code);
  }

  Future<void> _verifyOrder({
    String? orderId,
    String? verificationCode,
    String? qrData,
  }) async {
    try {
      final orderService = OrderService();
      final order = await orderService.verifyOrder(
        orderId: orderId,
        verificationCode: verificationCode,
        qrData: qrData,
      );

      // Show success dialog with order details
      if (mounted) {
        await _showOrderVerificationDialog(order);
      }
    } catch (e) {
      _showError('Verification failed: ${e.toString()}');
    }
  }

  Future<void> _showOrderVerificationDialog(dynamic order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Order Verified'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: #${order.id.substring(0, 8).toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Customer: ${order.dealTitle}'),
            const SizedBox(height: 8),
            Text('Total: ${order.formattedTotal}'),
            const SizedBox(height: 8),
            Text('Business: ${order.businessName}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mark this order as completed?',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete Order'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _completeOrder(order);
    }
  }

  Future<void> _completeOrder(dynamic order) async {
    try {
      final orderNotifier = ref.read(orderNotifierProvider.notifier);
      await orderNotifier.completeOrder(order.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order completed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Go back to business home
        context.go('/business-home');
      }
    } catch (e) {
      _showError('Failed to complete order: $e');
    }
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Verification Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                hintText: 'Enter 6-character code',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Auto-format to uppercase
                final formatted = value.toUpperCase();
                if (formatted != value) {
                  controller.value = controller.value.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-character verification code from the customer',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.trim();
              Navigator.of(context).pop();
              if (code.isNotEmpty) {
                _processQRCode(code);
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }


  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildScannerBottomBar() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scanning instructions
          Container(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Position QR code within the frame',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showManualEntryDialog(),
                          icon: const Icon(Icons.keyboard),
                          label: const Text('Enter Code Manually'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    return currentUserAsync.when(
      data: (currentUser) => CustomBottomNav(
        currentIndex: 2, // Scanner is index 2 in business navigation
        currentUser: currentUser,
        onTap: (index) => _handleBottomNavTap(index),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _handleBottomNavTap(int index) {
    debugPrint('🔘 QRScanner: Bottom nav tap index: $index');
    switch (index) {
      case 0:
        debugPrint('🏠 QRScanner: Navigating to business home');
        context.go('/business-home');
        break;
      case 1:
        debugPrint('🎯 QRScanner: Navigating to deals');
        context.go('/deals');
        break;
      case 2:
        // Already on scanner - stay here
        debugPrint('📷 QRScanner: Staying on scanner');
        break;
      case 3:
        debugPrint('📋 QRScanner: Navigating to orders');
        context.go('/orders');
        break;
      case 4:
        debugPrint('👤 QRScanner: Navigating to profile');
        context.go('/profile');
        break;
    }
  }
}