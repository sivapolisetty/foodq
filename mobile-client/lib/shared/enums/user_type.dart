import 'package:freezed_annotation/freezed_annotation.dart';

/// User type enumeration for MVP user switching system
/// Defines whether a user is a business owner or customer
enum UserType {
  @JsonValue('business')
  business,
  
  @JsonValue('customer')
  customer;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case UserType.business:
        return 'Business';
      case UserType.customer:
        return 'Customer';
    }
  }

  /// Icon for UI representation
  String get icon {
    switch (this) {
      case UserType.business:
        return '🏪';
      case UserType.customer:
        return '👤';
    }
  }

  /// Color for UI styling
  String get colorHex {
    switch (this) {
      case UserType.business:
        return '#4CAF50'; // Green for business
      case UserType.customer:
        return '#2196F3'; // Blue for customer
    }
  }

  /// Check if user type has business management capabilities
  bool get hasBusinessAccess => this == UserType.business;

  /// Check if user type has customer features
  bool get hasCustomerAccess => this == UserType.customer;
}