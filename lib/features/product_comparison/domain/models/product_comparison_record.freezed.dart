// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_comparison_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductComparisonRecord {

 String get id; DateTime get timestamp; String get rawJsonResult; String get imagePath;
/// Create a copy of ProductComparisonRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductComparisonRecordCopyWith<ProductComparisonRecord> get copyWith => _$ProductComparisonRecordCopyWithImpl<ProductComparisonRecord>(this as ProductComparisonRecord, _$identity);

  /// Serializes this ProductComparisonRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductComparisonRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.rawJsonResult, rawJsonResult) || other.rawJsonResult == rawJsonResult)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,rawJsonResult,imagePath);

@override
String toString() {
  return 'ProductComparisonRecord(id: $id, timestamp: $timestamp, rawJsonResult: $rawJsonResult, imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class $ProductComparisonRecordCopyWith<$Res>  {
  factory $ProductComparisonRecordCopyWith(ProductComparisonRecord value, $Res Function(ProductComparisonRecord) _then) = _$ProductComparisonRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime timestamp, String rawJsonResult, String imagePath
});




}
/// @nodoc
class _$ProductComparisonRecordCopyWithImpl<$Res>
    implements $ProductComparisonRecordCopyWith<$Res> {
  _$ProductComparisonRecordCopyWithImpl(this._self, this._then);

  final ProductComparisonRecord _self;
  final $Res Function(ProductComparisonRecord) _then;

/// Create a copy of ProductComparisonRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? timestamp = null,Object? rawJsonResult = null,Object? imagePath = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,rawJsonResult: null == rawJsonResult ? _self.rawJsonResult : rawJsonResult // ignore: cast_nullable_to_non_nullable
as String,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductComparisonRecord].
extension ProductComparisonRecordPatterns on ProductComparisonRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductComparisonRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductComparisonRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductComparisonRecord value)  $default,){
final _that = this;
switch (_that) {
case _ProductComparisonRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductComparisonRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ProductComparisonRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String rawJsonResult,  String imagePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductComparisonRecord() when $default != null:
return $default(_that.id,_that.timestamp,_that.rawJsonResult,_that.imagePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String rawJsonResult,  String imagePath)  $default,) {final _that = this;
switch (_that) {
case _ProductComparisonRecord():
return $default(_that.id,_that.timestamp,_that.rawJsonResult,_that.imagePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime timestamp,  String rawJsonResult,  String imagePath)?  $default,) {final _that = this;
switch (_that) {
case _ProductComparisonRecord() when $default != null:
return $default(_that.id,_that.timestamp,_that.rawJsonResult,_that.imagePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductComparisonRecord extends ProductComparisonRecord {
  const _ProductComparisonRecord({required this.id, required this.timestamp, required this.rawJsonResult, required this.imagePath}): super._();
  factory _ProductComparisonRecord.fromJson(Map<String, dynamic> json) => _$ProductComparisonRecordFromJson(json);

@override final  String id;
@override final  DateTime timestamp;
@override final  String rawJsonResult;
@override final  String imagePath;

/// Create a copy of ProductComparisonRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductComparisonRecordCopyWith<_ProductComparisonRecord> get copyWith => __$ProductComparisonRecordCopyWithImpl<_ProductComparisonRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductComparisonRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductComparisonRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.rawJsonResult, rawJsonResult) || other.rawJsonResult == rawJsonResult)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,rawJsonResult,imagePath);

@override
String toString() {
  return 'ProductComparisonRecord(id: $id, timestamp: $timestamp, rawJsonResult: $rawJsonResult, imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class _$ProductComparisonRecordCopyWith<$Res> implements $ProductComparisonRecordCopyWith<$Res> {
  factory _$ProductComparisonRecordCopyWith(_ProductComparisonRecord value, $Res Function(_ProductComparisonRecord) _then) = __$ProductComparisonRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime timestamp, String rawJsonResult, String imagePath
});




}
/// @nodoc
class __$ProductComparisonRecordCopyWithImpl<$Res>
    implements _$ProductComparisonRecordCopyWith<$Res> {
  __$ProductComparisonRecordCopyWithImpl(this._self, this._then);

  final _ProductComparisonRecord _self;
  final $Res Function(_ProductComparisonRecord) _then;

/// Create a copy of ProductComparisonRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? timestamp = null,Object? rawJsonResult = null,Object? imagePath = null,}) {
  return _then(_ProductComparisonRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,rawJsonResult: null == rawJsonResult ? _self.rawJsonResult : rawJsonResult // ignore: cast_nullable_to_non_nullable
as String,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
