// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'barakah_review_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BarakahReviewState {

 BarakahReviewWeek get week;
/// Create a copy of BarakahReviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BarakahReviewStateCopyWith<BarakahReviewState> get copyWith => _$BarakahReviewStateCopyWithImpl<BarakahReviewState>(this as BarakahReviewState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BarakahReviewState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BarakahReviewState&&(identical(other.week, _this.week) || other.week == _this.week));
}


@override
int get hashCode {
  final _this = this as BarakahReviewState;
  return Object.hash(runtimeType,_this.week);
}

@override
String toString() {
  final _this = this as BarakahReviewState;
  return 'BarakahReviewState(week: ${_this.week})';
}


}

/// @nodoc
abstract mixin class $BarakahReviewStateCopyWith<$Res>  {
  factory $BarakahReviewStateCopyWith(BarakahReviewState value, $Res Function(BarakahReviewState) _then) = _$BarakahReviewStateCopyWithImpl;
@useResult
$Res call({
 BarakahReviewWeek week
});




}
/// @nodoc
class _$BarakahReviewStateCopyWithImpl<$Res>
    implements $BarakahReviewStateCopyWith<$Res> {
  _$BarakahReviewStateCopyWithImpl(this._self, this._then);

  final BarakahReviewState _self;
  final $Res Function(BarakahReviewState) _then;

/// Create a copy of BarakahReviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? week = null,}) {
  return _then(_self.copyWith(
week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as BarakahReviewWeek,
  ));
}

}


/// Adds pattern-matching-related methods to [BarakahReviewState].
extension BarakahReviewStatePatterns on BarakahReviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BarakahReviewLoading value)?  loading,TResult Function( BarakahReviewLoaded value)?  loaded,TResult Function( BarakahReviewFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BarakahReviewLoading() when loading != null:
return loading(_that);case BarakahReviewLoaded() when loaded != null:
return loaded(_that);case BarakahReviewFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BarakahReviewLoading value)  loading,required TResult Function( BarakahReviewLoaded value)  loaded,required TResult Function( BarakahReviewFailure value)  failure,}){
final _that = this;
switch (_that) {
case BarakahReviewLoading():
return loading(_that);case BarakahReviewLoaded():
return loaded(_that);case BarakahReviewFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BarakahReviewLoading value)?  loading,TResult? Function( BarakahReviewLoaded value)?  loaded,TResult? Function( BarakahReviewFailure value)?  failure,}){
final _that = this;
switch (_that) {
case BarakahReviewLoading() when loading != null:
return loading(_that);case BarakahReviewLoaded() when loaded != null:
return loaded(_that);case BarakahReviewFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( BarakahReviewWeek week)?  loading,TResult Function( BarakahReviewWeek week,  BarakahWeeklyReview review)?  loaded,TResult Function( BarakahReviewWeek week)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BarakahReviewLoading() when loading != null:
return loading(_that.week);case BarakahReviewLoaded() when loaded != null:
return loaded(_that.week,_that.review);case BarakahReviewFailure() when failure != null:
return failure(_that.week);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( BarakahReviewWeek week)  loading,required TResult Function( BarakahReviewWeek week,  BarakahWeeklyReview review)  loaded,required TResult Function( BarakahReviewWeek week)  failure,}) {final _that = this;
switch (_that) {
case BarakahReviewLoading():
return loading(_that.week);case BarakahReviewLoaded():
return loaded(_that.week,_that.review);case BarakahReviewFailure():
return failure(_that.week);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( BarakahReviewWeek week)?  loading,TResult? Function( BarakahReviewWeek week,  BarakahWeeklyReview review)?  loaded,TResult? Function( BarakahReviewWeek week)?  failure,}) {final _that = this;
switch (_that) {
case BarakahReviewLoading() when loading != null:
return loading(_that.week);case BarakahReviewLoaded() when loaded != null:
return loaded(_that.week,_that.review);case BarakahReviewFailure() when failure != null:
return failure(_that.week);case _:
  return null;

}
}

}

/// @nodoc


class BarakahReviewLoading implements BarakahReviewState {
  const BarakahReviewLoading(this.week);
  

@override final  BarakahReviewWeek week;

/// Create a copy of BarakahReviewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BarakahReviewLoadingCopyWith<BarakahReviewLoading> get copyWith => _$BarakahReviewLoadingCopyWithImpl<BarakahReviewLoading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BarakahReviewLoading&&(identical(other.week, week) || other.week == week));
}


