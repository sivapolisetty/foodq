import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Service for handling image picking operations
/// Supports camera, gallery, and image management for business assets
class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Show image picker options dialog
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Select Image',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Camera option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text('Capture with camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _pickImageFromCamera();
                  Navigator.pop(context, file);
                },
              ),
              
              // Gallery option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF2196F3),
                  ),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select from photos'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _pickImageFromGallery();
                  Navigator.pop(context, file);
                },
              ),
              
              const SizedBox(height: 20),
              
              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Pick image from camera
  static Future<File?> _pickImageFromCamera() async {
    try {
      print('📷 Opening camera for image capture');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        print('✅ Image captured: ${image.path}');
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      print('💥 Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery
  static Future<File?> _pickImageFromGallery() async {
    try {
      print('🖼️ Opening gallery for image selection');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        print('✅ Image selected: ${image.path}');
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      print('💥 Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image directly from camera (without dialog)
  static Future<File?> pickImageFromCamera() async {
    return await _pickImageFromCamera();
  }

  /// Pick image directly from gallery (without dialog)
  static Future<File?> pickImageFromGallery() async {
    return await _pickImageFromGallery();
  }

  /// Get image size in bytes
  static Future<int> getImageSize(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return bytes.length;
    } catch (e) {
      print('💥 Error getting image size: $e');
      return 0;
    }
  }

  /// Check if image is valid and within size limits
  static Future<bool> isImageValid(File imageFile, {int maxSizeInMB = 5}) async {
    try {
      final size = await getImageSize(imageFile);
      final sizeInMB = size / (1024 * 1024);
      
      print('📊 Image size: ${sizeInMB.toStringAsFixed(2)} MB');
      
      if (sizeInMB > maxSizeInMB) {
        print('❌ Image too large: ${sizeInMB.toStringAsFixed(2)} MB (max: ${maxSizeInMB} MB)');
        return false;
      }
      
      return true;
    } catch (e) {
      print('💥 Error validating image: $e');
      return false;
    }
  }

  /// Show image size error dialog
  static void showImageSizeError(BuildContext context, {int maxSizeInMB = 5}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Image Too Large'),
            ],
          ),
          content: Text(
            'The selected image is too large. Please choose an image smaller than ${maxSizeInMB} MB.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

/// Widget for displaying image picker button with preview
class ImagePickerButton extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;
  final String label;
  final IconData icon;
  final Function(File) onImageSelected;
  final double? width;
  final double? height;

  const ImagePickerButton({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.label,
    required this.icon,
    required this.onImageSelected,
    this.width,
    this.height,
  });

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleImagePick,
      child: Container(
        width: widget.width ?? 120,
        height: widget.height ?? 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show selected image file
    if (widget.imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              widget.imageFile!,
              fit: BoxFit.cover,
            ),
            // Overlay with edit icon
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show network image
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            ),
            // Overlay with edit icon
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.icon,
          size: 32,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleImagePick() async {
    setState(() => _isLoading = true);

    try {
      final imageFile = await ImagePickerService.showImagePickerDialog(context);
      
      if (imageFile != null) {
        // Validate image size
        final isValid = await ImagePickerService.isImageValid(imageFile);
        
        if (isValid) {
          widget.onImageSelected(imageFile);
        } else {
          if (mounted) {
            ImagePickerService.showImageSizeError(context);
          }
        }
      }
    } catch (e) {
      print('💥 Error handling image pick: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error selecting image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}