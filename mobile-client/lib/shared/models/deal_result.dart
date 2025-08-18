import 'package:freezed_annotation/freezed_annotation.dart';
import 'deal.dart';

part 'deal_result.freezed.dart';

@freezed
class DealResult with _$DealResult {
  const factory DealResult.success({
    required Deal deal,
  }) = DealSuccess;
  
  const factory DealResult.error({
    required String message,
    String? code,
  }) = DealError;

  const DealResult._();

  /// Check if the result is successful
  bool get isSuccess => when(
    success: (_) => true,
    error: (_, __) => false,
  );

  /// Check if the result is an error
  bool get isError => !isSuccess;

  /// Get the deal if successful, null otherwise
  Deal? get deal => when(
    success: (deal) => deal,
    error: (_, __) => null,
  );

  /// Get the error message if error, null otherwise
  String? get error => when(
    success: (_) => null,
    error: (message, _) => message,
  );

  /// Get the error code if error, null otherwise
  String? get errorCode => when(
    success: (_) => null,
    error: (_, code) => code,
  );
}