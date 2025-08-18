import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_user.dart';

part 'auth_result.freezed.dart';

@freezed
class AuthResult with _$AuthResult {
  const factory AuthResult.success(AppUser user) = AuthSuccess;
  const factory AuthResult.failure(String error) = AuthFailure;

  const AuthResult._();

  bool get isSuccess => this is AuthSuccess;
  bool get isFailure => this is AuthFailure;

  AppUser? get user => maybeWhen(
    success: (user) => user,
    orElse: () => null,
  );

  String? get error => maybeWhen(
    failure: (error) => error,
    orElse: () => null,
  );
}