// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BusinessResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Business business) success,
    required TResult Function(String error) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Business business)? success,
    TResult? Function(String error)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Business business)? success,
    TResult Function(String error)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BusinessSuccess value) success,
    required TResult Function(BusinessFailure value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BusinessSuccess value)? success,
    TResult? Function(BusinessFailure value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BusinessSuccess value)? success,
    TResult Function(BusinessFailure value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessResultCopyWith<$Res> {
  factory $BusinessResultCopyWith(
          BusinessResult value, $Res Function(BusinessResult) then) =
      _$BusinessResultCopyWithImpl<$Res, BusinessResult>;
}

/// @nodoc
class _$BusinessResultCopyWithImpl<$Res, $Val extends BusinessResult>
    implements $BusinessResultCopyWith<$Res> {
  _$BusinessResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusinessResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$BusinessSuccessImplCopyWith<$Res> {
  factory _$$BusinessSuccessImplCopyWith(_$BusinessSuccessImpl value,
          $Res Function(_$BusinessSuccessImpl) then) =
      __$$BusinessSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Business business});

  $BusinessCopyWith<$Res> get business;
}

/// @nodoc
class __$$BusinessSuccessImplCopyWithImpl<$Res>
    extends _$BusinessResultCopyWithImpl<$Res, _$BusinessSuccessImpl>
    implements _$$BusinessSuccessImplCopyWith<$Res> {
  __$$BusinessSuccessImplCopyWithImpl(
      _$BusinessSuccessImpl _value, $Res Function(_$BusinessSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusinessResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? business = null,
  }) {
    return _then(_$BusinessSuccessImpl(
      null == business
          ? _value.business
          : business // ignore: cast_nullable_to_non_nullable
              as Business,
    ));
  }

  /// Create a copy of BusinessResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BusinessCopyWith<$Res> get business {
    return $BusinessCopyWith<$Res>(_value.business, (value) {
      return _then(_value.copyWith(business: value));
    });
  }
}

/// @nodoc

class _$BusinessSuccessImpl extends BusinessSuccess {
  const _$BusinessSuccessImpl(this.business) : super._();

  @override
  final Business business;

  @override
  String toString() {
    return 'BusinessResult.success(business: $business)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessSuccessImpl &&
            (identical(other.business, business) ||
                other.business == business));
  }

  @override
  int get hashCode => Object.hash(runtimeType, business);

  /// Create a copy of BusinessResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessSuccessImplCopyWith<_$BusinessSuccessImpl> get copyWith =>
      __$$BusinessSuccessImplCopyWithImpl<_$BusinessSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Business business) success,
    required TResult Function(String error) failure,
  }) {
    return success(business);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Business business)? success,
    TResult? Function(String error)? failure,
  }) {
    return success?.call(business);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Business business)? success,
    TResult Function(String error)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(business);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BusinessSuccess value) success,
    required TResult Function(BusinessFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BusinessSuccess value)? success,
    TResult? Function(BusinessFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BusinessSuccess value)? success,
    TResult Function(BusinessFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class BusinessSuccess extends BusinessResult {
  const factory BusinessSuccess(final Business business) =
      _$BusinessSuccessImpl;
  const BusinessSuccess._() : super._();

  Business get business;

  /// Create a copy of BusinessResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessSuccessImplCopyWith<_$BusinessSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BusinessFailureImplCopyWith<$Res> {
  factory _$$BusinessFailureImplCopyWith(_$BusinessFailureImpl value,
          $Res Function(_$BusinessFailureImpl) then) =
      __$$BusinessFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$BusinessFailureImplCopyWithImpl<$Res>
    extends _$BusinessResultCopyWithImpl<$Res, _$BusinessFailureImpl>
    implements _$$BusinessFailureImplCopyWith<$Res> {
  __$$BusinessFailureImplCopyWithImpl(
      _$BusinessFailureImpl _value, $Res Function(_$BusinessFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusinessResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$BusinessFailureImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$BusinessFailureImpl extends BusinessFailure {
  const _$BusinessFailureImpl(this.error) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'BusinessResult.failure(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessFailureImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of BusinessResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessFailureImplCopyWith<_$BusinessFailureImpl> get copyWith =>
      __$$BusinessFailureImplCopyWithImpl<_$BusinessFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Business business) success,
    required TResult Function(String error) failure,
  }) {
    return failure(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Business business)? success,
    TResult? Function(String error)? failure,
  }) {
    return failure?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Business business)? success,
    TResult Function(String error)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BusinessSuccess value) success,
    required TResult Function(BusinessFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BusinessSuccess value)? success,
    TResult? Function(BusinessFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BusinessSuccess value)? success,
    TResult Function(BusinessFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class BusinessFailure extends BusinessResult {
  const factory BusinessFailure(final String error) = _$BusinessFailureImpl;
  const BusinessFailure._() : super._();

  String get error;

  /// Create a copy of BusinessResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessFailureImplCopyWith<_$BusinessFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ImageUploadResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String imageUrl) success,
    required TResult Function(String error) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String imageUrl)? success,
    TResult? Function(String error)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String imageUrl)? success,
    TResult Function(String error)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ImageUploadSuccess value) success,
    required TResult Function(ImageUploadFailure value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ImageUploadSuccess value)? success,
    TResult? Function(ImageUploadFailure value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ImageUploadSuccess value)? success,
    TResult Function(ImageUploadFailure value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageUploadResultCopyWith<$Res> {
  factory $ImageUploadResultCopyWith(
          ImageUploadResult value, $Res Function(ImageUploadResult) then) =
      _$ImageUploadResultCopyWithImpl<$Res, ImageUploadResult>;
}

/// @nodoc
class _$ImageUploadResultCopyWithImpl<$Res, $Val extends ImageUploadResult>
    implements $ImageUploadResultCopyWith<$Res> {
  _$ImageUploadResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ImageUploadSuccessImplCopyWith<$Res> {
  factory _$$ImageUploadSuccessImplCopyWith(_$ImageUploadSuccessImpl value,
          $Res Function(_$ImageUploadSuccessImpl) then) =
      __$$ImageUploadSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String imageUrl});
}

