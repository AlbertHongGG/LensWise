// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoiceState {

 bool get isListening; bool get hasError; String get recognizedText;
/// Create a copy of VoiceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceStateCopyWith<VoiceState> get copyWith => _$VoiceStateCopyWithImpl<VoiceState>(this as VoiceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceState&&(identical(other.isListening, isListening) || other.isListening == isListening)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&(identical(other.recognizedText, recognizedText) || other.recognizedText == recognizedText));
}


@override
int get hashCode => Object.hash(runtimeType,isListening,hasError,recognizedText);

@override
String toString() {
  return 'VoiceState(isListening: $isListening, hasError: $hasError, recognizedText: $recognizedText)';
}


}

/// @nodoc
abstract mixin class $VoiceStateCopyWith<$Res>  {
  factory $VoiceStateCopyWith(VoiceState value, $Res Function(VoiceState) _then) = _$VoiceStateCopyWithImpl;
@useResult
$Res call({
 bool isListening, bool hasError, String recognizedText
});




}
/// @nodoc
class _$VoiceStateCopyWithImpl<$Res>
    implements $VoiceStateCopyWith<$Res> {
  _$VoiceStateCopyWithImpl(this._self, this._then);

  final VoiceState _self;
  final $Res Function(VoiceState) _then;

/// Create a copy of VoiceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isListening = null,Object? hasError = null,Object? recognizedText = null,}) {
  return _then(_self.copyWith(
isListening: null == isListening ? _self.isListening : isListening // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,recognizedText: null == recognizedText ? _self.recognizedText : recognizedText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceState].
extension VoiceStatePatterns on VoiceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceState value)  $default,){
final _that = this;
switch (_that) {
case _VoiceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceState value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isListening,  bool hasError,  String recognizedText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceState() when $default != null:
return $default(_that.isListening,_that.hasError,_that.recognizedText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isListening,  bool hasError,  String recognizedText)  $default,) {final _that = this;
switch (_that) {
case _VoiceState():
return $default(_that.isListening,_that.hasError,_that.recognizedText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isListening,  bool hasError,  String recognizedText)?  $default,) {final _that = this;
switch (_that) {
case _VoiceState() when $default != null:
return $default(_that.isListening,_that.hasError,_that.recognizedText);case _:
  return null;

}
}

}

/// @nodoc


class _VoiceState implements VoiceState {
  const _VoiceState({this.isListening = false, this.hasError = false, this.recognizedText = ''});
  

@override@JsonKey() final  bool isListening;
@override@JsonKey() final  bool hasError;
@override@JsonKey() final  String recognizedText;

/// Create a copy of VoiceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceStateCopyWith<_VoiceState> get copyWith => __$VoiceStateCopyWithImpl<_VoiceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceState&&(identical(other.isListening, isListening) || other.isListening == isListening)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&(identical(other.recognizedText, recognizedText) || other.recognizedText == recognizedText));
}


@override
int get hashCode => Object.hash(runtimeType,isListening,hasError,recognizedText);

@override
String toString() {
  return 'VoiceState(isListening: $isListening, hasError: $hasError, recognizedText: $recognizedText)';
}


}

/// @nodoc
abstract mixin class _$VoiceStateCopyWith<$Res> implements $VoiceStateCopyWith<$Res> {
  factory _$VoiceStateCopyWith(_VoiceState value, $Res Function(_VoiceState) _then) = __$VoiceStateCopyWithImpl;
@override @useResult
$Res call({
 bool isListening, bool hasError, String recognizedText
});




}
/// @nodoc
class __$VoiceStateCopyWithImpl<$Res>
    implements _$VoiceStateCopyWith<$Res> {
  __$VoiceStateCopyWithImpl(this._self, this._then);

  final _VoiceState _self;
  final $Res Function(_VoiceState) _then;

/// Create a copy of VoiceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isListening = null,Object? hasError = null,Object? recognizedText = null,}) {
  return _then(_VoiceState(
isListening: null == isListening ? _self.isListening : isListening // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,recognizedText: null == recognizedText ? _self.recognizedText : recognizedText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
