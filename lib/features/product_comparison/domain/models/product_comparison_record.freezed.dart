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

 String get id; DateTime get timestamp; String get title; String get summary; List<ComparisonProduct> get products; List<ComparisonPoint> get comparisonPoints; String get imagePath;
/// Create a copy of ProductComparisonRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductComparisonRecordCopyWith<ProductComparisonRecord> get copyWith => _$ProductComparisonRecordCopyWithImpl<ProductComparisonRecord>(this as ProductComparisonRecord, _$identity);

  /// Serializes this ProductComparisonRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductComparisonRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.products, products)&&const DeepCollectionEquality().equals(other.comparisonPoints, comparisonPoints)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,title,summary,const DeepCollectionEquality().hash(products),const DeepCollectionEquality().hash(comparisonPoints),imagePath);

@override
String toString() {
  return 'ProductComparisonRecord(id: $id, timestamp: $timestamp, title: $title, summary: $summary, products: $products, comparisonPoints: $comparisonPoints, imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class $ProductComparisonRecordCopyWith<$Res>  {
  factory $ProductComparisonRecordCopyWith(ProductComparisonRecord value, $Res Function(ProductComparisonRecord) _then) = _$ProductComparisonRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime timestamp, String title, String summary, List<ComparisonProduct> products, List<ComparisonPoint> comparisonPoints, String imagePath
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? timestamp = null,Object? title = null,Object? summary = null,Object? products = null,Object? comparisonPoints = null,Object? imagePath = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<ComparisonProduct>,comparisonPoints: null == comparisonPoints ? _self.comparisonPoints : comparisonPoints // ignore: cast_nullable_to_non_nullable
as List<ComparisonPoint>,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String title,  String summary,  List<ComparisonProduct> products,  List<ComparisonPoint> comparisonPoints,  String imagePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductComparisonRecord() when $default != null:
return $default(_that.id,_that.timestamp,_that.title,_that.summary,_that.products,_that.comparisonPoints,_that.imagePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String title,  String summary,  List<ComparisonProduct> products,  List<ComparisonPoint> comparisonPoints,  String imagePath)  $default,) {final _that = this;
switch (_that) {
case _ProductComparisonRecord():
return $default(_that.id,_that.timestamp,_that.title,_that.summary,_that.products,_that.comparisonPoints,_that.imagePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime timestamp,  String title,  String summary,  List<ComparisonProduct> products,  List<ComparisonPoint> comparisonPoints,  String imagePath)?  $default,) {final _that = this;
switch (_that) {
case _ProductComparisonRecord() when $default != null:
return $default(_that.id,_that.timestamp,_that.title,_that.summary,_that.products,_that.comparisonPoints,_that.imagePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductComparisonRecord extends ProductComparisonRecord {
  const _ProductComparisonRecord({required this.id, required this.timestamp, required this.title, required this.summary, final  List<ComparisonProduct> products = const [], final  List<ComparisonPoint> comparisonPoints = const [], required this.imagePath}): _products = products,_comparisonPoints = comparisonPoints,super._();
  factory _ProductComparisonRecord.fromJson(Map<String, dynamic> json) => _$ProductComparisonRecordFromJson(json);

@override final  String id;
@override final  DateTime timestamp;
@override final  String title;
@override final  String summary;
 final  List<ComparisonProduct> _products;
@override@JsonKey() List<ComparisonProduct> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

 final  List<ComparisonPoint> _comparisonPoints;
@override@JsonKey() List<ComparisonPoint> get comparisonPoints {
  if (_comparisonPoints is EqualUnmodifiableListView) return _comparisonPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comparisonPoints);
}

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductComparisonRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._products, _products)&&const DeepCollectionEquality().equals(other._comparisonPoints, _comparisonPoints)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,title,summary,const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_comparisonPoints),imagePath);

@override
String toString() {
  return 'ProductComparisonRecord(id: $id, timestamp: $timestamp, title: $title, summary: $summary, products: $products, comparisonPoints: $comparisonPoints, imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class _$ProductComparisonRecordCopyWith<$Res> implements $ProductComparisonRecordCopyWith<$Res> {
  factory _$ProductComparisonRecordCopyWith(_ProductComparisonRecord value, $Res Function(_ProductComparisonRecord) _then) = __$ProductComparisonRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime timestamp, String title, String summary, List<ComparisonProduct> products, List<ComparisonPoint> comparisonPoints, String imagePath
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? timestamp = null,Object? title = null,Object? summary = null,Object? products = null,Object? comparisonPoints = null,Object? imagePath = null,}) {
  return _then(_ProductComparisonRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<ComparisonProduct>,comparisonPoints: null == comparisonPoints ? _self._comparisonPoints : comparisonPoints // ignore: cast_nullable_to_non_nullable
as List<ComparisonPoint>,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ComparisonProduct {

 String get originalName; String get translatedName;
/// Create a copy of ComparisonProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparisonProductCopyWith<ComparisonProduct> get copyWith => _$ComparisonProductCopyWithImpl<ComparisonProduct>(this as ComparisonProduct, _$identity);

  /// Serializes this ComparisonProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparisonProduct&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.translatedName, translatedName) || other.translatedName == translatedName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalName,translatedName);

@override
String toString() {
  return 'ComparisonProduct(originalName: $originalName, translatedName: $translatedName)';
}


}

/// @nodoc
abstract mixin class $ComparisonProductCopyWith<$Res>  {
  factory $ComparisonProductCopyWith(ComparisonProduct value, $Res Function(ComparisonProduct) _then) = _$ComparisonProductCopyWithImpl;
@useResult
$Res call({
 String originalName, String translatedName
});




}
/// @nodoc
class _$ComparisonProductCopyWithImpl<$Res>
    implements $ComparisonProductCopyWith<$Res> {
  _$ComparisonProductCopyWithImpl(this._self, this._then);

  final ComparisonProduct _self;
  final $Res Function(ComparisonProduct) _then;

/// Create a copy of ComparisonProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? originalName = null,Object? translatedName = null,}) {
  return _then(_self.copyWith(
originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,translatedName: null == translatedName ? _self.translatedName : translatedName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ComparisonProduct].
extension ComparisonProductPatterns on ComparisonProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComparisonProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComparisonProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComparisonProduct value)  $default,){
final _that = this;
switch (_that) {
case _ComparisonProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComparisonProduct value)?  $default,){
final _that = this;
switch (_that) {
case _ComparisonProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String originalName,  String translatedName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComparisonProduct() when $default != null:
return $default(_that.originalName,_that.translatedName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String originalName,  String translatedName)  $default,) {final _that = this;
switch (_that) {
case _ComparisonProduct():
return $default(_that.originalName,_that.translatedName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String originalName,  String translatedName)?  $default,) {final _that = this;
switch (_that) {
case _ComparisonProduct() when $default != null:
return $default(_that.originalName,_that.translatedName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComparisonProduct implements ComparisonProduct {
  const _ComparisonProduct({required this.originalName, required this.translatedName});
  factory _ComparisonProduct.fromJson(Map<String, dynamic> json) => _$ComparisonProductFromJson(json);

@override final  String originalName;
@override final  String translatedName;

/// Create a copy of ComparisonProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComparisonProductCopyWith<_ComparisonProduct> get copyWith => __$ComparisonProductCopyWithImpl<_ComparisonProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComparisonProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComparisonProduct&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.translatedName, translatedName) || other.translatedName == translatedName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalName,translatedName);

@override
String toString() {
  return 'ComparisonProduct(originalName: $originalName, translatedName: $translatedName)';
}


}

/// @nodoc
abstract mixin class _$ComparisonProductCopyWith<$Res> implements $ComparisonProductCopyWith<$Res> {
  factory _$ComparisonProductCopyWith(_ComparisonProduct value, $Res Function(_ComparisonProduct) _then) = __$ComparisonProductCopyWithImpl;
@override @useResult
$Res call({
 String originalName, String translatedName
});




}
/// @nodoc
class __$ComparisonProductCopyWithImpl<$Res>
    implements _$ComparisonProductCopyWith<$Res> {
  __$ComparisonProductCopyWithImpl(this._self, this._then);

  final _ComparisonProduct _self;
  final $Res Function(_ComparisonProduct) _then;

/// Create a copy of ComparisonProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? originalName = null,Object? translatedName = null,}) {
  return _then(_ComparisonProduct(
originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,translatedName: null == translatedName ? _self.translatedName : translatedName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ComparisonPoint {

 String get aspect; List<String> get values;
/// Create a copy of ComparisonPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparisonPointCopyWith<ComparisonPoint> get copyWith => _$ComparisonPointCopyWithImpl<ComparisonPoint>(this as ComparisonPoint, _$identity);

  /// Serializes this ComparisonPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparisonPoint&&(identical(other.aspect, aspect) || other.aspect == aspect)&&const DeepCollectionEquality().equals(other.values, values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,aspect,const DeepCollectionEquality().hash(values));

@override
String toString() {
  return 'ComparisonPoint(aspect: $aspect, values: $values)';
}


}

/// @nodoc
abstract mixin class $ComparisonPointCopyWith<$Res>  {
  factory $ComparisonPointCopyWith(ComparisonPoint value, $Res Function(ComparisonPoint) _then) = _$ComparisonPointCopyWithImpl;
@useResult
$Res call({
 String aspect, List<String> values
});




}
/// @nodoc
class _$ComparisonPointCopyWithImpl<$Res>
    implements $ComparisonPointCopyWith<$Res> {
  _$ComparisonPointCopyWithImpl(this._self, this._then);

  final ComparisonPoint _self;
  final $Res Function(ComparisonPoint) _then;

/// Create a copy of ComparisonPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? aspect = null,Object? values = null,}) {
  return _then(_self.copyWith(
aspect: null == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as String,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ComparisonPoint].
extension ComparisonPointPatterns on ComparisonPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComparisonPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComparisonPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComparisonPoint value)  $default,){
final _that = this;
switch (_that) {
case _ComparisonPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComparisonPoint value)?  $default,){
final _that = this;
switch (_that) {
case _ComparisonPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String aspect,  List<String> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComparisonPoint() when $default != null:
return $default(_that.aspect,_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String aspect,  List<String> values)  $default,) {final _that = this;
switch (_that) {
case _ComparisonPoint():
return $default(_that.aspect,_that.values);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String aspect,  List<String> values)?  $default,) {final _that = this;
switch (_that) {
case _ComparisonPoint() when $default != null:
return $default(_that.aspect,_that.values);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComparisonPoint implements ComparisonPoint {
  const _ComparisonPoint({required this.aspect, final  List<String> values = const []}): _values = values;
  factory _ComparisonPoint.fromJson(Map<String, dynamic> json) => _$ComparisonPointFromJson(json);

@override final  String aspect;
 final  List<String> _values;
@override@JsonKey() List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of ComparisonPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComparisonPointCopyWith<_ComparisonPoint> get copyWith => __$ComparisonPointCopyWithImpl<_ComparisonPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComparisonPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComparisonPoint&&(identical(other.aspect, aspect) || other.aspect == aspect)&&const DeepCollectionEquality().equals(other._values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,aspect,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'ComparisonPoint(aspect: $aspect, values: $values)';
}


}

/// @nodoc
abstract mixin class _$ComparisonPointCopyWith<$Res> implements $ComparisonPointCopyWith<$Res> {
  factory _$ComparisonPointCopyWith(_ComparisonPoint value, $Res Function(_ComparisonPoint) _then) = __$ComparisonPointCopyWithImpl;
@override @useResult
$Res call({
 String aspect, List<String> values
});




}
/// @nodoc
class __$ComparisonPointCopyWithImpl<$Res>
    implements _$ComparisonPointCopyWith<$Res> {
  __$ComparisonPointCopyWithImpl(this._self, this._then);

  final _ComparisonPoint _self;
  final $Res Function(_ComparisonPoint) _then;

/// Create a copy of ComparisonPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? aspect = null,Object? values = null,}) {
  return _then(_ComparisonPoint(
aspect: null == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as String,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
