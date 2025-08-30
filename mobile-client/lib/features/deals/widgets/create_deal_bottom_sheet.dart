import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/deal_result.dart';
import '../../../shared/models/app_user.dart';
import '../providers/deal_provider.dart';
import '../services/deal_service.dart';
import '../../auth/widgets/production_auth_wrapper.dart';

class CreateDealBottomSheet extends ConsumerStatefulWidget {
  final Deal? deal; // If provided, we're editing; otherwise creating
  final AppUser? currentUser; // Pass current user to avoid provider issues

  const CreateDealBottomSheet({
    super.key,
    this.deal,
    this.currentUser,
  });

  @override
  ConsumerState<CreateDealBottomSheet> createState() => _CreateDealBottomSheetState();
}

class _CreateDealBottomSheetState extends ConsumerState<CreateDealBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _allergenInfoController = TextEditingController();
  
  DateTime? _expiresAt;
  bool _isSubmitting = false;
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // For web compatibility
  String? _selectedImageName;
  String? _currentImageUrl;
  
  // Cache the current user at the widget level
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    
    // Set current user from widget parameter
    _currentUser = widget.currentUser;
    
    // Pre-populate fields if editing
    if (widget.deal != null) {
      final deal = widget.deal!;
      _titleController.text = deal.title;
      _descriptionController.text = deal.description ?? '';
      _originalPriceController.text = deal.originalPrice.toString();
      _discountedPriceController.text = deal.discountedPrice.toString();
      _quantityController.text = deal.quantityAvailable.toString();
      _allergenInfoController.text = deal.allergenInfo ?? '';
      _expiresAt = deal.expiresAt;
      _currentImageUrl = deal.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _quantityController.dispose();
    _allergenInfoController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    // Show image source selection dialog
    final ImageSource? source = await _showImageSourceDialog();
    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // For web, read the file as bytes
        final bytes = await pickedFile.readAsBytes();
        print('🌐 Web image selected:');
        print('   Source: ${source == ImageSource.camera ? "Camera" : "Gallery"}');
        print('   Name: ${pickedFile.name}');
        print('   Size: ${bytes.length} bytes');
        print('   Extension: ${pickedFile.name.split('.').last}');
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
          _selectedImage = null; // Clear file reference for web
        });
      } else {
        // For mobile, use file
        print('📱 Mobile image selected:');
        print('   Source: ${source == ImageSource.camera ? "Camera" : "Gallery"}');
        print('   Path: ${pickedFile.path}');
        print('   Name: ${pickedFile.name}');
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedImageBytes = null; // Clear bytes for mobile
          _selectedImageName = pickedFile.name;
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera to take a new photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select from existing photos'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.deal != null;
    
    // If no user was passed, try to get it from the provider as fallback
    if (_currentUser == null) {
      final currentUserAsync = ref.watch(authenticatedUserProvider);
      currentUserAsync.whenData((user) {
        if (user != null && mounted) {
          setState(() {
            _currentUser = user;
          });
        }
      });
    }
    
    return OverflowSafeWrapper(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Deal' : 'Create New Deal',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildImageSection(),
                      const SizedBox(height: 24),
                      _buildPricingSection(),
                      const SizedBox(height: 24),
                      _buildQuantityAndTimeSection(),
                      const SizedBox(height: 24),
                      _buildAdditionalInfoSection(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.info_outline,
          title: 'Basic Information',
        ),
        const SizedBox(height: 16),
        
        // Title field
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Deal Title *',
            hintText: 'e.g., Fresh Pizza Slices',
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            if (value.trim().length < 3) {
              return 'Title must be at least 3 characters';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Description field
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Describe your food item, ingredients, or special offers...',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.image,
          title: 'Deal Image',
        ),
        const SizedBox(height: 16),
        
        GestureDetector(
          onTap: _selectImage,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outline.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: _hasSelectedImage()
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildSelectedImage(),
                      ),
                      // Show "NEW" badge when a new image is selected in edit mode
                      if (widget.deal != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'NEW',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _currentImageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
          ),
        ),
      ],
    );
  }

  bool _hasSelectedImage() {
    return (kIsWeb && _selectedImageBytes != null) || (!kIsWeb && _selectedImage != null);
  }

  Widget _buildSelectedImage() {
    if (kIsWeb && _selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && _selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to add image',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Take a photo or choose from gallery',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.attach_money,
          title: 'Pricing',
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _originalPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Original Price *',
                  hintText: '0.00',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Original price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Enter valid price > 0';
                  }
                  return null;
                },
                onChanged: _calculateDiscount,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _discountedPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Sale Price *',
                  hintText: '0.00',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sale price is required';
                  }
                  final discountedPrice = double.tryParse(value);
                  if (discountedPrice == null || discountedPrice <= 0) {
                    return 'Enter valid price > 0';
                  }
                  
                  final originalPrice = double.tryParse(_originalPriceController.text);
                  if (originalPrice != null && discountedPrice >= originalPrice) {
                    return 'Must be less than original';
                  }
                  return null;
                },
                onChanged: _calculateDiscount,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Discount display
        _buildDiscountDisplay(),
      ],
    );
  }

  Widget _buildQuantityAndTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.schedule,
          title: 'Quantity & Timing',
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Quantity Available *',
                  hintText: '0',
                  suffixText: 'items',
                  prefixIcon: const Icon(Icons.inventory),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Enter valid quantity > 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _selectExpirationTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _expiresAt != null
                              ? _formatDateTime(_expiresAt!)
                              : 'Select expiry time *',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _expiresAt != null
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.warning_amber,
          title: 'Additional Information',
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _allergenInfoController,
          decoration: InputDecoration(
            labelText: 'Allergen Information (Optional)',
            hintText: 'e.g., Contains nuts, dairy, gluten...',
            prefixIcon: const Icon(Icons.health_and_safety),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
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
                Icons.lightbulb_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tip: Add clear descriptions and allergen info to help customers make informed decisions.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onInfoContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountDisplay() {
    final originalPrice = double.tryParse(_originalPriceController.text);
    final discountedPrice = double.tryParse(_discountedPriceController.text);
    
    if (originalPrice != null && discountedPrice != null && originalPrice > discountedPrice) {
      final savings = originalPrice - discountedPrice;
      final percentage = ((savings / originalPrice) * 100).round();
      
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.successContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.savings,
              color: AppColors.success,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Customers save \$${savings.toStringAsFixed(2)} ($percentage% off)',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSuccessContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : () {
          print('🔘 Create Deal button pressed');
          _submitForm();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                widget.deal != null ? 'Update Deal' : 'Create Deal',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _calculateDiscount([String? value]) {
    setState(() {}); // Trigger rebuild to update discount display
  }

  void _selectExpirationTime() async {
    final now = DateTime.now();
    final defaultFutureTime = now.add(const Duration(hours: 4));
    final initialDate = _expiresAt ?? defaultFutureTime;
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );
    
    if (selectedDate != null && mounted) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(defaultFutureTime),
      );
      
      if (selectedTime != null) {
        final proposedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        
        // Ensure the selected time is at least 5 minutes in the future
        final minimumFutureTime = now.add(const Duration(minutes: 5));
        if (proposedDateTime.isAfter(minimumFutureTime)) {
          setState(() {
            _expiresAt = proposedDateTime;
          });
        } else {
          // If selected time is too close to now, show warning
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a time at least 5 minutes in the future'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      return 'Today at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    } else {
      return '${dateTime.month}/${dateTime.day} at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    }
  }

  void _submitForm() async {
    print('🔄 _submitForm called');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }
    
    if (_expiresAt == null) {
      print('❌ No expiration time selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expiration time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if expiration time is at least 5 minutes in the future
    final now = DateTime.now();
    final minimumFutureTime = now.add(const Duration(minutes: 5));
    if (_expiresAt!.isBefore(minimumFutureTime)) {
      print('❌ Expiration time is too close to current time');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiration time must be at least 5 minutes in the future'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Use the cached current user
    final currentUser = _currentUser;
    
    print('👤 Current user: ${currentUser?.name}, isBusiness: ${currentUser?.isBusiness}, businessId: ${currentUser?.businessId}');
    
    if (currentUser == null || !currentUser.isBusiness || currentUser.businessId == null) {
      print('❌ Invalid user for deal creation');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in as a business user to create deals'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      bool success;
      if (widget.deal != null) {
        print('✏️ Updating existing deal');
        
        // Handle image upload for existing deal if new image selected
        String? imageUrl = _currentImageUrl;
        if (_hasSelectedImage()) {
          final dealService = DealService();
          if (!kIsWeb && _selectedImage != null) {
            // Mobile: Upload using file path
            print('📱 Uploading image for existing deal (mobile)');
            imageUrl = await dealService.uploadDealImage(
              widget.deal!.id,
              _selectedImage!.path,
            );
          } else if (kIsWeb && _selectedImageBytes != null && _selectedImageName != null) {
            // Web: Upload using image bytes
            print('🌐 Uploading image for existing deal (web)');
            print('   Deal ID: ${widget.deal!.id}');
            print('   Image name: $_selectedImageName');
            print('   Image bytes size: ${_selectedImageBytes!.length}');
            imageUrl = await dealService.uploadDealImageBytes(
              widget.deal!.id,
              _selectedImageBytes!,
              _selectedImageName!,
            );
          }
          
          if (imageUrl != null) {
            print('✅ Image uploaded successfully: $imageUrl');
          } else {
            print('❌ Failed to upload image');
          }
        }
        
        final dealData = {
          'business_id': currentUser.businessId,
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          'original_price': double.parse(_originalPriceController.text),
          'discounted_price': double.parse(_discountedPriceController.text),
          'quantity_available': int.parse(_quantityController.text),
          'expires_at': _expiresAt!.toIso8601String(),
          'allergen_info': _allergenInfoController.text.trim().isEmpty 
              ? null 
              : _allergenInfoController.text.trim(),
          if (imageUrl != null) 'image_url': imageUrl,
        };
        
        // Update existing deal
        success = await ref.read(dealListProvider.notifier).updateDeal(
          widget.deal!.id,
          dealData,
        );
      } else {
        print('➕ Creating new deal');
        
        // Create new deal - use consistent approach for all cases
        final dealData = {
          'business_id': currentUser.businessId,
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          'original_price': double.parse(_originalPriceController.text),
          'discounted_price': double.parse(_discountedPriceController.text),
          'quantity_available': int.parse(_quantityController.text),
          'expires_at': _expiresAt!.toIso8601String(),
          'allergen_info': _allergenInfoController.text.trim().isEmpty 
              ? null 
              : _allergenInfoController.text.trim(),
        };

        if (_hasSelectedImage()) {
          // Handle image upload through the deal service directly
          final dealService = DealService();
          DealResult dealResult;
          
          print('📱 Creating deal with image...');
          print('   Platform: ${kIsWeb ? "Web" : "Mobile"}');
          print('   Business ID: ${currentUser.businessId}');
          print('   Title: ${_titleController.text.trim()}');
          print('   Original Price: ${_originalPriceController.text}');
          print('   Discounted Price: ${_discountedPriceController.text}');
          
          if (!kIsWeb && _selectedImage != null) {
            // Mobile: Create deal with image using file path
            print('📱 Mobile: Calling createDealWithImage');
            dealResult = await dealService.createDealWithImage(
              businessId: currentUser.businessId!,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty 
                  ? 'No description provided'
                  : _descriptionController.text.trim(),
              originalPrice: double.parse(_originalPriceController.text),
              discountedPrice: double.parse(_discountedPriceController.text),
              quantityAvailable: int.parse(_quantityController.text),
              expiresAt: _expiresAt!,
              imagePath: _selectedImage!.path,
              allergenInfo: _allergenInfoController.text.trim().isEmpty 
                  ? null 
                  : _allergenInfoController.text.trim(),
            );
            print('📱 Mobile: createDealWithImage completed');
          } else {
            // Web: Create deal with image using bytes
            print('🌐 Web: Creating deal with image using bytes');
            print('   Image name: $_selectedImageName');
            print('   Image bytes size: ${_selectedImageBytes?.length ?? 0}');
            dealResult = await dealService.createDealWithImageBytes(
              businessId: currentUser.businessId!,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty 
                  ? 'No description provided'
                  : _descriptionController.text.trim(),
              originalPrice: double.parse(_originalPriceController.text),
              discountedPrice: double.parse(_discountedPriceController.text),
              quantityAvailable: int.parse(_quantityController.text),
              expiresAt: _expiresAt!,
              imageBytes: _selectedImageBytes,
              imageName: _selectedImageName,
              allergenInfo: _allergenInfoController.text.trim().isEmpty 
                  ? null 
                  : _allergenInfoController.text.trim(),
            );
            print('🌐 Web: createDealWithImageBytes completed');
          }

          print('🔍 DETAILED RESULT DEBUG:');
          print('   dealResult type: ${dealResult.runtimeType}');
          print('   dealResult.isSuccess: ${dealResult.isSuccess}');
          print('   dealResult.error: ${dealResult.error}');
          print('   dealResult.deal != null: ${dealResult.deal != null}');
          if (dealResult.deal != null) {
            print('   dealResult.deal.id: ${dealResult.deal!.id}');
            print('   dealResult.deal.title: ${dealResult.deal!.title}');
          }

          if (dealResult.isSuccess && dealResult.deal != null) {
            print('✅ SUCCESS BRANCH: About to add deal to provider state');
            // Add the new deal to provider state using the proper method
            ref.read(dealListProvider.notifier).addDealToState(dealResult.deal!);
            success = true;
            print('✅ Deal with image created and added to provider state');
          } else {
            print('❌ FAILURE BRANCH: dealResult indicates failure');
            print('   isSuccess: ${dealResult.isSuccess}');
            print('   error: ${dealResult.error}');
            success = false;
            throw Exception(dealResult.error ?? 'Unknown error');
          }
        } else {
          // Create deal without image using provider method
          success = await ref.read(dealListProvider.notifier).createDeal(dealData);
        }
      }

      print('📋 Deal data prepared and processed');
      print('✅ Deal operation result: $success');

      print('✅ Deal operation result: $success');

      if (mounted) {
        if (success) {
          print('🎉 Deal operation successful - closing modal');
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.deal != null ? 'Deal updated successfully!' : 'Deal created successfully!',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Simply close the modal - no navigation needed since we're already on the deals page
          Navigator.of(context).pop();
          
        } else {
          print('❌ Deal operation failed');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.deal != null ? 'Failed to update deal' : 'Failed to create deal',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      print('💥 Exception during deal submission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}