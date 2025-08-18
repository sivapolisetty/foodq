import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../providers/business_provider.dart';

class LocationSelector extends ConsumerWidget {
  const LocationSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentForm = ref.watch(businessEnrollmentFormProvider);
    final formNotifier = ref.watch(businessEnrollmentFormProvider.notifier);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.place,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Business Location',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Select your exact business location to help customers find you easily.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Location Status
            if (enrollmentForm.hasSelectedLocation)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Selected',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSuccessContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (enrollmentForm.latitude != null && enrollmentForm.longitude != null)
                            Text(
                              'Lat: ${enrollmentForm.latitude!.toStringAsFixed(6)}, '
                              'Lng: ${enrollmentForm.longitude!.toStringAsFixed(6)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onSuccessContainer.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_off,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please select your business location',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onWarningContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Location Selection Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('select_location_button'),
                    onPressed: () => _showLocationPicker(context, formNotifier),
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use Current Location'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showManualLocationEntry(context, formNotifier),
                    icon: const Icon(Icons.edit_location),
                    label: const Text('Enter Manually'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            if (enrollmentForm.errors['location'] != null) ...[
              const SizedBox(height: 8),
              Text(
                enrollmentForm.errors['location']!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context, BusinessEnrollmentFormNotifier formNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Use Current Location'),
        content: const Text(
          'This will use your device\'s GPS to determine your business location. '
          'Make sure you\'re at your business when selecting this option.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Mock location for demo - in real app, use geolocator
              formNotifier.updateLocation(40.7128, -74.0060);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location selected successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Use Location'),
          ),
        ],
      ),
    );
  }

  void _showManualLocationEntry(BuildContext context, BusinessEnrollmentFormNotifier formNotifier) {
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Location Manually'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the exact latitude and longitude of your business location.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: latController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: '40.7128',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lngController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: '-74.0060',
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
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);
              
              if (lat != null && lng != null) {
                formNotifier.updateLocation(lat, lng);
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Location set successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid coordinates'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Set Location'),
          ),
        ],
      ),
    );
  }
}