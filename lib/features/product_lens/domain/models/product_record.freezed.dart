// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductRecord {

 String get id; DateTime get timestamp; String get productName; String get originalName; String get brand; String get origin; String get summary; List<String> get ingredients; List<String> get allergenAlerts; List<String> get dietaryFlags; List<String> get whenRecommended; List<String> get whenNotRecommended; List<String> get imagePaths;
/// Create a copy of ProductRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductRecordCopyWith<ProductRecord> get copyWith => _$ProductRecordCopyWithImpl<ProductRecord>(this as ProductRecord, _$identity);

  /// Serializes this ProductRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.ingredients, ingredients)&&const DeepCollectionEquality().equals(other.allergenAlerts, allergenAlerts)&&const DeepCollectionEquality().equals(other.dietaryFlags, dietaryFlags)&&const DeepCollectionEquality().equals(other.whenRecommended, whenRecommended)&&const DeepCollectionEquality().equals(other.whenNotRecommended, whenNotRecommended)&&const DeepCollectionEquality().equals(other.imagePaths, imagePaths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,productName,originalName,brand,origin,summary,const DeepCollectionEquality().hash(ingredients),const DeepCollectionEquality().hash(allergenAlerts),const DeepCollectionEquality().hash(dietaryFlags),const DeepCollectionEquality().hash(whenRecommended),const DeepCollectionEquality().hash(whenNotRecommended),const DeepCollectionEquality().hash(imagePaths));

@override
String toString() {
  return 'ProductRecord(id: $id, timestamp: $timestamp, productName: $productName, originalName: $originalName, brand: $brand, origin: $origin, summary: $summary, ingredients: $ingredients, allergenAlerts: $allergenAlerts, dietaryFlags: $dietaryFlags, whenRecommended: $whenRecommended, whenNotRecommended: $whenNotRecommended, imagePaths: $imagePaths)';
}


}

/// @nodoc
abstract mixin class $ProductRecordCopyWith<$Res>  {
  factory $ProductRecordCopyWith(ProductRecord value, $Res Function(ProductRecord) _then) = _$ProductRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime timestamp, String productName, String originalName, String brand, String origin, String summary, List<String> ingredients, List<String> allergenAlerts, List<String> dietaryFlags, List<String> whenRecommended, List<String> whenNotRecommended, List<String> imagePaths
});




}
/// @nodoc
class _$ProductRecordCopyWithImpl<$Res>
    implements $ProductRecordCopyWith<$Res> {
  _$ProductRecordCopyWithImpl(this._self, this._then);

  final ProductRecord _self;
  final $Res Function(ProductRecord) _then;

/// Create a copy of ProductRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? timestamp = null,Object? productName = null,Object? originalName = null,Object? brand = null,Object? origin = null,Object? summary = null,Object? ingredients = null,Object? allergenAlerts = null,Object? dietaryFlags = null,Object? whenRecommended = null,Object? whenNotRecommended = null,Object? imagePaths = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,allergenAlerts: null == allergenAlerts ? _self.allergenAlerts : allergenAlerts // ignore: cast_nullable_to_non_nullable
as List<String>,dietaryFlags: null == dietaryFlags ? _self.dietaryFlags : dietaryFlags // ignore: cast_nullable_to_non_nullable
as List<String>,whenRecommended: null == whenRecommended ? _self.whenRecommended : whenRecommended // ignore: cast_nullable_to_non_nullable
as List<String>,whenNotRecommended: null == whenNotRecommended ? _self.whenNotRecommended : whenNotRecommended // ignore: cast_nullable_to_non_nullable
as List<String>,imagePaths: null == imagePaths ? _self.imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductRecord].
extension ProductRecordPatterns on ProductRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductRecord value)  $default,){
final _that = this;
switch (_that) {
case _ProductRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ProductRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String productName,  String originalName,  String brand,  String origin,  String summary,  List<String> ingredients,  List<String> allergenAlerts,  List<String> dietaryFlags,  List<String> whenRecommended,  List<String> whenNotRecommended,  List<String> imagePaths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductRecord() when $default != null:
return $default(_that.id,_that.timestamp,_that.productName,_that.originalName,_that.brand,_that.origin,_that.summary,_that.ingredients,_that.allergenAlerts,_that.dietaryFlags,_that.whenRecommended,_that.whenNotRecommended,_that.imagePaths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String productName,  String originalName,  String brand,  String origin,  String summary,  List<String> ingredients,  List<String> allergenAlerts,  List<String> dietaryFlags,  List<String> whenRecommended,  List<String> whenNotRecommended,  List<String> imagePaths)  $default,) {final _that = this;
switch (_that) {
case _ProductRecord():
return $default(_that.id,_that.timestamp,_that.productName,_that.originalName,_that.brand,_that.origin,_that.summary,_that.ingredients,_that.allergenAlerts,_that.dietaryFlags,_that.whenRecommended,_that.whenNotRecommended,_that.imagePaths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime timestamp,  String productName,  String originalName,  String brand,  String origin,  String summary,  List<String> ingredients,  List<String> allergenAlerts,  List<String> dietaryFlags,  List<String> whenRecommended,  List<String> whenNotRecommended,  List<String> imagePaths)?  $default,) {final _that = this;
switch (_that) {
case _ProductRecord() when $default != null:
return $default(_that.id,_that.timestamp,_that.productName,_that.originalName,_that.brand,_that.origin,_that.summary,_that.ingredients,_that.allergenAlerts,_that.dietaryFlags,_that.whenRecommended,_that.whenNotRecommended,_that.imagePaths);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductRecord extends ProductRecord {
  const _ProductRecord({required this.id, required this.timestamp, required this.productName, required this.originalName, required this.brand, required this.origin, required this.summary, required final  List<String> ingredients, required final  List<String> allergenAlerts, required final  List<String> dietaryFlags, required final  List<String> whenRecommended, required final  List<String> whenNotRecommended, final  List<String> imagePaths = const []}): _ingredients = ingredients,_allergenAlerts = allergenAlerts,_dietaryFlags = dietaryFlags,_whenRecommended = whenRecommended,_whenNotRecommended = whenNotRecommended,_imagePaths = imagePaths,super._();
  factory _ProductRecord.fromJson(Map<String, dynamic> json) => _$ProductRecordFromJson(json);

@override final  String id;
@override final  DateTime timestamp;
@override final  String productName;
@override final  String originalName;
@override final  String brand;
@override final  String origin;
@override final  String summary;
 final  List<String> _ingredients;
@override List<String> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

 final  List<String> _allergenAlerts;
@override List<String> get allergenAlerts {
  if (_allergenAlerts is EqualUnmodifiableListView) return _allergenAlerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergenAlerts);
}

 final  List<String> _dietaryFlags;
@override List<String> get dietaryFlags {
  if (_dietaryFlags is EqualUnmodifiableListView) return _dietaryFlags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietaryFlags);
}

 final  List<String> _whenRecommended;
@override List<String> get whenRecommended {
  if (_whenRecommended is EqualUnmodifiableListView) return _whenRecommended;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_whenRecommended);
}

 final  List<String> _whenNotRecommended;
@override List<String> get whenNotRecommended {
  if (_whenNotRecommended is EqualUnmodifiableListView) return _whenNotRecommended;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_whenNotRecommended);
}

