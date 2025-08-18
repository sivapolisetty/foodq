// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DealResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Deal deal) success,
    required TResult Function(String message, String? code) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Deal deal)? success,
    TResult? Function(String message, String? code)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Deal deal)? success,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DealSuccess value) success,
    required TResult Function(DealError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DealSuccess value)? success,
    TResult? Function(DealError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DealSuccess value)? success,
    TResult Function(DealError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealResultCopyWith<$Res> {
  factory $DealResultCopyWith(
          DealResult value, $Res Function(DealResult) then) =
      _$DealResultCopyWithImpl<$Res, DealResult>;
}

/// @nodoc
class _$DealResultCopyWithImpl<$Res, $Val extends DealResult>
    implements $DealResultCopyWith<$Res> {
  _$DealResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DealResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DealSuccessImplCopyWith<$Res> {
  factory _$$DealSuccessImplCopyWith(
          _$DealSuccessImpl value, $Res Function(_$DealSuccessImpl) then) =
      __$$DealSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Deal deal});

  $DealCopyWith<$Res> get deal;
}

/// @nodoc
class __$$DealSuccessImplCopyWithImpl<$Res>
    extends _$DealResultCopyWithImpl<$Res, _$DealSuccessImpl>
    implements _$$DealSuccessImplCopyWith<$Res> {
  __$$DealSuccessImplCopyWithImpl(
      _$DealSuccessImpl _value, $Res Function(_$DealSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of DealResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deal = null,
  }) {
    return _then(_$DealSuccessImpl(
      deal: null == deal
          ? _value.deal
          : deal // ignore: cast_nullable_to_non_nullable
              as Deal,
    ));
  }

  /// Create a copy of DealResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DealCopyWith<$Res> get deal {
    return $DealCopyWith<$Res>(_value.deal, (value) {
      return _then(_value.copyWith(deal: value));
    });
  }
}

/// @nodoc

class _$DealSuccessImpl extends DealSuccess {
  const _$DealSuccessImpl({required this.deal}) : super._();

  @override
  final Deal deal;

  @override
  String toString() {
    return 'DealResult.success(deal: $deal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealSuccessImpl &&
            (identical(other.deal, deal) || other.deal == deal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deal);

  /// Create a copy of DealResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealSuccessImplCopyWith<_$DealSuccessImpl> get copyWith =>
      __$$DealSuccessImplCopyWithImpl<_$DealSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Deal deal) success,
    required TResult Function(String message, String? code) error,
  }) {
    return success(deal);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Deal deal)? success,
    TResult? Function(String message, String? code)? error,
  }) {
    return success?.call(deal);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Deal deal)? success,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(deal);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DealSuccess value) success,
    required TResult Function(DealError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DealSuccess value)? success,
    TResult? Function(DealError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DealSuccess value)? success,
    TResult Function(DealError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class DealSuccess extends DealResult {
  const factory DealSuccess({required final Deal deal}) = _$DealSuccessImpl;
  const DealSuccess._() : super._();

  Deal get deal;

  /// Create a copy of DealResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealSuccessImplCopyWith<_$DealSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DealErrorImplCopyWith<$Res> {
  factory _$$DealErrorImplCopyWith(
          _$DealErrorImpl value, $Res Function(_$DealErrorImpl) then) =
      __$$DealErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$DealErrorImplCopyWithImpl<$Res>
    extends _$DealResultCopyWithImpl<$Res, _$DealErrorImpl>
    implements _$$DealErrorImplCopyWith<$Res> {
  __$$DealErrorImplCopyWithImpl(
      _$DealErrorImpl _value, $Res Function(_$DealErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of DealResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
  }) {
    return _then(_$DealErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$DealErrorImpl extends DealError {
  const _$DealErrorImpl({required this.message, this.code}) : super._();

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'DealResult.error(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of DealResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealErrorImplCopyWith<_$DealErrorImpl> get copyWith =>
      __$$DealErrorImplCopyWithImpl<_$DealErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Deal deal) success,
    required TResult Function(String message, String? code) error,
  }) {
    return error(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Deal deal)? success,
    TResult? Function(String message, String? code)? error,
  }) {
    return error?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Deal deal)? success,
    TResult Function(String message, String? code)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DealSuccess value) success,
    required TResult Function(DealError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DealSuccess value)? success,
    TResult? Function(DealError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DealSuccess value)? success,
    TResult Function(DealError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class DealError extends DealResult {
  const factory DealError({required final String message, final String? code}) =
      _$DealErrorImpl;
  const DealError._() : super._();

  String get message;
  String? get code;

  /// Create a copy of DealResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealErrorImplCopyWith<_$DealErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
