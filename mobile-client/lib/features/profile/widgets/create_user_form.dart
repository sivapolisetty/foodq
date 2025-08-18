import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/enums/user_type.dart';

/// Comprehensive user registration form widget
/// Supports both customer and business users with enhanced fields
class CreateUserForm extends ConsumerStatefulWidget {
  final UserType? initialUserType;
  final Function(Map<String, dynamic>) onSubmit;
  final bool isLoading;

  const CreateUserForm({
    Key? key,
    this.initialUserType,
    required this.onSubmit,
    this.isLoading = false,
  }) : super(key: key);

  @override
  ConsumerState<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends ConsumerState<CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic Information Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Address Controllers
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  // Business Information Controllers
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _businessLicenseController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _deliveryRadiusController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  
  // Form State
  UserType _selectedUserType = UserType.customer;
  bool _autoSwitchToNewUser = true;
  String? _selectedState;
  String? _selectedBusinessCategory;
  Set<String> _selectedDietaryPreferences = {};
  Set<String> _selectedFavoriteCuisines = {};
  Set<String> _selectedPaymentMethods = {};
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  
  // Business Hours
  Map<String, TimeOfDay?> _businessHoursStart = {};
  Map<String, TimeOfDay?> _businessHoursEnd = {};
  
  // Constants
  static const List<String> _states = [
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
    'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho',
    'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
    'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
    'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada',
    'New Hampshire', 'New Jersey', 'New Mexico', 'New York',
    'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon',
    'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
    'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
    'West Virginia', 'Wisconsin', 'Wyoming'
  ];
  
  static const List<String> _businessCategories = [
    'Restaurant', 'Grocery Store', 'Bakery', 'Coffee Shop', 'Fast Food',
    'Food Truck', 'Catering', 'Deli', 'Bar', 'Ice Cream Shop',
    'Specialty Food', 'Farmers Market', 'Other'
  ];
  
  static const List<String> _dietaryPreferences = [
    'Vegetarian', 'Vegan', 'Gluten-Free', 'Keto', 'Paleo', 'Halal',
    'Kosher', 'Dairy-Free', 'Nut-Free', 'Low-Carb', 'Organic', 'Raw Food'
  ];
  
  static const List<String> _cuisineTypes = [
    'American', 'Italian', 'Chinese', 'Mexican', 'Indian', 'Japanese',
    'Thai', 'Mediterranean', 'French', 'Greek', 'Korean', 'Vietnamese',
    'Lebanese', 'Spanish', 'German', 'British', 'Other'
  ];
  
