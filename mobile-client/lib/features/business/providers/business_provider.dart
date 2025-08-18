import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/business_service.dart';
import '../../../shared/models/business.dart';
import '../../../shared/models/business_result.dart';

// Business Service Provider
final businessServiceProvider = Provider<BusinessService>((ref) {
  return BusinessService();
});

// Business State Provider
final businessStateProvider = StateNotifierProvider<BusinessStateNotifier, BusinessState>((ref) {
  final businessService = ref.watch(businessServiceProvider);
  return BusinessStateNotifier(businessService);
});

// Business Enrollment Form Provider
final businessEnrollmentFormProvider = StateNotifierProvider<BusinessEnrollmentFormNotifier, BusinessEnrollmentFormState>((ref) {
  return BusinessEnrollmentFormNotifier();
});

// Current User's Business Provider
final currentUserBusinessProvider = FutureProvider.family<Business?, String>((ref, ownerId) async {
  final businessService = ref.watch(businessServiceProvider);
  return await businessService.getBusinessByOwnerId(ownerId);
});

// Business Search Provider
final businessSearchProvider = StateNotifierProvider<BusinessSearchNotifier, BusinessSearchState>((ref) {
  final businessService = ref.watch(businessServiceProvider);
  return BusinessSearchNotifier(businessService);
});

// Business State
class BusinessState {
  final Business? business;
  final bool isLoading;
  final String? error;
  final bool isEnrolling;
  final bool isUploading;

  const BusinessState({
    this.business,
    this.isLoading = false,
    this.error,
    this.isEnrolling = false,
    this.isUploading = false,
  });

