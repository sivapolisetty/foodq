import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant_onboarding_request.dart';
import '../services/restaurant_onboarding_service.dart';

/// Restaurant Onboarding State
class RestaurantOnboardingState {
  final RestaurantOnboardingRequest? currentApplication;
  final List<RestaurantOnboardingRequest> allApplications;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const RestaurantOnboardingState({
    this.currentApplication,
    this.allApplications = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  RestaurantOnboardingState copyWith({
    RestaurantOnboardingRequest? currentApplication,
    List<RestaurantOnboardingRequest>? allApplications,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return RestaurantOnboardingState(
      currentApplication: currentApplication ?? this.currentApplication,
      allApplications: allApplications ?? this.allApplications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Restaurant Onboarding State Notifier
class RestaurantOnboardingNotifier extends StateNotifier<RestaurantOnboardingState> {
  final RestaurantOnboardingService _service;

  RestaurantOnboardingNotifier(this._service) : super(const RestaurantOnboardingState());

  /// Load user's restaurant onboarding application
  Future<void> loadUserApplication(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final application = await _service.getUserApplication(userId);
      state = state.copyWith(
        currentApplication: application,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load application: $e',
      );
    }
  }

  /// Submit a new restaurant onboarding application
  Future<RestaurantOnboardingRequest?> submitApplication(
    RestaurantOnboardingFormData formData,
  ) async {
    state = state.copyWith(isSubmitting: true, error: null);
    
    try {
      final application = await _service.submitApplication(formData);
      state = state.copyWith(
        currentApplication: application,
        isSubmitting: false,
      );
      return application;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit application: $e',
      );
      return null;
    }
  }

  /// Refresh application status
  Future<void> refreshApplicationStatus(String applicationId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final application = await _service.getApplicationById(applicationId);
      state = state.copyWith(
        currentApplication: application,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh status: $e',
      );
    }
  }

  /// Clear current application (for submitting new after rejection)
  void clearCurrentApplication() {
    state = state.copyWith(currentApplication: null);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Load all applications (admin use)
  Future<void> loadAllApplications() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final applications = await _service.getAllApplications();
      state = state.copyWith(
        allApplications: applications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load applications: $e',
      );
    }
  }

  /// Update application status (admin use)
  Future<bool> updateApplicationStatus(
    String applicationId,
    String status, {
    String? adminNotes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _service.updateApplicationStatus(
        applicationId,
        status,
        adminNotes: adminNotes,
      );
      
      if (success) {
        // Refresh the specific application
        await refreshApplicationStatus(applicationId);
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update status: $e',
      );
      return false;
    }
  }
}

/// Restaurant Onboarding Provider
final restaurantOnboardingServiceProvider = Provider<RestaurantOnboardingService>((ref) {
  return RestaurantOnboardingService();
});

final restaurantOnboardingProvider = StateNotifierProvider<RestaurantOnboardingNotifier, RestaurantOnboardingState>((ref) {
  final service = ref.watch(restaurantOnboardingServiceProvider);
  return RestaurantOnboardingNotifier(service);
});