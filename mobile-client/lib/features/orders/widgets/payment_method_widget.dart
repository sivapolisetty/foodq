import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum PaymentMethod {
  card,
  applePay,
  googlePay,
  cash,
}

class PaymentMethodWidget extends StatefulWidget {
  const PaymentMethodWidget({super.key});

  @override
  State<PaymentMethodWidget> createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends State<PaymentMethodWidget> {
  PaymentMethod _selectedMethod = PaymentMethod.card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.payment,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Payment Options
          _buildPaymentOption(
            method: PaymentMethod.card,
            icon: Icons.credit_card,
            title: 'Credit/Debit Card',
            subtitle: 'Visa, Mastercard, American Express',
            isRecommended: true,
          ),
          
          const SizedBox(height: 12),
          
          _buildPaymentOption(
            method: PaymentMethod.applePay,
            icon: Icons.apple,
            title: 'Apple Pay',
            subtitle: 'Touch ID or Face ID',
            isEnabled: false, // Disabled for demo
          ),
          
          const SizedBox(height: 12),
          
          _buildPaymentOption(
            method: PaymentMethod.googlePay,
            icon: Icons.g_mobiledata,
            title: 'Google Pay',
            subtitle: 'Quick and secure',
            isEnabled: false, // Disabled for demo
          ),
          
          const SizedBox(height: 12),
          
          _buildPaymentOption(
            method: PaymentMethod.cash,
            icon: Icons.money,
            title: 'Cash on Pickup',
            subtitle: 'Pay when you collect your order',
            isEnabled: false, // Disabled for demo
          ),
          
          // Selected Payment Method Details
          if (_selectedMethod == PaymentMethod.card) ...[
            const SizedBox(height: 20),
            _buildCardDetailsSection(),
          ],
          
          const SizedBox(height: 16),
          
          // Security Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  size: 20,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your payment information is encrypted and secure',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isRecommended = false,
    bool isEnabled = true,
  }) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: isEnabled ? () => setState(() => _selectedMethod = method) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryGreen 
                : (isEnabled ? Colors.grey[300]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isEnabled 
              ? (isSelected ? AppTheme.primaryGreen.withOpacity(0.05) : Colors.white)
              : Colors.grey[100],
        ),
        child: Row(
          children: [
            // Radio Button
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedMethod,
              onChanged: isEnabled ? (value) => setState(() => _selectedMethod = value!) : null,
              activeColor: AppTheme.primaryGreen,
            ),
            
            const SizedBox(width: 12),
            
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEnabled 
                    ? AppTheme.primaryGreen.withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isEnabled ? AppTheme.primaryGreen : Colors.grey[400],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isEnabled ? Colors.black87 : Colors.grey[500],
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Recommended',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                  if (!isEnabled) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetailsSection() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        
        // Demo Card Information
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DEMO CARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                '•••• •••• •••• 4242',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARD HOLDER',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'DEMO USER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPIRES',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '12/28',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'This is a demo card for testing purposes. In production, you would enter your actual card details.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}