import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';
import '../../../shared/models/app_user.dart';

/// Service for managing users (both mock and authenticated)
/// Handles CRUD operations for the unified user system
class UserService {
  static const String _endpoint = '/api/users'; // Worker handles app_users table internally

  /// Get all users
  Future<List<AppUser>> getAllUsers() async {
    try {
      final response = await ApiService.get<List<dynamic>>(
        _endpoint,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => AppUser.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load users: ${response.error}');
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  /// Get users by type (business or customer)
  Future<List<AppUser>> getUsersByType(String userType) async {
    try {
      final response = await ApiService.get<List<dynamic>>(
        '$_endpoint?user_type=eq.$userType',
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => AppUser.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load users by type: ${response.error}');
    } catch (e) {
      throw Exception('Failed to load users by type: $e');
    }
  }

  /// Get user by ID
  Future<AppUser?> getUserById(String userId) async {
    try {
      final response = await ApiService.get<List<dynamic>>(
        '$_endpoint?id=eq.$userId',
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        return AppUser.fromJson(response.data!.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user with business ID from onboarding status
  Future<AppUser?> getUserWithBusinessId(String userId) async {
    try {
      // First get basic user data
      final userResponse = await ApiService.get<dynamic>(
        '$_endpoint?id=eq.$userId',
        fromJson: (data) => data,
      );

      if (!userResponse.success || userResponse.data == null) {
        return null;
      }

      List<dynamic> userData;
      if (userResponse.data is List) {
        userData = userResponse.data as List<dynamic>;
        if (userData.isEmpty) return null;
      } else if (userResponse.data is Map && userResponse.data['data'] is List) {
        userData = userResponse.data['data'] as List<dynamic>;
        if (userData.isEmpty) return null;
      } else {
        return null;
      }

      final user = AppUser.fromJson(userData.first as Map<String, dynamic>);

      // If not a business user, return as is
      if (!user.isBusiness) {
        return user;
      }

      // Get onboarding status to find business ID
      final onboardingResponse = await ApiService.get<dynamic>(
        '/api/users/$userId/onboarding-status',
        fromJson: (data) => data,
      );

      if (onboardingResponse.success && onboardingResponse.data != null) {
        final onboardingData = onboardingResponse.data;
        String? businessId;

        // Extract business ID from different possible response structures
        if (onboardingData is Map<String, dynamic>) {
          final businessStatus = onboardingData['business_status'] as Map<String, dynamic>?;
          if (businessStatus != null) {
            // Try to get business ID from business status
            final businessName = businessStatus['name'] as String?;
            if (businessName != null) {
              // Get business ID by querying businesses owned by the user
              final businessResponse = await ApiService.get<dynamic>(
                '/api/businesses',
                queryParameters: {
                  'owner_id': user.id, // Query by owner_id to find businesses owned by this user
                  'limit': '1'
                },
                fromJson: (data) => data,
              );

              if (businessResponse.success && businessResponse.data != null) {
                final businessData = businessResponse.data;
                
                // Handle both direct data arrays and wrapped responses
                List<dynamic>? businesses;
                if (businessData is List) {
                  businesses = businessData;
                } else if (businessData is Map) {
                  if (businessData.containsKey('data') && businessData['data'] is List) {
                    businesses = businessData['data'] as List<dynamic>;
                  } else if (businessData.containsKey('success') && businessData['data'] is List) {
                    businesses = businessData['data'] as List<dynamic>;
                  }
                }
                
                if (businesses != null && businesses.isNotEmpty) {
                  final business = businesses.first as Map<String, dynamic>;
                  businessId = business['id'] as String?;
                  print('Found business ID for user ${user.id}: $businessId');
                }
              }
            }
          }
        }

        // Create updated user with business ID
        return AppUser.business(
          id: user.id,
          name: user.name,
          email: user.email,
          businessId: businessId ?? user.businessId ?? '', // Use found business ID or fallback
          phone: user.phone,
          profileImageUrl: user.profileImageUrl,
        );
      }

      return user;
    } catch (e) {
      print('Error getting user with business ID: $e');
      return null;
    }
  }

  /// Create a new user
  Future<AppUser> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await ApiService.post<Map<String, dynamic>>(
        _endpoint,
        body: userData,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppUser.fromJson(response.data!);
      }
      throw Exception('Failed to create user: ${response.error}');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Update an existing user
  Future<AppUser> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final response = await ApiService.put<Map<String, dynamic>>(
        '$_endpoint?id=eq.$userId',
        body: updates,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppUser.fromJson(response.data!);
      }
      throw Exception('Failed to update user: ${response.error}');
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Delete a user
  Future<bool> deleteUser(String userId) async {
    try {
      final response = await ApiService.delete(
        '$_endpoint?id=eq.$userId',
      );

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Create predefined test users for demo
  Future<List<AppUser>> createTestUsers() async {
    try {
      final testUsers = [
        // Business users
        {
          'name': 'Mario Rossi',
          'email': 'mario@demopizza.com',
          'user_type': 'business',
          'business_id': '550e8400-e29b-41d4-a716-446655440001',
          'phone': '+1-555-123-0001',
        },
        {
          'name': 'Sarah Johnson',
          'email': 'sarah@burgerbarn.com',
          'user_type': 'business',
          'business_id': 'aeaec618-7e20-4ef3-a7da-97510d119366',
          'phone': '+1-555-123-0002',
        },
        {
          'name': 'Alex Chen',
          'email': 'alex@coffeecorner.com',
          'user_type': 'business',
          'business_id': '78bffd03-bb34-4ddb-b144-99cecd71f9f4',
          'phone': '+1-555-123-0003',
        },
        // Customer users
        {
          'name': 'John Smith',
          'email': 'john.smith@email.com',
          'user_type': 'customer',
          'phone': '+1-555-123-0004',
        },
        {
          'name': 'Emma Wilson',
          'email': 'emma.wilson@email.com',
          'user_type': 'customer',
          'phone': '+1-555-123-0005',
        },
        {
          'name': 'Mike Chen',
          'email': 'mike.chen@email.com',
          'user_type': 'customer',
          'phone': '+1-555-123-0006',
        },
        {
          'name': 'Lisa Brown',
          'email': 'lisa.brown@email.com',
          'user_type': 'customer',
          'phone': '+1-555-123-0007',
        },
        {
          'name': 'David Jones',
          'email': 'david.jones@email.com',
          'user_type': 'customer',
          'phone': '+1-555-123-0008',
        },
      ];

      final createdUsers = <AppUser>[];
      for (final userData in testUsers) {
        try {
          final user = await createUser(userData);
          createdUsers.add(user);
        } catch (e) {
          // Skip if user already exists (based on email constraint)
          print('Skipping existing user: ${userData['email']}');
        }
      }

      return createdUsers;
    } catch (e) {
      throw Exception('Failed to create test users: $e');
    }
  }

  /// Check if test users exist
  Future<bool> hasTestUsers() async {
    try {
      final users = await getAllUsers();
      return users.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Reset all users (for testing)
  Future<bool> resetUsers() async {
    try {
      final users = await getAllUsers();
      for (final user in users) {
        await deleteUser(user.id);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}