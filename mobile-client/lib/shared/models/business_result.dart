import 'package:freezed_annotation/freezed_annotation.dart';
import 'business.dart';

part 'business_result.freezed.dart';

@freezed
class BusinessResult with _$BusinessResult {
  const factory BusinessResult.success(Business business) = BusinessSuccess;
  const factory BusinessResult.failure(String error) = BusinessFailure;

  const BusinessResult._();

  bool get isSuccess => this is BusinessSuccess;
  bool get isFailure => this is BusinessFailure;

  Business? get business => maybeWhen(
    success: (business) => business,
    orElse: () => null,
  );

  String? get error => maybeWhen(
    failure: (error) => error,
    orElse: () => null,
  );
}

@freezed
class ImageUploadResult with _$ImageUploadResult {
  const factory ImageUploadResult.success(String imageUrl) = ImageUploadSuccess;
  const factory ImageUploadResult.failure(String error) = ImageUploadFailure;

  const ImageUploadResult._();

  bool get isSuccess => this is ImageUploadSuccess;
  bool get isFailure => this is ImageUploadFailure;

  String? get imageUrl => maybeWhen(
    success: (url) => url,
    orElse: () => null,
  );

  String? get error => maybeWhen(
    failure: (error) => error,
    orElse: () => null,
  );
}