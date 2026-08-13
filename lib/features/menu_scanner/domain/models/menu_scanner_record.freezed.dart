// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_scanner_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MenuScannerRecord {

 String get id; DateTime get timestamp; String get storeName; List<MenuScannerItem> get items; List<String> get imagePaths;
/// Create a copy of MenuScannerRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuScannerRecordCopyWith<MenuScannerRecord> get copyWith => _$MenuScannerRecordCopyWithImpl<MenuScannerRecord>(this as MenuScannerRecord, _$identity);

  /// Serializes this MenuScannerRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuScannerRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.imagePaths, imagePaths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,storeName,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(imagePaths));

@override
String toString() {
  return 'MenuScannerRecord(id: $id, timestamp: $timestamp, storeName: $storeName, items: $items, imagePaths: $imagePaths)';
}


}

/// @nodoc
abstract mixin class $MenuScannerRecordCopyWith<$Res>  {
  factory $MenuScannerRecordCopyWith(MenuScannerRecord value, $Res Function(MenuScannerRecord) _then) = _$MenuScannerRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime timestamp, String storeName, List<MenuScannerItem> items, List<String> imagePaths
});




}
/// @nodoc
class _$MenuScannerRecordCopyWithImpl<$Res>
    implements $MenuScannerRecordCopyWith<$Res> {
  _$MenuScannerRecordCopyWithImpl(this._self, this._then);

  final MenuScannerRecord _self;
  final $Res Function(MenuScannerRecord) _then;

/// Create a copy of MenuScannerRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? timestamp = null,Object? storeName = null,Object? items = null,Object? imagePaths = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MenuScannerItem>,imagePaths: null == imagePaths ? _self.imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuScannerRecord].
extension MenuScannerRecordPatterns on MenuScannerRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuScannerRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuScannerRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuScannerRecord value)  $default,){
final _that = this;
switch (_that) {
case _MenuScannerRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuScannerRecord value)?  $default,){
final _that = this;
switch (_that) {
case _MenuScannerRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String storeName,  List<MenuScannerItem> items,  List<String> imagePaths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuScannerRecord() when $default != null:
return $default(_that.id,_that.timestamp,_that.storeName,_that.items,_that.imagePaths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String storeName,  List<MenuScannerItem> items,  List<String> imagePaths)  $default,) {final _that = this;
switch (_that) {
case _MenuScannerRecord():
return $default(_that.id,_that.timestamp,_that.storeName,_that.items,_that.imagePaths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime timestamp,  String storeName,  List<MenuScannerItem> items,  List<String> imagePaths)?  $default,) {final _that = this;
switch (_that) {
case _MenuScannerRecord() when $default != null:
return $default(_that.id,_that.timestamp,_that.storeName,_that.items,_that.imagePaths);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuScannerRecord extends MenuScannerRecord {
  const _MenuScannerRecord({required this.id, required this.timestamp, required this.storeName, final  List<MenuScannerItem> items = const [], final  List<String> imagePaths = const []}): _items = items,_imagePaths = imagePaths,super._();
  factory _MenuScannerRecord.fromJson(Map<String, dynamic> json) => _$MenuScannerRecordFromJson(json);

@override final  String id;
@override final  DateTime timestamp;
@override final  String storeName;
 final  List<MenuScannerItem> _items;
@override@JsonKey() List<MenuScannerItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<String> _imagePaths;
@override@JsonKey() List<String> get imagePaths {
  if (_imagePaths is EqualUnmodifiableListView) return _imagePaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagePaths);
}


/// Create a copy of MenuScannerRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuScannerRecordCopyWith<_MenuScannerRecord> get copyWith => __$MenuScannerRecordCopyWithImpl<_MenuScannerRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuScannerRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuScannerRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._imagePaths, _imagePaths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,storeName,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_imagePaths));

@override
String toString() {
  return 'MenuScannerRecord(id: $id, timestamp: $timestamp, storeName: $storeName, items: $items, imagePaths: $imagePaths)';
}


}

/// @nodoc
abstract mixin class _$MenuScannerRecordCopyWith<$Res> implements $MenuScannerRecordCopyWith<$Res> {
  factory _$MenuScannerRecordCopyWith(_MenuScannerRecord value, $Res Function(_MenuScannerRecord) _then) = __$MenuScannerRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime timestamp, String storeName, List<MenuScannerItem> items, List<String> imagePaths
});




}
/// @nodoc
class __$MenuScannerRecordCopyWithImpl<$Res>
    implements _$MenuScannerRecordCopyWith<$Res> {
  __$MenuScannerRecordCopyWithImpl(this._self, this._then);

  final _MenuScannerRecord _self;
  final $Res Function(_MenuScannerRecord) _then;

/// Create a copy of MenuScannerRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? timestamp = null,Object? storeName = null,Object? items = null,Object? imagePaths = null,}) {
  return _then(_MenuScannerRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MenuScannerItem>,imagePaths: null == imagePaths ? _self._imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$MenuScannerItem {

 String get originalName; String get translatedName; String? get description; double get price;
/// Create a copy of MenuScannerItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuScannerItemCopyWith<MenuScannerItem> get copyWith => _$MenuScannerItemCopyWithImpl<MenuScannerItem>(this as MenuScannerItem, _$identity);

  /// Serializes this MenuScannerItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuScannerItem&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.translatedName, translatedName) || other.translatedName == translatedName)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalName,translatedName,description,price);

@override
String toString() {
  return 'MenuScannerItem(originalName: $originalName, translatedName: $translatedName, description: $description, price: $price)';
}


}

/// @nodoc
abstract mixin class $MenuScannerItemCopyWith<$Res>  {
  factory $MenuScannerItemCopyWith(MenuScannerItem value, $Res Function(MenuScannerItem) _then) = _$MenuScannerItemCopyWithImpl;
@useResult
$Res call({
 String originalName, String translatedName, String? description, double price
});




}
/// @nodoc
class _$MenuScannerItemCopyWithImpl<$Res>
    implements $MenuScannerItemCopyWith<$Res> {
  _$MenuScannerItemCopyWithImpl(this._self, this._then);

  final MenuScannerItem _self;
  final $Res Function(MenuScannerItem) _then;

/// Create a copy of MenuScannerItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? originalName = null,Object? translatedName = null,Object? description = freezed,Object? price = null,}) {
  return _then(_self.copyWith(
originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,translatedName: null == translatedName ? _self.translatedName : translatedName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuScannerItem].
extension MenuScannerItemPatterns on MenuScannerItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuScannerItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuScannerItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuScannerItem value)  $default,){
final _that = this;
switch (_that) {
case _MenuScannerItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuScannerItem value)?  $default,){
final _that = this;
switch (_that) {
case _MenuScannerItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String originalName,  String translatedName,  String? description,  double price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuScannerItem() when $default != null:
return $default(_that.originalName,_that.translatedName,_that.description,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String originalName,  String translatedName,  String? description,  double price)  $default,) {final _that = this;
switch (_that) {
case _MenuScannerItem():
return $default(_that.originalName,_that.translatedName,_that.description,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String originalName,  String translatedName,  String? description,  double price)?  $default,) {final _that = this;
switch (_that) {
case _MenuScannerItem() when $default != null:
return $default(_that.originalName,_that.translatedName,_that.description,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuScannerItem implements MenuScannerItem {
  const _MenuScannerItem({required this.originalName, required this.translatedName, this.description, required this.price});
  factory _MenuScannerItem.fromJson(Map<String, dynamic> json) => _$MenuScannerItemFromJson(json);

@override final  String originalName;
@override final  String translatedName;
@override final  String? description;
@override final  double price;

/// Create a copy of MenuScannerItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuScannerItemCopyWith<_MenuScannerItem> get copyWith => __$MenuScannerItemCopyWithImpl<_MenuScannerItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuScannerItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuScannerItem&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.translatedName, translatedName) || other.translatedName == translatedName)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalName,translatedName,description,price);

@override
String toString() {
  return 'MenuScannerItem(originalName: $originalName, translatedName: $translatedName, description: $description, price: $price)';
}


}

/// @nodoc
abstract mixin class _$MenuScannerItemCopyWith<$Res> implements $MenuScannerItemCopyWith<$Res> {
  factory _$MenuScannerItemCopyWith(_MenuScannerItem value, $Res Function(_MenuScannerItem) _then) = __$MenuScannerItemCopyWithImpl;
@override @useResult
$Res call({
 String originalName, String translatedName, String? description, double price
});




}
/// @nodoc
class __$MenuScannerItemCopyWithImpl<$Res>
    implements _$MenuScannerItemCopyWith<$Res> {
  __$MenuScannerItemCopyWithImpl(this._self, this._then);

  final _MenuScannerItem _self;
  final $Res Function(_MenuScannerItem) _then;

/// Create a copy of MenuScannerItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? originalName = null,Object? translatedName = null,Object? description = freezed,Object? price = null,}) {
  return _then(_MenuScannerItem(
originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,translatedName: null == translatedName ? _self.translatedName : translatedName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