  static const List<String> _paymentMethods = [
    'Cash', 'Credit Cards', 'Debit Cards', 'PayPal', 'Venmo',
    'Apple Pay', 'Google Pay', 'Zelle', 'Cash App'
  ];
  
  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialUserType != null) {
      _selectedUserType = widget.initialUserType!;
    }
    
    // Initialize business hours
    for (String day in _weekdays) {
      _businessHoursStart[day] = const TimeOfDay(hour: 9, minute: 0);
      _businessHoursEnd[day] = const TimeOfDay(hour: 17, minute: 0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _websiteController.dispose();
    _businessLicenseController.dispose();
    _taxIdController.dispose();
    _deliveryRadiusController.dispose();
    _minimumOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.05),
            Colors.white,
            const Color(0xFF4CAF50).withOpacity(0.02),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with polka dot decoration
              _buildHeader(),
              const SizedBox(height: 24),
              
              // User type selection
              _buildUserTypeSelection(),
              const SizedBox(height: 24),
              
              // Basic Information Section
              _buildBasicInformationSection(),
              const SizedBox(height: 20),
              
              // Address Information Section
              _buildAddressSection(),
              const SizedBox(height: 20),
              
              // Dynamic sections based on user type
              if (_selectedUserType == UserType.business) ...[
                _buildBusinessInformationSection(),
                const SizedBox(height: 20),
                _buildBusinessHoursSection(),
                const SizedBox(height: 20),
                _buildBusinessSettingsSection(),
                const SizedBox(height: 20),
              ] else ...[
                _buildCustomerPreferencesSection(),
                const SizedBox(height: 20),
                _buildNotificationPreferencesSection(),
                const SizedBox(height: 20),
              ],
              
              // Options
              _buildOptions(),
              const SizedBox(height: 24),
              
              // Submit button
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Header with decorative elements
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF66BB6A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_add,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Join the GrabEat community today',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // User type selection with enhanced design
  Widget _buildUserTypeSelection() {
    return _buildSection(
      title: 'Account Type',
      icon: Icons.account_circle,
      child: Row(
        children: [
          Expanded(
            child: _buildUserTypeOption(
              userType: UserType.customer,
              title: 'Customer',
              subtitle: 'Browse and order deals',
              icon: Icons.shopping_bag,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildUserTypeOption(
              userType: UserType.business,
              title: 'Business',
              subtitle: 'Create and manage deals',
              icon: Icons.storefront,
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeOption({
    required UserType userType,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedUserType == userType;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = userType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Basic Information Section
  Widget _buildBasicInformationSection() {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.person,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full Name *',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address *',
            hint: 'Enter your email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number *',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.trim().length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Address Section
  Widget _buildAddressSection() {
    return _buildSection(
      title: 'Address Information',
      icon: Icons.location_on,
      child: Column(
        children: [
          _buildTextField(
            controller: _streetController,
            label: 'Street Address *',
            hint: 'Enter your street address',
            icon: Icons.home_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your street address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City *',
                  hint: 'Enter city',
                  icon: Icons.location_city_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value: _selectedState,
                  label: 'State *',
                  hint: 'Select state',
                  icon: Icons.map_outlined,
                  items: _states,
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Select state';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _postalCodeController,
            label: 'Postal Code *',
            hint: 'Enter postal code',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter postal code';
              }
              if (value.trim().length < 5) {
                return 'Please enter a valid postal code';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Business Information Section
  Widget _buildBusinessInformationSection() {
    return _buildSection(
      title: 'Business Information',
      icon: Icons.business,
      child: Column(
        children: [
          _buildTextField(
            controller: _businessNameController,
            label: 'Business Name *',
            hint: 'Enter your business name',
            icon: Icons.storefront_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your business name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            value: _selectedBusinessCategory,
            label: 'Business Category *',
            hint: 'Select category',
            icon: Icons.category_outlined,
            items: _businessCategories,
            onChanged: (value) {
              setState(() {
                _selectedBusinessCategory = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a business category';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _businessDescriptionController,
            label: 'Business Description *',
            hint: 'Describe your business',
            icon: Icons.description_outlined,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe your business';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _websiteController,
            label: 'Website',
            hint: 'Enter website URL (optional)',
            icon: Icons.language_outlined,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _businessLicenseController,
                  label: 'Business License',
                  hint: 'License number',
                  icon: Icons.verified_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _taxIdController,
                  label: 'Tax ID',
                  hint: 'Tax ID number',
                  icon: Icons.receipt_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Business Hours Section
  Widget _buildBusinessHoursSection() {
    return _buildSection(
      title: 'Business Hours',
      icon: Icons.access_time,
      child: Column(
        children: _weekdays.map((day) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTimeButton(
                          time: _businessHoursStart[day],
                          label: 'Open',
                          onTap: () => _selectTime(day, true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('-', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTimeButton(
                          time: _businessHoursEnd[day],
                          label: 'Close',
                          onTap: () => _selectTime(day, false),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Business Settings Section
  Widget _buildBusinessSettingsSection() {
    return _buildSection(
      title: 'Business Settings',
      icon: Icons.settings,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _deliveryRadiusController,
                  label: 'Delivery Radius (miles)',
                  hint: 'e.g., 5',
                  icon: Icons.location_on_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _minimumOrderController,
                  label: 'Minimum Order (\$)',
                  hint: 'e.g., 10.00',
                  icon: Icons.attach_money_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMultiSelectChips(
            title: 'Payment Methods Accepted',
            options: _paymentMethods,
            selectedOptions: _selectedPaymentMethods,
            onChanged: (selected) {
              setState(() {
                _selectedPaymentMethods = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  // Customer Preferences Section
  Widget _buildCustomerPreferencesSection() {
    return _buildSection(
      title: 'Your Preferences',
      icon: Icons.favorite,
      child: Column(
        children: [
          _buildMultiSelectChips(
            title: 'Dietary Preferences',
            options: _dietaryPreferences,
            selectedOptions: _selectedDietaryPreferences,
            onChanged: (selected) {
              setState(() {
                _selectedDietaryPreferences = selected;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildMultiSelectChips(
            title: 'Favorite Cuisines',
            options: _cuisineTypes,
            selectedOptions: _selectedFavoriteCuisines,
            onChanged: (selected) {
              setState(() {
                _selectedFavoriteCuisines = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  // Notification Preferences Section
  Widget _buildNotificationPreferencesSection() {
    return _buildSection(
      title: 'Notification Preferences',
      icon: Icons.notifications,
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Enable Notifications',
            subtitle: 'Receive updates about deals and orders',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          if (_notificationsEnabled) ...[
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: 'SMS Notifications',
              subtitle: 'Receive notifications via SMS',
              value: _smsNotifications,
              onChanged: (value) {
                setState(() {
                  _smsNotifications = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  // Options section
  Widget _buildOptions() {
    return _buildSection(
      title: 'Account Options',
      icon: Icons.settings_outlined,
      child: _buildSwitchTile(
        title: 'Auto-switch to new account',
        subtitle: 'Automatically switch to this account after creation',
        value: _autoSwitchToNewUser,
        onChanged: (value) {
          setState(() {
            _autoSwitchToNewUser = value;
          });
        },
      ),
    );
  }

  // Submit button with enhanced styling
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF66BB6A),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: widget.isLoading ? null : _handleSubmit,
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Create ${_selectedUserType == UserType.customer ? 'Customer' : 'Business'} Account',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Helper method to build sections
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // Enhanced text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  // Dropdown builder
  Widget _buildDropdown({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Multi-select chips builder
  Widget _buildMultiSelectChips({
    required String title,
    required List<String> options,
    required Set<String> selectedOptions,
    required void Function(Set<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF212121),
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newSelected = Set<String>.from(selectedOptions);
                if (selected) {
                  newSelected.add(option);
                } else {
                  newSelected.remove(option);
                }
                onChanged(newSelected);
              },
              selectedColor: const Color(0xFF4CAF50),
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Switch tile builder
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  // Time button builder
  Widget _buildTimeButton({
    required TimeOfDay? time,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          time?.format(context) ?? label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Time picker helper
  Future<void> _selectTime(String day, bool isStart) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: isStart 
          ? _businessHoursStart[day] ?? const TimeOfDay(hour: 9, minute: 0)
          : _businessHoursEnd[day] ?? const TimeOfDay(hour: 17, minute: 0),
    );
    
    if (time != null) {
      setState(() {
        if (isStart) {
          _businessHoursStart[day] = time;
        } else {
          _businessHoursEnd[day] = time;
        }
      });
    }
  }

  // Enhanced form submission
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prepare comprehensive user data
    final Map<String, dynamic> userData = {
      // Basic Information
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'user_type': _selectedUserType.name,
      'auto_switch': _autoSwitchToNewUser,
      
      // Address Information
      'address': _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _selectedState,
      'postal_code': _postalCodeController.text.trim(),
    };

    // Add user-type specific data
    if (_selectedUserType == UserType.business) {
      userData['business_id'] = _generateBusinessId();
      userData['business_name'] = _businessNameController.text.trim();
      userData['business_category'] = _selectedBusinessCategory;
      userData['business_description'] = _businessDescriptionController.text.trim();
      userData['business_website'] = _websiteController.text.trim();
      userData['business_license'] = _businessLicenseController.text.trim();
      userData['tax_id'] = _taxIdController.text.trim();
      userData['delivery_radius'] = int.tryParse(_deliveryRadiusController.text.trim()) ?? 5;
      userData['min_order_amount'] = double.tryParse(_minimumOrderController.text.trim()) ?? 0.0;
      userData['accepts_cash'] = _selectedPaymentMethods.contains('Cash');
      userData['accepts_cards'] = _selectedPaymentMethods.contains('Cards');
      userData['accepts_digital'] = _selectedPaymentMethods.contains('Digital');
      
      // Business hours
      final businessHours = <String, dynamic>{};
      for (String day in _weekdays) {
        businessHours[day.toLowerCase()] = {
          'start': _businessHoursStart[day]?.format(context) ?? '09:00',
          'end': _businessHoursEnd[day]?.format(context) ?? '17:00',
        };
      }
      userData['business_hours'] = businessHours;
    } else {
      userData['dietary_preferences'] = _selectedDietaryPreferences.toList();
      userData['favorite_cuisines'] = _selectedFavoriteCuisines.toList();
      userData['notification_preferences'] = {
        'email': _emailNotifications,
        'sms': _smsNotifications,
        'push': _notificationsEnabled,
      };
    }

    widget.onSubmit(userData);
  }

  String _generateBusinessId() {
    // Generate a simple UUID-like string for demo purposes
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return '550e8400-e29b-41d4-a716-$random${random}001';
  }

  // Reset form method
  void reset() {
    _formKey.currentState?.reset();
    
    // Clear all controllers
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _streetController.clear();
    _cityController.clear();
    _postalCodeController.clear();
    _businessNameController.clear();
    _businessDescriptionController.clear();
    _websiteController.clear();
    _businessLicenseController.clear();
    _taxIdController.clear();
    _deliveryRadiusController.clear();
    _minimumOrderController.clear();
    
    // Reset state
    setState(() {
      _selectedUserType = widget.initialUserType ?? UserType.customer;
      _autoSwitchToNewUser = true;
      _selectedState = null;
      _selectedBusinessCategory = null;
      _selectedDietaryPreferences.clear();
      _selectedFavoriteCuisines.clear();
      _selectedPaymentMethods.clear();
      _notificationsEnabled = true;
      _emailNotifications = true;
      _smsNotifications = false;
      
      // Reset business hours
      for (String day in _weekdays) {
        _businessHoursStart[day] = const TimeOfDay(hour: 9, minute: 0);
        _businessHoursEnd[day] = const TimeOfDay(hour: 17, minute: 0);
      }
    });
  }
}