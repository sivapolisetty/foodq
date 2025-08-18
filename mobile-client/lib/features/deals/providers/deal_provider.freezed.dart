// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DealListState {
  List<Deal>? get deals => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Create a copy of DealListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DealListStateCopyWith<DealListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealListStateCopyWith<$Res> {
  factory $DealListStateCopyWith(
          DealListState value, $Res Function(DealListState) then) =
      _$DealListStateCopyWithImpl<$Res, DealListState>;
  @useResult
  $Res call(
      {List<Deal>? deals,
      bool isLoading,
      bool isRefreshing,
      String? error,
      DateTime? lastUpdated});
}

/// @nodoc
class _$DealListStateCopyWithImpl<$Res, $Val extends DealListState>
    implements $DealListStateCopyWith<$Res> {
  _$DealListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DealListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deals = freezed,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? error = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      deals: freezed == deals
          ? _value.deals
          : deals // ignore: cast_nullable_to_non_nullable
              as List<Deal>?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DealListStateImplCopyWith<$Res>
    implements $DealListStateCopyWith<$Res> {
  factory _$$DealListStateImplCopyWith(
          _$DealListStateImpl value, $Res Function(_$DealListStateImpl) then) =
      __$$DealListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Deal>? deals,
      bool isLoading,
      bool isRefreshing,
      String? error,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$DealListStateImplCopyWithImpl<$Res>
    extends _$DealListStateCopyWithImpl<$Res, _$DealListStateImpl>
    implements _$$DealListStateImplCopyWith<$Res> {
  __$$DealListStateImplCopyWithImpl(
      _$DealListStateImpl _value, $Res Function(_$DealListStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of DealListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deals = freezed,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? error = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$DealListStateImpl(
      deals: freezed == deals
          ? _value._deals
          : deals // ignore: cast_nullable_to_non_nullable
              as List<Deal>?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$DealListStateImpl implements _DealListState {
  const _$DealListStateImpl(
      {final List<Deal>? deals,
      this.isLoading = false,
      this.isRefreshing = false,
      this.error,
      this.lastUpdated})
      : _deals = deals;

  final List<Deal>? _deals;
  @override
  List<Deal>? get deals {
    final value = _deals;
    if (value == null) return null;
    if (_deals is EqualUnmodifiableListView) return _deals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isRefreshing;
  @override
  final String? error;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'DealListState(deals: $deals, isLoading: $isLoading, isRefreshing: $isRefreshing, error: $error, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealListStateImpl &&
            const DeepCollectionEquality().equals(other._deals, _deals) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_deals),
      isLoading,
      isRefreshing,
      error,
      lastUpdated);

  /// Create a copy of DealListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealListStateImplCopyWith<_$DealListStateImpl> get copyWith =>
      __$$DealListStateImplCopyWithImpl<_$DealListStateImpl>(this, _$identity);
}

abstract class _DealListState implements DealListState {
  const factory _DealListState(
      {final List<Deal>? deals,
      final bool isLoading,
      final bool isRefreshing,
      final String? error,
      final DateTime? lastUpdated}) = _$DealListStateImpl;

  @override
  List<Deal>? get deals;
  @override
  bool get isLoading;
  @override
  bool get isRefreshing;
  @override
  String? get error;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of DealListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealListStateImplCopyWith<_$DealListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