  BusinessState copyWith({
    Business? business,
    bool? isLoading,
    String? error,
    bool? isEnrolling,
    bool? isUploading,
  }) {
    return BusinessState(
      business: business ?? this.business,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isEnrolling: isEnrolling ?? this.isEnrolling,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

// Business State Notifier
class BusinessStateNotifier extends StateNotifier<BusinessState> {
  final BusinessService _businessService;

  BusinessStateNotifier(this._businessService) : super(const BusinessState());

  Future<void> enrollBusiness({
    required String ownerId,
    required String name,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    String? phone,
    String? email,
  }) async {
    state = state.copyWith(isEnrolling: true, error: null);

    final result = await _businessService.enrollBusiness(
      ownerId: ownerId,
      name: name,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      email: email,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        business: result.business,
        isEnrolling: false,
      );
    } else {
      state = state.copyWith(
        error: result.error,
        isEnrolling: false,
      );
    }
  }

  Future<void> updateBusiness(String businessId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _businessService.updateBusiness(businessId, updates);

    if (result.isSuccess) {
      state = state.copyWith(
        business: result.business,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: result.error,
        isLoading: false,
      );
    }
  }

  Future<void> uploadLogo(String businessId, String imageData) async {
    state = state.copyWith(isUploading: true, error: null);

    final result = await _businessService.uploadBusinessLogo(businessId, imageData);

    if (result.isSuccess) {
      // Update business with new logo URL
      if (state.business != null) {
        final updatedBusiness = state.business!.copyWith(logoUrl: result.imageUrl);
        state = state.copyWith(
          business: updatedBusiness,
          isUploading: false,
        );
      }
    } else {
      state = state.copyWith(
        error: result.error,
        isUploading: false,
      );
    }
  }

  Future<void> uploadCoverImage(String businessId, String imageData) async {
    state = state.copyWith(isUploading: true, error: null);

    final result = await _businessService.uploadBusinessCoverImage(businessId, imageData);

    if (result.isSuccess) {
      if (state.business != null) {
        final updatedBusiness = state.business!.copyWith(coverImageUrl: result.imageUrl);
        state = state.copyWith(
          business: updatedBusiness,
          isUploading: false,
        );
      }
    } else {
      state = state.copyWith(
        error: result.error,
        isUploading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Business Enrollment Form State
class BusinessEnrollmentFormState {
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final double? latitude;
  final double? longitude;
  final Map<String, String> errors;
  final bool hasSelectedLocation;

  const BusinessEnrollmentFormState({
    this.name = '',
    this.description = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.latitude,
    this.longitude,
    this.errors = const {},
    this.hasSelectedLocation = false,
  });

  BusinessEnrollmentFormState copyWith({
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    double? latitude,
    double? longitude,
    Map<String, String>? errors,
    bool? hasSelectedLocation,
  }) {
    return BusinessEnrollmentFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      errors: errors ?? this.errors,
      hasSelectedLocation: hasSelectedLocation ?? this.hasSelectedLocation,
    );
  }

  bool get isValid {
    return name.isNotEmpty &&
           description.isNotEmpty &&
           address.isNotEmpty &&
           errors.isEmpty &&
           hasSelectedLocation &&
           _isValidEmail(email) &&
           _isValidPhone(phone);
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return true; // Email is optional
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    if (phone.isEmpty) return true; // Phone is optional
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }
}

// Business Enrollment Form Notifier
class BusinessEnrollmentFormNotifier extends StateNotifier<BusinessEnrollmentFormState> {
  BusinessEnrollmentFormNotifier() : super(const BusinessEnrollmentFormState());

  void updateName(String name) {
    final errors = Map<String, String>.from(state.errors);
    
    if (name.isEmpty) {
      errors['name'] = 'Business name is required';
    } else if (name.length < 2) {
      errors['name'] = 'Business name must be at least 2 characters';
    } else {
      errors.remove('name');
    }

    state = state.copyWith(name: name, errors: errors);
  }

  void updateDescription(String description) {
    final errors = Map<String, String>.from(state.errors);
    
    if (description.isEmpty) {
      errors['description'] = 'Description is required';
    } else if (description.length < 10) {
      errors['description'] = 'Description must be at least 10 characters';
    } else {
      errors.remove('description');
    }

    state = state.copyWith(description: description, errors: errors);
  }

  void updateAddress(String address) {
    final errors = Map<String, String>.from(state.errors);
    
    if (address.isEmpty) {
      errors['address'] = 'Address is required';
    } else {
      errors.remove('address');
    }

    state = state.copyWith(address: address, errors: errors);
  }

  void updatePhone(String phone) {
    final errors = Map<String, String>.from(state.errors);
    
    if (phone.isNotEmpty && !_isValidPhone(phone)) {
      errors['phone'] = 'Please enter a valid phone number';
    } else {
      errors.remove('phone');
    }

    state = state.copyWith(phone: phone, errors: errors);
  }

  void updateEmail(String email) {
    final errors = Map<String, String>.from(state.errors);
    
    if (email.isNotEmpty && !_isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email';
    } else {
      errors.remove('email');
    }

    state = state.copyWith(email: email, errors: errors);
  }

  void updateLocation(double latitude, double longitude) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      hasSelectedLocation: true,
    );
  }

  void validateForm() {
    final errors = <String, String>{};

    if (state.name.isEmpty) {
      errors['name'] = 'Business name is required';
    } else if (state.name.length < 2) {
      errors['required'] = 'Business name must be at least 2 characters';
    }

    if (state.description.isEmpty) {
      errors['description'] = 'Description is required';
    } else if (state.description.length < 10) {
      errors['description'] = 'Description must be at least 10 characters';
    }

    if (state.address.isEmpty) {
      errors['address'] = 'Address is required';
    }

    if (!state.hasSelectedLocation) {
      errors['location'] = 'Please select your business location';
    }

    if (state.phone.isNotEmpty && !_isValidPhone(state.phone)) {
      errors['phone'] = 'Please enter a valid phone number';
    }

    if (state.email.isNotEmpty && !_isValidEmail(state.email)) {
      errors['email'] = 'Please enter a valid email';
    }

    state = state.copyWith(errors: errors);
  }

  void clearForm() {
    state = const BusinessEnrollmentFormState();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }
}

// Business Search State
class BusinessSearchState {
  final List<Business> results;
  final bool isLoading;
  final String query;
  final String? error;

  const BusinessSearchState({
    this.results = const [],
    this.isLoading = false,
    this.query = '',
    this.error,
  });

  BusinessSearchState copyWith({
    List<Business>? results,
    bool? isLoading,
    String? query,
    String? error,
  }) {
    return BusinessSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      error: error,
    );
  }
}

// Business Search Notifier
class BusinessSearchNotifier extends StateNotifier<BusinessSearchState> {
  final BusinessService _businessService;

  BusinessSearchNotifier(this._businessService) : super(const BusinessSearchState());

  Future<void> searchBusinesses(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(results: [], query: query);
      return;
    }

    state = state.copyWith(isLoading: true, query: query, error: null);

    try {
      final results = await _businessService.searchBusinesses(query);
      state = state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearSearch() {
    state = const BusinessSearchState();
  }
}