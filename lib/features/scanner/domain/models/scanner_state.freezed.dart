// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scanner_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScannerState {

 ScannerMode get currentMode; List<AppImageEntity> get capturedImages; CameraActionState get actionState;
/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScannerStateCopyWith<ScannerState> get copyWith => _$ScannerStateCopyWithImpl<ScannerState>(this as ScannerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScannerState&&(identical(other.currentMode, currentMode) || other.currentMode == currentMode)&&const DeepCollectionEquality().equals(other.capturedImages, capturedImages)&&(identical(other.actionState, actionState) || other.actionState == actionState));
}


@override
int get hashCode => Object.hash(runtimeType,currentMode,const DeepCollectionEquality().hash(capturedImages),actionState);

@override
String toString() {
  return 'ScannerState(currentMode: $currentMode, capturedImages: $capturedImages, actionState: $actionState)';
}


}

/// @nodoc
abstract mixin class $ScannerStateCopyWith<$Res>  {
  factory $ScannerStateCopyWith(ScannerState value, $Res Function(ScannerState) _then) = _$ScannerStateCopyWithImpl;
@useResult
$Res call({
 ScannerMode currentMode, List<AppImageEntity> capturedImages, CameraActionState actionState
});




}
/// @nodoc
class _$ScannerStateCopyWithImpl<$Res>
    implements $ScannerStateCopyWith<$Res> {
  _$ScannerStateCopyWithImpl(this._self, this._then);

  final ScannerState _self;
  final $Res Function(ScannerState) _then;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentMode = null,Object? capturedImages = null,Object? actionState = null,}) {
  return _then(_self.copyWith(
currentMode: null == currentMode ? _self.currentMode : currentMode // ignore: cast_nullable_to_non_nullable
as ScannerMode,capturedImages: null == capturedImages ? _self.capturedImages : capturedImages // ignore: cast_nullable_to_non_nullable
as List<AppImageEntity>,actionState: null == actionState ? _self.actionState : actionState // ignore: cast_nullable_to_non_nullable
as CameraActionState,
  ));
}

}


/// Adds pattern-matching-related methods to [ScannerState].
extension ScannerStatePatterns on ScannerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScannerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScannerState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScannerState value)  $default,){
final _that = this;
switch (_that) {
case _ScannerState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScannerState value)?  $default,){
final _that = this;
switch (_that) {
case _ScannerState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ScannerMode currentMode,  List<AppImageEntity> capturedImages,  CameraActionState actionState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScannerState() when $default != null:
return $default(_that.currentMode,_that.capturedImages,_that.actionState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ScannerMode currentMode,  List<AppImageEntity> capturedImages,  CameraActionState actionState)  $default,) {final _that = this;
switch (_that) {
case _ScannerState():
return $default(_that.currentMode,_that.capturedImages,_that.actionState);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ScannerMode currentMode,  List<AppImageEntity> capturedImages,  CameraActionState actionState)?  $default,) {final _that = this;
switch (_that) {
case _ScannerState() when $default != null:
return $default(_that.currentMode,_that.capturedImages,_that.actionState);case _:
  return null;

}
}

}

/// @nodoc


class _ScannerState extends ScannerState {
  const _ScannerState({this.currentMode = ScannerMode.product, final  List<AppImageEntity> capturedImages = const [], this.actionState = CameraActionState.idle}): _capturedImages = capturedImages,super._();
  

@override@JsonKey() final  ScannerMode currentMode;
 final  List<AppImageEntity> _capturedImages;
@override@JsonKey() List<AppImageEntity> get capturedImages {
  if (_capturedImages is EqualUnmodifiableListView) return _capturedImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_capturedImages);
}

@override@JsonKey() final  CameraActionState actionState;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScannerStateCopyWith<_ScannerState> get copyWith => __$ScannerStateCopyWithImpl<_ScannerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScannerState&&(identical(other.currentMode, currentMode) || other.currentMode == currentMode)&&const DeepCollectionEquality().equals(other._capturedImages, _capturedImages)&&(identical(other.actionState, actionState) || other.actionState == actionState));
}


@override
int get hashCode => Object.hash(runtimeType,currentMode,const DeepCollectionEquality().hash(_capturedImages),actionState);

@override
String toString() {
  return 'ScannerState(currentMode: $currentMode, capturedImages: $capturedImages, actionState: $actionState)';
}


}

/// @nodoc
abstract mixin class _$ScannerStateCopyWith<$Res> implements $ScannerStateCopyWith<$Res> {
  factory _$ScannerStateCopyWith(_ScannerState value, $Res Function(_ScannerState) _then) = __$ScannerStateCopyWithImpl;
@override @useResult
$Res call({
 ScannerMode currentMode, List<AppImageEntity> capturedImages, CameraActionState actionState
});




}
/// @nodoc
class __$ScannerStateCopyWithImpl<$Res>
    implements _$ScannerStateCopyWith<$Res> {
  __$ScannerStateCopyWithImpl(this._self, this._then);

  final _ScannerState _self;
  final $Res Function(_ScannerState) _then;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentMode = null,Object? capturedImages = null,Object? actionState = null,}) {
  return _then(_ScannerState(
currentMode: null == currentMode ? _self.currentMode : currentMode // ignore: cast_nullable_to_non_nullable
as ScannerMode,capturedImages: null == capturedImages ? _self._capturedImages : capturedImages // ignore: cast_nullable_to_non_nullable
as List<AppImageEntity>,actionState: null == actionState ? _self.actionState : actionState // ignore: cast_nullable_to_non_nullable
as CameraActionState,
  ));
}


}

// dart format on