 final  List<String> _imagePaths;
@override@JsonKey() List<String> get imagePaths {
  if (_imagePaths is EqualUnmodifiableListView) return _imagePaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagePaths);
}


/// Create a copy of ProductRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductRecordCopyWith<_ProductRecord> get copyWith => __$ProductRecordCopyWithImpl<_ProductRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients)&&const DeepCollectionEquality().equals(other._allergenAlerts, _allergenAlerts)&&const DeepCollectionEquality().equals(other._dietaryFlags, _dietaryFlags)&&const DeepCollectionEquality().equals(other._whenRecommended, _whenRecommended)&&const DeepCollectionEquality().equals(other._whenNotRecommended, _whenNotRecommended)&&const DeepCollectionEquality().equals(other._imagePaths, _imagePaths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,productName,originalName,brand,origin,summary,const DeepCollectionEquality().hash(_ingredients),const DeepCollectionEquality().hash(_allergenAlerts),const DeepCollectionEquality().hash(_dietaryFlags),const DeepCollectionEquality().hash(_whenRecommended),const DeepCollectionEquality().hash(_whenNotRecommended),const DeepCollectionEquality().hash(_imagePaths));

@override
String toString() {
  return 'ProductRecord(id: $id, timestamp: $timestamp, productName: $productName, originalName: $originalName, brand: $brand, origin: $origin, summary: $summary, ingredients: $ingredients, allergenAlerts: $allergenAlerts, dietaryFlags: $dietaryFlags, whenRecommended: $whenRecommended, whenNotRecommended: $whenNotRecommended, imagePaths: $imagePaths)';
}


}

/// @nodoc
abstract mixin class _$ProductRecordCopyWith<$Res> implements $ProductRecordCopyWith<$Res> {
  factory _$ProductRecordCopyWith(_ProductRecord value, $Res Function(_ProductRecord) _then) = __$ProductRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime timestamp, String productName, String originalName, String brand, String origin, String summary, List<String> ingredients, List<String> allergenAlerts, List<String> dietaryFlags, List<String> whenRecommended, List<String> whenNotRecommended, List<String> imagePaths
});




}
/// @nodoc
class __$ProductRecordCopyWithImpl<$Res>
    implements _$ProductRecordCopyWith<$Res> {
  __$ProductRecordCopyWithImpl(this._self, this._then);

  final _ProductRecord _self;
  final $Res Function(_ProductRecord) _then;

/// Create a copy of ProductRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? timestamp = null,Object? productName = null,Object? originalName = null,Object? brand = null,Object? origin = null,Object? summary = null,Object? ingredients = null,Object? allergenAlerts = null,Object? dietaryFlags = null,Object? whenRecommended = null,Object? whenNotRecommended = null,Object? imagePaths = null,}) {
  return _then(_ProductRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,allergenAlerts: null == allergenAlerts ? _self._allergenAlerts : allergenAlerts // ignore: cast_nullable_to_non_nullable
as List<String>,dietaryFlags: null == dietaryFlags ? _self._dietaryFlags : dietaryFlags // ignore: cast_nullable_to_non_nullable
as List<String>,whenRecommended: null == whenRecommended ? _self._whenRecommended : whenRecommended // ignore: cast_nullable_to_non_nullable
as List<String>,whenNotRecommended: null == whenNotRecommended ? _self._whenNotRecommended : whenNotRecommended // ignore: cast_nullable_to_non_nullable
as List<String>,imagePaths: null == imagePaths ? _self._imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