@override
int get hashCode {
    return Object.hash(runtimeType,week);
}

@override
String toString() {
    return 'BarakahReviewState.loading(week: $week)';
}


}

/// @nodoc
abstract mixin class $BarakahReviewLoadingCopyWith<$Res> implements $BarakahReviewStateCopyWith<$Res> {
  factory $BarakahReviewLoadingCopyWith(BarakahReviewLoading value, $Res Function(BarakahReviewLoading) _then) = _$BarakahReviewLoadingCopyWithImpl;
@override @useResult
$Res call({
 BarakahReviewWeek week
});




}
/// @nodoc
class _$BarakahReviewLoadingCopyWithImpl<$Res>
    implements $BarakahReviewLoadingCopyWith<$Res> {
  _$BarakahReviewLoadingCopyWithImpl(this._self, this._then);

  final BarakahReviewLoading _self;
  final $Res Function(BarakahReviewLoading) _then;

/// Create a copy of BarakahReviewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? week = null,}) {
  return _then(BarakahReviewLoading(
null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as BarakahReviewWeek,
  ));
}


}

/// @nodoc


class BarakahReviewLoaded implements BarakahReviewState {
  const BarakahReviewLoaded(this.week, this.review);
  

@override final  BarakahReviewWeek week;
 final  BarakahWeeklyReview review;

/// Create a copy of BarakahReviewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BarakahReviewLoadedCopyWith<BarakahReviewLoaded> get copyWith => _$BarakahReviewLoadedCopyWithImpl<BarakahReviewLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BarakahReviewLoaded&&(identical(other.week, week) || other.week == week)&&(identical(other.review, review) || other.review == review));
}


@override
int get hashCode {
    return Object.hash(runtimeType,week,review);
}

@override
String toString() {
    return 'BarakahReviewState.loaded(week: $week, review: $review)';
}


}

/// @nodoc
abstract mixin class $BarakahReviewLoadedCopyWith<$Res> implements $BarakahReviewStateCopyWith<$Res> {
  factory $BarakahReviewLoadedCopyWith(BarakahReviewLoaded value, $Res Function(BarakahReviewLoaded) _then) = _$BarakahReviewLoadedCopyWithImpl;
@override @useResult
$Res call({
 BarakahReviewWeek week, BarakahWeeklyReview review
});




}
/// @nodoc
class _$BarakahReviewLoadedCopyWithImpl<$Res>
    implements $BarakahReviewLoadedCopyWith<$Res> {
  _$BarakahReviewLoadedCopyWithImpl(this._self, this._then);

  final BarakahReviewLoaded _self;
  final $Res Function(BarakahReviewLoaded) _then;

/// Create a copy of BarakahReviewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? week = null,Object? review = null,}) {
  return _then(BarakahReviewLoaded(
null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as BarakahReviewWeek,null == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as BarakahWeeklyReview,
  ));
}


}

/// @nodoc


class BarakahReviewFailure implements BarakahReviewState {
  const BarakahReviewFailure(this.week);
  

@override final  BarakahReviewWeek week;

/// Create a copy of BarakahReviewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BarakahReviewFailureCopyWith<BarakahReviewFailure> get copyWith => _$BarakahReviewFailureCopyWithImpl<BarakahReviewFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BarakahReviewFailure&&(identical(other.week, week) || other.week == week));
}


@override
int get hashCode {
    return Object.hash(runtimeType,week);
}

@override
String toString() {
    return 'BarakahReviewState.failure(week: $week)';
}


}

/// @nodoc
abstract mixin class $BarakahReviewFailureCopyWith<$Res> implements $BarakahReviewStateCopyWith<$Res> {
  factory $BarakahReviewFailureCopyWith(BarakahReviewFailure value, $Res Function(BarakahReviewFailure) _then) = _$BarakahReviewFailureCopyWithImpl;
@override @useResult
$Res call({
 BarakahReviewWeek week
});




}
/// @nodoc
class _$BarakahReviewFailureCopyWithImpl<$Res>
    implements $BarakahReviewFailureCopyWith<$Res> {
  _$BarakahReviewFailureCopyWithImpl(this._self, this._then);

  final BarakahReviewFailure _self;
  final $Res Function(BarakahReviewFailure) _then;

/// Create a copy of BarakahReviewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? week = null,}) {
  return _then(BarakahReviewFailure(
null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as BarakahReviewWeek,
  ));
}


}

// dart format on