/// @nodoc
class __$$ImageUploadSuccessImplCopyWithImpl<$Res>
    extends _$ImageUploadResultCopyWithImpl<$Res, _$ImageUploadSuccessImpl>
    implements _$$ImageUploadSuccessImplCopyWith<$Res> {
  __$$ImageUploadSuccessImplCopyWithImpl(_$ImageUploadSuccessImpl _value,
      $Res Function(_$ImageUploadSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageUrl = null,
  }) {
    return _then(_$ImageUploadSuccessImpl(
      null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ImageUploadSuccessImpl extends ImageUploadSuccess {
  const _$ImageUploadSuccessImpl(this.imageUrl) : super._();

  @override
  final String imageUrl;

  @override
  String toString() {
    return 'ImageUploadResult.success(imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageUploadSuccessImpl &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imageUrl);

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageUploadSuccessImplCopyWith<_$ImageUploadSuccessImpl> get copyWith =>
      __$$ImageUploadSuccessImplCopyWithImpl<_$ImageUploadSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String imageUrl) success,
    required TResult Function(String error) failure,
  }) {
    return success(imageUrl);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String imageUrl)? success,
    TResult? Function(String error)? failure,
  }) {
    return success?.call(imageUrl);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String imageUrl)? success,
    TResult Function(String error)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(imageUrl);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ImageUploadSuccess value) success,
    required TResult Function(ImageUploadFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ImageUploadSuccess value)? success,
    TResult? Function(ImageUploadFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ImageUploadSuccess value)? success,
    TResult Function(ImageUploadFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class ImageUploadSuccess extends ImageUploadResult {
  const factory ImageUploadSuccess(final String imageUrl) =
      _$ImageUploadSuccessImpl;
  const ImageUploadSuccess._() : super._();

  String get imageUrl;

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageUploadSuccessImplCopyWith<_$ImageUploadSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ImageUploadFailureImplCopyWith<$Res> {
  factory _$$ImageUploadFailureImplCopyWith(_$ImageUploadFailureImpl value,
          $Res Function(_$ImageUploadFailureImpl) then) =
      __$$ImageUploadFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$ImageUploadFailureImplCopyWithImpl<$Res>
    extends _$ImageUploadResultCopyWithImpl<$Res, _$ImageUploadFailureImpl>
    implements _$$ImageUploadFailureImplCopyWith<$Res> {
  __$$ImageUploadFailureImplCopyWithImpl(_$ImageUploadFailureImpl _value,
      $Res Function(_$ImageUploadFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$ImageUploadFailureImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ImageUploadFailureImpl extends ImageUploadFailure {
  const _$ImageUploadFailureImpl(this.error) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'ImageUploadResult.failure(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageUploadFailureImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageUploadFailureImplCopyWith<_$ImageUploadFailureImpl> get copyWith =>
      __$$ImageUploadFailureImplCopyWithImpl<_$ImageUploadFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String imageUrl) success,
    required TResult Function(String error) failure,
  }) {
    return failure(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String imageUrl)? success,
    TResult? Function(String error)? failure,
  }) {
    return failure?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String imageUrl)? success,
    TResult Function(String error)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ImageUploadSuccess value) success,
    required TResult Function(ImageUploadFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ImageUploadSuccess value)? success,
    TResult? Function(ImageUploadFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ImageUploadSuccess value)? success,
    TResult Function(ImageUploadFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class ImageUploadFailure extends ImageUploadResult {
  const factory ImageUploadFailure(final String error) =
      _$ImageUploadFailureImpl;
  const ImageUploadFailure._() : super._();

  String get error;

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageUploadFailureImplCopyWith<_$ImageUploadFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
