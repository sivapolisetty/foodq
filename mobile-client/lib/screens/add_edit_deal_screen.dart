import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/business.dart';
import '../models/deal.dart';
import '../services/deal_service.dart';
import '../widgets/yindii_app_bar.dart';
import '../widgets/yindii_button.dart';
import '../widgets/yindii_input_field.dart';

class AddEditDealScreen extends StatefulWidget {
  final Business business;
  final DealService dealService;
  final Deal? deal; // null for add, Deal for edit

  const AddEditDealScreen({
    Key? key,
    required this.business,
    required this.dealService,
    this.deal,
  }) : super(key: key);

  @override
  State<AddEditDealScreen> createState() => _AddEditDealScreenState();
}

class _AddEditDealScreenState extends State<AddEditDealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _termsController = TextEditingController();
  final _maxRedemptionsController = TextEditingController();

  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isLoading = false;
  File? _selectedImage;
  String? _currentImageUrl;
  int _discountPercentage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.deal != null) {
      _populateFields();
    }
    _originalPriceController.addListener(_calculateDiscount);
    _discountedPriceController.addListener(_calculateDiscount);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _termsController.dispose();
    _maxRedemptionsController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final deal = widget.deal!;
    _titleController.text = deal.title;
    _descriptionController.text = deal.description ?? '';
    _originalPriceController.text = deal.originalPrice.toString();
    _discountedPriceController.text = deal.discountedPrice.toString();
    _termsController.text = deal.termsConditions ?? '';
    _maxRedemptionsController.text = deal.maxRedemptions.toString();
    _validFrom = deal.validFrom;
    _validUntil = deal.validUntil;
    _isActive = deal.isActive;
    _currentImageUrl = deal.imageUrl;
    _discountPercentage = deal.discountPercentage;
  }

  void _calculateDiscount() {
    final original = double.tryParse(_originalPriceController.text) ?? 0;
    final discounted = double.tryParse(_discountedPriceController.text) ?? 0;
    
    if (original > 0 && discounted >= 0 && discounted < original) {
      final percentage = ((original - discounted) / original * 100).round();
      setState(() {
        _discountPercentage = percentage;
      });
    } else {
      setState(() {
        _discountPercentage = 0;
      });
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isValidFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isValidFrom ? _validFrom : _validUntil,
      firstDate: isValidFrom ? DateTime.now() : _validFrom,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isValidFrom) {
          _validFrom = picked;
          // Ensure valid until is after valid from
          if (_validUntil.isBefore(_validFrom)) {
            _validUntil = _validFrom.add(const Duration(days: 1));
          }
        } else {
          _validUntil = picked;
        }
      });
    }
  }

  Future<void> _saveDeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _currentImageUrl;

      // Upload image if new one is selected
      if (_selectedImage != null) {
        final tempDealId = widget.deal?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
        imageUrl = await widget.dealService.uploadDealImage(
          tempDealId,
          _selectedImage!.path,
        );
      }

      final deal = Deal(
        id: widget.deal?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        originalPrice: double.parse(_originalPriceController.text),
        discountedPrice: double.parse(_discountedPriceController.text),
        discountPercentage: _discountPercentage,
        businessId: widget.business.id,
        imageUrl: imageUrl,
        isActive: _isActive,
        validFrom: _validFrom,
        validUntil: _validUntil,
        termsConditions: _termsController.text.trim().isEmpty 
            ? null 
            : _termsController.text.trim(),
        maxRedemptions: int.tryParse(_maxRedemptionsController.text) ?? 0,
        currentRedemptions: widget.deal?.currentRedemptions ?? 0,
        createdAt: widget.deal?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.deal == null) {
        await widget.dealService.createDeal(deal);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal created successfully!')),
        );
      } else {
        await widget.dealService.updateDeal(deal);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal updated successfully!')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save deal: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.deal != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: YindiiAppBar(
        title: isEditing ? 'Edit Deal' : 'Add Deal',
        actions: [
          if (isEditing)
            Switch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: const Color(0xFF2E7D32),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Business info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          widget.business.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Deal image
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deal Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _selectImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _currentImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _currentImageUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF2E7D32),
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
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Deal details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deal Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    YindiiInputField(
                      label: 'Deal Title',
                      hint: 'e.g., 50% off on Pizza',
                      controller: _titleController,
                      required: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a deal title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    YindiiInputField(
                      label: 'Description',
                      hint: 'Describe your deal in detail',
                      controller: _descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: YindiiInputField(
                            label: 'Original Price',
                            hint: '0.00',
                            controller: _originalPriceController,
                            keyboardType: TextInputType.number,
                            required: true,
                            prefixIcon: const Icon(Icons.currency_rupee),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'Invalid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: YindiiInputField(
                            label: 'Discounted Price',
                            hint: '0.00',
                            controller: _discountedPriceController,
                            keyboardType: TextInputType.number,
                            required: true,
                            prefixIcon: const Icon(Icons.currency_rupee),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price < 0) {
                                return 'Invalid price';
                              }
                              final original = double.tryParse(_originalPriceController.text) ?? 0;
                              if (price >= original) {
                                return 'Must be less than original';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_discountPercentage > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_offer,
                              color: Color(0xFF2E7D32),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Discount: $_discountPercentage% OFF',
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Validity dates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Validity Period',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Valid From',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_validFrom.day}/${_validFrom.month}/${_validFrom.year}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Valid Until',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_validUntil.day}/${_validUntil.month}/${_validUntil.year}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Additional settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    YindiiInputField(
                      label: 'Max Redemptions',
                      hint: '0 for unlimited',
                      controller: _maxRedemptionsController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final number = int.tryParse(value);
                          if (number == null || number < 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    YindiiInputField(
                      label: 'Terms & Conditions',
                      hint: 'Optional terms and conditions',
                      controller: _termsController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            YindiiButton(
              text: isEditing ? 'Update Deal' : 'Create Deal',
              onPressed: _saveDeal,
              isLoading: _isLoading,
              icon: isEditing ? Icons.save : Icons.add,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to add image',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}