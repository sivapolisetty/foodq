import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grabeat/features/auth/services/auth_service.dart';
import 'package:grabeat/shared/models/user_role.dart';

@GenerateMocks([SupabaseClient, GoTrueClient, AuthResponse, User, Session])
import 'auth_service_test.mocks.dart';

void main() {
  late AuthService authService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    
    authService = AuthService(supabaseClient: mockSupabaseClient);
  });

  group('AuthService Tests', () {
    group('signInWithEmail', () {
      test('should return customer role by default when signing in', () async {
        // Arrange
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        final mockSession = MockSession();
        
        when(mockUser.id).thenReturn('test-user-id');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockSession.user).thenReturn(mockUser);
        when(mockAuthResponse.session).thenReturn(mockSession);
        when(mockAuthResponse.user).thenReturn(mockUser);
        
        when(mockGoTrueClient.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockAuthResponse);

        // Mock profile fetch to return customer role
        when(mockSupabaseClient.from('profiles')).thenReturn(
          MockPostgrestQueryBuilder()
        );
        
        // Act
        final result = await authService.signInWithEmail(
          'test@example.com',
          'password123',
        );
        
        // Assert
        expect(result.isSuccess, true);
        expect(result.user?.role, UserRole.customer);
      });

      test('should return error when credentials are invalid', () async {
        // Arrange
        when(mockGoTrueClient.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(AuthException('Invalid credentials'));
        
        // Act
        final result = await authService.signInWithEmail(
          'invalid@example.com',
          'wrongpassword',
        );
        
        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Invalid credentials'));
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        when(mockGoTrueClient.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('Network error'));
        
        // Act
        final result = await authService.signInWithEmail(
          'test@example.com',
          'password123',
        );
        
        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Network error'));
      });
    });

    group('switchUserRole', () {
      test('should switch from customer to business role', () async {
        // Arrange
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('test-user-id');
        when(mockGoTrueClient.currentUser).thenReturn(mockUser);
        
        when(mockSupabaseClient.from('profiles')).thenReturn(
          MockPostgrestQueryBuilder()
        );
        
        // Act
        final result = await authService.switchUserRole(UserRole.business);
        
        // Assert
        expect(result.isSuccess, true);
        expect(result.user?.role, UserRole.business);
      });

      test('should return error when user is not authenticated', () async {
        // Arrange
        when(mockGoTrueClient.currentUser).thenReturn(null);
        
        // Act
        final result = await authService.switchUserRole(UserRole.business);
        
        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('not authenticated'));
      });
    });

    group('signUp', () {
      test('should create new user with customer role by default', () async {
        // Arrange
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        
        when(mockUser.id).thenReturn('new-user-id');
        when(mockUser.email).thenReturn('newuser@example.com');
        when(mockAuthResponse.user).thenReturn(mockUser);
        
        when(mockGoTrueClient.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockAuthResponse);

        when(mockSupabaseClient.from('profiles')).thenReturn(
          MockPostgrestQueryBuilder()
        );
        
        // Act
        final result = await authService.signUp(
          email: 'newuser@example.com',
          password: 'password123',
          fullName: 'New User',
        );
        
        // Assert
        expect(result.isSuccess, true);
        expect(result.user?.email, 'newuser@example.com');
        expect(result.user?.role, UserRole.customer);
      });

      test('should return error when email already exists', () async {
        // Arrange
        when(mockGoTrueClient.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(AuthException('Email already registered'));
        
        // Act
        final result = await authService.signUp(
          email: 'existing@example.com',
          password: 'password123',
          fullName: 'Existing User',
        );
        
        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('already registered'));
      });
    });

    group('signOut', () {
      test('should sign out user successfully', () async {
        // Arrange
        when(mockGoTrueClient.signOut()).thenAnswer((_) async => {});
        
        // Act
        await authService.signOut();
        
        // Assert
        verify(mockGoTrueClient.signOut()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return current user with profile data', () async {
        // Arrange
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('current-user-id');
        when(mockUser.email).thenReturn('current@example.com');
        when(mockGoTrueClient.currentUser).thenReturn(mockUser);
        
        when(mockSupabaseClient.from('profiles')).thenReturn(
          MockPostgrestQueryBuilder()
        );
        
        // Act
        final result = await authService.getCurrentUser();
        
        // Assert
        expect(result?.id, 'current-user-id');
        expect(result?.email, 'current@example.com');
      });

      test('should return null when no user is signed in', () async {
        // Arrange
        when(mockGoTrueClient.currentUser).thenReturn(null);
        
        // Act
        final result = await authService.getCurrentUser();
        
        // Assert
        expect(result, isNull);
      });
    });
  });
}

// Mock class for PostgrestQueryBuilder
class MockPostgrestQueryBuilder extends Mock {
  MockPostgrestQueryBuilder select([String columns = '*']) => this;
  MockPostgrestQueryBuilder eq(String column, Object value) => this;
  MockPostgrestQueryBuilder single() => this;
  MockPostgrestQueryBuilder upsert(Map<String, dynamic> values) => this;
  
  Future<Map<String, dynamic>> then(Function(Map<String, dynamic>) onValue) {
    // Return mock profile data
    return Future.value({
      'id': 'test-user-id',
      'email': 'test@example.com',
      'full_name': 'Test User',
      'role': 'customer',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}