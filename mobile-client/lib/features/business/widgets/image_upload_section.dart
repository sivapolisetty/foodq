import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../providers/business_provider.dart';

class ImageUploadSection extends ConsumerWidget {
  const ImageUploadSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessStateProvider);

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
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Business Images',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Optional',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Add a logo and cover image to make your business more appealing to customers.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Logo Upload
            _ImageUploadCard(
              key: const Key('logo_upload_button'),
              title: 'Business Logo',
              description: 'Square image, recommended 512x512px',
              icon: Icons.account_circle,
              imageUrl: businessState.business?.logoUrl,
              onTap: () => _handleLogoUpload(ref),
              isUploading: businessState.isUploading,
            ),
            
            const SizedBox(height: 16),
            
            // Cover Image Upload
            _ImageUploadCard(
              key: const Key('cover_image_upload_button'),
              title: 'Cover Image',
              description: 'Wide image, recommended 1200x400px',
              icon: Icons.panorama,
              imageUrl: businessState.business?.coverImageUrl,
              onTap: () => _handleCoverImageUpload(ref),
              isUploading: businessState.isUploading,
            ),
            
            const SizedBox(height: 16),
            
            // Upload Guidelines
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Image Guidelines',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onInfoContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Use high-quality, professional images\n'
                    '• Maximum file size: 5MB\n'
                    '• Supported formats: JPG, PNG\n'
                    '• Images will be automatically optimized',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onInfoContainer,
                      height: 1.4,
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

  void _handleLogoUpload(WidgetRef ref) {
    // Mock image upload - in real app, use image_picker
    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Logo'),
        content: const Text(
          'In a real app, this would open the image picker to select a logo image.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              // Mock upload
              const businessId = '550e8400-e29b-41d4-a716-446655440001';
              const mockImageData = 'mock-image-data';
              
              ref.read(businessStateProvider.notifier).uploadLogo(businessId, mockImageData);
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _handleCoverImageUpload(WidgetRef ref) {
    // Mock image upload - in real app, use image_picker
    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Cover Image'),
        content: const Text(
          'In a real app, this would open the image picker to select a cover image.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              // Mock upload
              const businessId = '550e8400-e29b-41d4-a716-446655440001';
              const mockImageData = 'mock-cover-image-data';
              
              ref.read(businessStateProvider.notifier).uploadCoverImage(businessId, mockImageData);
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}

class _ImageUploadCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool isUploading;

  const _ImageUploadCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.imageUrl,
    required this.onTap,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: imageUrl != null 
                ? AppColors.success.withOpacity(0.3)
                : AppColors.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(12),
          color: imageUrl != null 
              ? AppColors.successContainer.withOpacity(0.3)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Image Preview or Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: imageUrl != null 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Icon(
                      icon,
                      color: AppColors.onSurfaceVariant,
                      size: 30,
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (imageUrl != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Upload Button/Status
            if (isUploading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                imageUrl != null ? Icons.edit : Icons.add_a_photo,
                color: imageUrl != null ? AppColors.success : AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}