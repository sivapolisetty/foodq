import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CustomerInfoWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController instructionsController;

  const CustomerInfoWidget({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.instructionsController,
  });

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
                Icons.person,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Name Field
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 16),
          
          // Phone Field
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              hintText: '(555) 123-4567',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              // Basic phone validation
              final phoneRegex = RegExp(r'^\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}$');
              if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Special Instructions Field
          TextFormField(
            controller: instructionsController,
            decoration: InputDecoration(
              labelText: 'Special Instructions (Optional)',
              hintText: 'Any special requests or dietary needs?',
              prefixIcon: const Icon(Icons.note_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
              ),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          
          const SizedBox(height: 16),
          
          // Information Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'We\'ll use this information to contact you about your order and pickup.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
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
}