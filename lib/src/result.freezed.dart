// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Result<T, E extends Exception> {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Result<T, E>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Result<$T, $E>()';
  }
}

/// @nodoc
class $ResultCopyWith<T, E extends Exception, $Res> {
  $ResultCopyWith(Result<T, E> _, $Res Function(Result<T, E>) __);
}

/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<T, E extends Exception> on Result<T, E> {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Ok<T, E> value)? ok,
    TResult Function(Err<T, E> value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case Ok() when ok != null:
        return ok(_that);
      case Err() when error != null:
        return error(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Ok<T, E> value) ok,
    required TResult Function(Err<T, E> value) error,
  }) {
    final _that = this;
    switch (_that) {
      case Ok():
        return ok(_that);
      case Err():
        return error(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Ok<T, E> value)? ok,
    TResult? Function(Err<T, E> value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case Ok() when ok != null:
        return ok(_that);
      case Err() when error != null:
        return error(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? ok,
    TResult Function(E error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case Ok() when ok != null:
        return ok(_that.data);
      case Err() when error != null:
        return error(_that.error);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) ok,
    required TResult Function(E error) error,
  }) {
    final _that = this;
    switch (_that) {
      case Ok():
        return ok(_that.data);
      case Err():
        return error(_that.error);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? ok,
    TResult? Function(E error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case Ok() when ok != null:
        return ok(_that.data);
      case Err() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class Ok<T, E extends Exception> extends Result<T, E> {
  const Ok(this.data) : super._();

  final T data;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OkCopyWith<T, E, Ok<T, E>> get copyWith =>
      _$OkCopyWithImpl<T, E, Ok<T, E>>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Ok<T, E> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'Result<$T, $E>.ok(data: $data)';
  }
}

/// @nodoc
abstract mixin class $OkCopyWith<T, E extends Exception, $Res>
    implements $ResultCopyWith<T, E, $Res> {
  factory $OkCopyWith(Ok<T, E> value, $Res Function(Ok<T, E>) _then) =
      _$OkCopyWithImpl;
  @useResult
  $Res call({T data});
}

/// @nodoc
class _$OkCopyWithImpl<T, E extends Exception, $Res>
    implements $OkCopyWith<T, E, $Res> {
  _$OkCopyWithImpl(this._self, this._then);

  final Ok<T, E> _self;
  final $Res Function(Ok<T, E>) _then;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = freezed,
  }) {
    return _then(Ok<T, E>(
      freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class Err<T, E extends Exception> extends Result<T, E> {
  const Err(this.error) : super._();

  final E error;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ErrCopyWith<T, E, Err<T, E>> get copyWith =>
      _$ErrCopyWithImpl<T, E, Err<T, E>>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Err<T, E> &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(error));

  @override
  String toString() {
    return 'Result<$T, $E>.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $ErrCopyWith<T, E extends Exception, $Res>
    implements $ResultCopyWith<T, E, $Res> {
  factory $ErrCopyWith(Err<T, E> value, $Res Function(Err<T, E>) _then) =
      _$ErrCopyWithImpl;
  @useResult
  $Res call({E error});
}

/// @nodoc
class _$ErrCopyWithImpl<T, E extends Exception, $Res>
    implements $ErrCopyWith<T, E, $Res> {
  _$ErrCopyWithImpl(this._self, this._then);

  final Err<T, E> _self;
  final $Res Function(Err<T, E>) _then;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(Err<T, E>(
      null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as E,
    ));
  }
}

// dart format on
