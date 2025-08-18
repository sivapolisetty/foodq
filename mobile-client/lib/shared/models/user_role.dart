enum UserRole {
  customer('customer'),
  business('business_owner'),
  staff('staff');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'business_owner':
      case 'business':
        return UserRole.business;
      case 'staff':
        return UserRole.staff;
      default:
        return UserRole.customer; // Default to customer
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.business:
        return 'Business Owner';
      case UserRole.staff:
        return 'Staff';
    }
  }

  bool get canManageBusiness {
    return this == UserRole.business;
  }

  bool get canManageOrders {
    return this == UserRole.business || this == UserRole.staff;
  }

  bool get canViewFinances {
    return this == UserRole.business;
  }

  bool get canManageDeals {
    return this == UserRole.business || this == UserRole.staff;
  }
}