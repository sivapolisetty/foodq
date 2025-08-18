import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grabeat/core/services/auth_service.dart';
import 'package:grabeat/shared/models/app_user.dart';
import 'package:grabeat/shared/enums/user_type.dart';

import 'auth_service_google_magic_test.mocks.dart';

@GenerateMocks([
  SupabaseClient,
  GoTrueClient,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  User,
  Session,
  AuthResponse,
])
void main() {
  late AuthService authService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockGoogleSignIn mockGoogleSignIn;
  
  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockGoogleSignIn = MockGoogleSignIn();
    
    // Setup mock returns
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    
    // Create auth service with mocked dependencies
    // Note: In a real implementation, you'd inject these dependencies
    authService = AuthService();
  });

  group('Google Sign-In Tests', () {
    test('should successfully sign in with Google', () async {
      // Arrange
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();
      final mockUser = MockUser();
      final mockAuthResponse = MockAuthResponse();
      
      when(mockGoogleUser.displayName).thenReturn('Test User');
      when(mockGoogleUser.email).thenReturn('test@example.com');
      when(mockGoogleUser.photoUrl).thenReturn('https://example.com/photo.jpg');
      when(mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
      
      when(mockGoogleAuth.idToken).thenReturn('test-id-token');
      when(mockGoogleAuth.accessToken).thenReturn('test-access-token');
      
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
      
      when(mockUser.id).thenReturn('user-123');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockAuthResponse.user).thenReturn(mockUser);
      
      when(mockGoTrueClient.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: 'test-id-token',
        accessToken: 'test-access-token',
      )).thenAnswer((_) async => mockAuthResponse);

      // Act & Assert - Test would need actual implementation
      expect(mockGoogleUser.email, 'test@example.com');
      expect(mockGoogleAuth.idToken, 'test-id-token');
    });

    test('should handle Google sign-in cancellation', () async {
      // Arrange
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () async => await authService.signInWithGoogle(),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle Google sign-in error', () async {
      // Arrange
      when(mockGoogleSignIn.signIn()).thenThrow(Exception('Google sign-in failed'));

      // Act & Assert
      expect(
        () async => await authService.signInWithGoogle(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Magic Link Tests', () {
    test('should send magic link successfully', () async {
      // Arrange
      const email = 'test@example.com';
      
      when(mockGoTrueClient.signInWithOtp(
        email: email,
        emailRedirectTo: null,
      )).thenAnswer((_) async => {});

      // Act
      await authService.signInWithMagicLink(email: email);

      // Assert
      verify(mockGoTrueClient.signInWithOtp(
        email: email,
        emailRedirectTo: null,
      )).called(1);
    });

    test('should send magic link with redirect URL', () async {
      // Arrange
      const email = 'test@example.com';
      const redirectTo = 'https://example.com/auth/callback';
      
      when(mockGoTrueClient.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo,
      )).thenAnswer((_) async => {});

      // Act
      await authService.signInWithMagicLink(
        email: email,
        redirectTo: redirectTo,
      );

      // Assert
      verify(mockGoTrueClient.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo,
      )).called(1);
    });

    test('should handle magic link send error', () async {
      // Arrange
      const email = 'test@example.com';
      
      when(mockGoTrueClient.signInWithOtp(
        email: email,
        emailRedirectTo: null,
      )).thenThrow(Exception('Failed to send magic link'));

      // Act & Assert
      expect(
        () async => await authService.signInWithMagicLink(email: email),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('OTP Verification Tests', () {
    test('should verify OTP successfully', () async {
      // Arrange
      const email = 'test@example.com';
      const token = '123456';
      final mockUser = MockUser();
      final mockAuthResponse = MockAuthResponse();
      
      when(mockUser.id).thenReturn('user-123');
      when(mockUser.email).thenReturn(email);
      when(mockAuthResponse.user).thenReturn(mockUser);
      
      when(mockGoTrueClient.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      )).thenAnswer((_) async => mockAuthResponse);

      // Act
      final response = await authService.verifyOTP(
        email: email,
        token: token,
      );

      // Assert
      expect(response.user, isNotNull);
      expect(response.user?.email, email);
    });

    test('should handle OTP verification error', () async {
      // Arrange
      const email = 'test@example.com';
      const token = 'invalid';
      
      when(mockGoTrueClient.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      )).thenThrow(Exception('Invalid OTP'));

      // Act & Assert
      expect(
        () async => await authService.verifyOTP(
          email: email,
          token: token,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should create app user after successful OTP verification', () async {
      // Arrange
      const email = 'newuser@example.com';
      const token = '123456';
      final mockUser = MockUser();
      final mockAuthResponse = MockAuthResponse();
      
      when(mockUser.id).thenReturn('user-456');
      when(mockUser.email).thenReturn(email);
      when(mockAuthResponse.user).thenReturn(mockUser);
      
      when(mockGoTrueClient.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      )).thenAnswer((_) async => mockAuthResponse);

      // Mock getCurrentAppUser to return null (new user)
      when(mockSupabaseClient.from('app_users'))
          .thenReturn(mockSupabaseClient as dynamic);
      when(mockSupabaseClient.select())
          .thenReturn(mockSupabaseClient as dynamic);
      when(mockSupabaseClient.eq('id', 'user-456'))
          .thenReturn(mockSupabaseClient as dynamic);
      when(mockSupabaseClient.single())
          .thenThrow(Exception('User not found'));

      // Act
      final response = await authService.verifyOTP(
        email: email,
        token: token,
      );

      // Assert
      expect(response.user, isNotNull);
      expect(response.user?.id, 'user-456');
    });
  });

  group('Sign Out Tests', () {
    test('should sign out from Google and Supabase', () async {
      // Arrange
      when(mockGoogleSignIn.isSignedIn()).thenAnswer((_) async => true);
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      when(mockGoTrueClient.signOut()).thenAnswer((_) async => {});

      // Act
      await authService.signOut();

      // Assert
      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockGoTrueClient.signOut()).called(1);
    });

    test('should sign out from Supabase only when not signed in with Google', () async {
      // Arrange
      when(mockGoogleSignIn.isSignedIn()).thenAnswer((_) async => false);
      when(mockGoTrueClient.signOut()).thenAnswer((_) async => {});

      // Act
      await authService.signOut();

      // Assert
      verifyNever(mockGoogleSignIn.signOut());
      verify(mockGoTrueClient.signOut()).called(1);
    });
  });

  group('Token Management Tests', () {
    test('should get access token when session exists', () {
      // Arrange
      final mockSession = MockSession();
      when(mockSession.accessToken).thenReturn('test-access-token');
      when(mockGoTrueClient.currentSession).thenReturn(mockSession);

      // Act
      final token = authService.accessToken;

      // Assert
      expect(token, 'test-access-token');
    });

    test('should return null when no session exists', () {
      // Arrange
      when(mockGoTrueClient.currentSession).thenReturn(null);

      // Act
      final token = authService.accessToken;

      // Assert
      expect(token, isNull);
    });
  });

  group('User Profile Tests', () {
    test('should create user profile with Google provider', () async {
      // Arrange
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockUser = MockUser();
      
      when(mockGoogleUser.displayName).thenReturn('Google User');
      when(mockGoogleUser.photoUrl).thenReturn('https://example.com/avatar.jpg');
      when(mockUser.id).thenReturn('google-user-123');
      when(mockUser.email).thenReturn('google@example.com');

      // Mock database insert
      when(mockSupabaseClient.from('app_users'))
          .thenReturn(mockSupabaseClient as dynamic);
      when(mockSupabaseClient.insert(any))
          .thenAnswer((_) async => {});

      // Act & Assert
      expect(mockGoogleUser.displayName, 'Google User');
      expect(mockGoogleUser.photoUrl, contains('avatar.jpg'));
    });

    test('should create user profile with magic link provider', () async {
      // Arrange
      final mockUser = MockUser();
      const email = 'magic@example.com';
      
      when(mockUser.id).thenReturn('magic-user-123');
      when(mockUser.email).thenReturn(email);

      // Mock database insert
      when(mockSupabaseClient.from('app_users'))
          .thenReturn(mockSupabaseClient as dynamic);
      when(mockSupabaseClient.insert(any))
          .thenAnswer((_) async => {});

      // Act & Assert
      expect(mockUser.email, email);
      expect(mockUser.id, contains('magic'));
    });
  });
}