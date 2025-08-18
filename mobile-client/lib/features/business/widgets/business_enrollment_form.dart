import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../providers/business_provider.dart';

class BusinessEnrollmentForm extends ConsumerWidget {
  const BusinessEnrollmentForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentForm = ref.watch(businessEnrollmentFormProvider);
    final formNotifier = ref.watch(businessEnrollmentFormProvider.notifier);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Information',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Business Name Field
            TextFormField(
              key: const Key('business_name_field'),
              onChanged: formNotifier.updateName,
              decoration: InputDecoration(
                labelText: 'Business Name *',
                hintText: 'e.g., Mario\'s Pizzeria',
                prefixIcon: const Icon(Icons.business),
                errorText: enrollmentForm.errors['name'],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Business Description Field
            TextFormField(
              key: const Key('business_description_field'),
              onChanged: formNotifier.updateDescription,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Tell customers about your business, cuisine type, specialties...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description),
                ),
                errorText: enrollmentForm.errors['description'],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Address Field
            TextFormField(
              key: const Key('business_address_field'),
              onChanged: formNotifier.updateAddress,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Business Address *',
                hintText: '123 Main St, City, State, ZIP',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Icon(Icons.location_on),
                ),
                errorText: enrollmentForm.errors['address'],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Phone Field
            TextFormField(
              key: const Key('business_phone_field'),
              onChanged: formNotifier.updatePhone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 (555) 123-4567',
                prefixIcon: const Icon(Icons.phone),
                errorText: enrollmentForm.errors['phone'],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Email Field
            TextFormField(
              key: const Key('business_email_field'),
              onChanged: formNotifier.updateEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Business Email',
                hintText: 'contact@business.com',
                prefixIcon: const Icon(Icons.email),
                errorText: enrollmentForm.errors['email'],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Required Fields Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fields marked with * are required',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onInfoContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}