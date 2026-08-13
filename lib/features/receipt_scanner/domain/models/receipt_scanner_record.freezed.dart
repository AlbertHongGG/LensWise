// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt_scanner_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReceiptScannerRecord {

 String get id; DateTime get timestamp; String? get receiptDate; String get storeName; String? get currency; double get subtotal; List<ReceiptItem> get items; List<ReceiptFeeItem> get discounts; List<ReceiptFeeItem> get taxes; double get totalAmount; List<String> get imagePaths;
/// Create a copy of ReceiptScannerRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptScannerRecordCopyWith<ReceiptScannerRecord> get copyWith => _$ReceiptScannerRecordCopyWithImpl<ReceiptScannerRecord>(this as ReceiptScannerRecord, _$identity);

  /// Serializes this ReceiptScannerRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptScannerRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.discounts, discounts)&&const DeepCollectionEquality().equals(other.taxes, taxes)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&const DeepCollectionEquality().equals(other.imagePaths, imagePaths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,receiptDate,storeName,currency,subtotal,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(discounts),const DeepCollectionEquality().hash(taxes),totalAmount,const DeepCollectionEquality().hash(imagePaths));

@override
String toString() {
  return 'ReceiptScannerRecord(id: $id, timestamp: $timestamp, receiptDate: $receiptDate, storeName: $storeName, currency: $currency, subtotal: $subtotal, items: $items, discounts: $discounts, taxes: $taxes, totalAmount: $totalAmount, imagePaths: $imagePaths)';
}


}

/// @nodoc
abstract mixin class $ReceiptScannerRecordCopyWith<$Res>  {
  factory $ReceiptScannerRecordCopyWith(ReceiptScannerRecord value, $Res Function(ReceiptScannerRecord) _then) = _$ReceiptScannerRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime timestamp, String? receiptDate, String storeName, String? currency, double subtotal, List<ReceiptItem> items, List<ReceiptFeeItem> discounts, List<ReceiptFeeItem> taxes, double totalAmount, List<String> imagePaths
});




}
/// @nodoc
class _$ReceiptScannerRecordCopyWithImpl<$Res>
    implements $ReceiptScannerRecordCopyWith<$Res> {
  _$ReceiptScannerRecordCopyWithImpl(this._self, this._then);

  final ReceiptScannerRecord _self;
  final $Res Function(ReceiptScannerRecord) _then;

/// Create a copy of ReceiptScannerRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? timestamp = null,Object? receiptDate = freezed,Object? storeName = null,Object? currency = freezed,Object? subtotal = null,Object? items = null,Object? discounts = null,Object? taxes = null,Object? totalAmount = null,Object? imagePaths = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as String?,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ReceiptItem>,discounts: null == discounts ? _self.discounts : discounts // ignore: cast_nullable_to_non_nullable
as List<ReceiptFeeItem>,taxes: null == taxes ? _self.taxes : taxes // ignore: cast_nullable_to_non_nullable
as List<ReceiptFeeItem>,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,imagePaths: null == imagePaths ? _self.imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiptScannerRecord].
extension ReceiptScannerRecordPatterns on ReceiptScannerRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiptScannerRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiptScannerRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiptScannerRecord value)  $default,){
final _that = this;
switch (_that) {
case _ReceiptScannerRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiptScannerRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiptScannerRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String? receiptDate,  String storeName,  String? currency,  double subtotal,  List<ReceiptItem> items,  List<ReceiptFeeItem> discounts,  List<ReceiptFeeItem> taxes,  double totalAmount,  List<String> imagePaths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiptScannerRecord() when $default != null:
return $default(_that.id,_that.timestamp,_that.receiptDate,_that.storeName,_that.currency,_that.subtotal,_that.items,_that.discounts,_that.taxes,_that.totalAmount,_that.imagePaths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String? receiptDate,  String storeName,  String? currency,  double subtotal,  List<ReceiptItem> items,  List<ReceiptFeeItem> discounts,  List<ReceiptFeeItem> taxes,  double totalAmount,  List<String> imagePaths)  $default,) {final _that = this;
switch (_that) {
case _ReceiptScannerRecord():
return $default(_that.id,_that.timestamp,_that.receiptDate,_that.storeName,_that.currency,_that.subtotal,_that.items,_that.discounts,_that.taxes,_that.totalAmount,_that.imagePaths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime timestamp,  String? receiptDate,  String storeName,  String? currency,  double subtotal,  List<ReceiptItem> items,  List<ReceiptFeeItem> discounts,  List<ReceiptFeeItem> taxes,  double totalAmount,  List<String> imagePaths)?  $default,) {final _that = this;
switch (_that) {
case _ReceiptScannerRecord() when $default != null:
return $default(_that.id,_that.timestamp,_that.receiptDate,_that.storeName,_that.currency,_that.subtotal,_that.items,_that.discounts,_that.taxes,_that.totalAmount,_that.imagePaths);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceiptScannerRecord extends ReceiptScannerRecord {
  const _ReceiptScannerRecord({required this.id, required this.timestamp, this.receiptDate, required this.storeName, this.currency, required this.subtotal, final  List<ReceiptItem> items = const [], final  List<ReceiptFeeItem> discounts = const [], final  List<ReceiptFeeItem> taxes = const [], required this.totalAmount, final  List<String> imagePaths = const []}): _items = items,_discounts = discounts,_taxes = taxes,_imagePaths = imagePaths,super._();
  factory _ReceiptScannerRecord.fromJson(Map<String, dynamic> json) => _$ReceiptScannerRecordFromJson(json);

@override final  String id;
@override final  DateTime timestamp;
@override final  String? receiptDate;
@override final  String storeName;
@override final  String? currency;
@override final  double subtotal;
 final  List<ReceiptItem> _items;
@override@JsonKey() List<ReceiptItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<ReceiptFeeItem> _discounts;
@override@JsonKey() List<ReceiptFeeItem> get discounts {
  if (_discounts is EqualUnmodifiableListView) return _discounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discounts);
}

 final  List<ReceiptFeeItem> _taxes;
@override@JsonKey() List<ReceiptFeeItem> get taxes {
  if (_taxes is EqualUnmodifiableListView) return _taxes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_taxes);
}

@override final  double totalAmount;
 final  List<String> _imagePaths;
@override@JsonKey() List<String> get imagePaths {
  if (_imagePaths is EqualUnmodifiableListView) return _imagePaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagePaths);
}


/// Create a copy of ReceiptScannerRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptScannerRecordCopyWith<_ReceiptScannerRecord> get copyWith => __$ReceiptScannerRecordCopyWithImpl<_ReceiptScannerRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptScannerRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptScannerRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._discounts, _discounts)&&const DeepCollectionEquality().equals(other._taxes, _taxes)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&const DeepCollectionEquality().equals(other._imagePaths, _imagePaths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,receiptDate,storeName,currency,subtotal,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_discounts),const DeepCollectionEquality().hash(_taxes),totalAmount,const DeepCollectionEquality().hash(_imagePaths));

@override
String toString() {
  return 'ReceiptScannerRecord(id: $id, timestamp: $timestamp, receiptDate: $receiptDate, storeName: $storeName, currency: $currency, subtotal: $subtotal, items: $items, discounts: $discounts, taxes: $taxes, totalAmount: $totalAmount, imagePaths: $imagePaths)';
}


}

/// @nodoc
abstract mixin class _$ReceiptScannerRecordCopyWith<$Res> implements $ReceiptScannerRecordCopyWith<$Res> {
  factory _$ReceiptScannerRecordCopyWith(_ReceiptScannerRecord value, $Res Function(_ReceiptScannerRecord) _then) = __$ReceiptScannerRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime timestamp, String? receiptDate, String storeName, String? currency, double subtotal, List<ReceiptItem> items, List<ReceiptFeeItem> discounts, List<ReceiptFeeItem> taxes, double totalAmount, List<String> imagePaths
});




}
/// @nodoc
class __$ReceiptScannerRecordCopyWithImpl<$Res>
    implements _$ReceiptScannerRecordCopyWith<$Res> {
  __$ReceiptScannerRecordCopyWithImpl(this._self, this._then);

  final _ReceiptScannerRecord _self;
  final $Res Function(_ReceiptScannerRecord) _then;

/// Create a copy of ReceiptScannerRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? timestamp = null,Object? receiptDate = freezed,Object? storeName = null,Object? currency = freezed,Object? subtotal = null,Object? items = null,Object? discounts = null,Object? taxes = null,Object? totalAmount = null,Object? imagePaths = null,}) {
  return _then(_ReceiptScannerRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as String?,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ReceiptItem>,discounts: null == discounts ? _self._discounts : discounts // ignore: cast_nullable_to_non_nullable
as List<ReceiptFeeItem>,taxes: null == taxes ? _self._taxes : taxes // ignore: cast_nullable_to_non_nullable
as List<ReceiptFeeItem>,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,imagePaths: null == imagePaths ? _self._imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ReceiptItem {

 String get originalName; String get translatedName; double get price;
/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptItemCopyWith<ReceiptItem> get copyWith => _$ReceiptItemCopyWithImpl<ReceiptItem>(this as ReceiptItem, _$identity);

  /// Serializes this ReceiptItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptItem&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.translatedName, translatedName) || other.translatedName == translatedName)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalName,translatedName,price);

@override
String toString() {
  return 'ReceiptItem(originalName: $originalName, translatedName: $translatedName, price: $price)';
}


}

/// @nodoc
abstract mixin class $ReceiptItemCopyWith<$Res>  {
  factory $ReceiptItemCopyWith(ReceiptItem value, $Res Function(ReceiptItem) _then) = _$ReceiptItemCopyWithImpl;
@useResult
$Res call({
 String originalName, String translatedName, double price
});




}
/// @nodoc
class _$ReceiptItemCopyWithImpl<$Res>
    implements $ReceiptItemCopyWith<$Res> {
  _$ReceiptItemCopyWithImpl(this._self, this._then);

  final ReceiptItem _self;
  final $Res Function(ReceiptItem) _then;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? originalName = null,Object? translatedName = null,Object? price = null,}) {
  return _then(_self.copyWith(
originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,translatedName: null == translatedName ? _self.translatedName : translatedName // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiptItem].
extension ReceiptItemPatterns on ReceiptItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiptItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiptItem value)  $default,){
final _that = this;
switch (_that) {
case _ReceiptItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiptItem value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String originalName,  String translatedName,  double price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
return $default(_that.originalName,_that.translatedName,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String originalName,  String translatedName,  double price)  $default,) {final _that = this;
switch (_that) {
case _ReceiptItem():
return $default(_that.originalName,_that.translatedName,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String originalName,  String translatedName,  double price)?  $default,) {final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
return $default(_that.originalName,_that.translatedName,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceiptItem implements ReceiptItem {
  const _ReceiptItem({required this.originalName, required this.translatedName, required this.price});
  factory _ReceiptItem.fromJson(Map<String, dynamic> json) => _$ReceiptItemFromJson(json);

@override final  String originalName;
@override final  String translatedName;
@override final  double price;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptItemCopyWith<_ReceiptItem> get copyWith => __$ReceiptItemCopyWithImpl<_ReceiptItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptItem&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.translatedName, translatedName) || other.translatedName == translatedName)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalName,translatedName,price);

@override
String toString() {
  return 'ReceiptItem(originalName: $originalName, translatedName: $translatedName, price: $price)';
}


}

/// @nodoc
abstract mixin class _$ReceiptItemCopyWith<$Res> implements $ReceiptItemCopyWith<$Res> {
  factory _$ReceiptItemCopyWith(_ReceiptItem value, $Res Function(_ReceiptItem) _then) = __$ReceiptItemCopyWithImpl;
@override @useResult
$Res call({
 String originalName, String translatedName, double price
});




}
/// @nodoc
class __$ReceiptItemCopyWithImpl<$Res>
    implements _$ReceiptItemCopyWith<$Res> {
  __$ReceiptItemCopyWithImpl(this._self, this._then);

  final _ReceiptItem _self;
  final $Res Function(_ReceiptItem) _then;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? originalName = null,Object? translatedName = null,Object? price = null,}) {
  return _then(_ReceiptItem(
originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,translatedName: null == translatedName ? _self.translatedName : translatedName // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ReceiptFeeItem {

 String get name; double get amount;
/// Create a copy of ReceiptFeeItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptFeeItemCopyWith<ReceiptFeeItem> get copyWith => _$ReceiptFeeItemCopyWithImpl<ReceiptFeeItem>(this as ReceiptFeeItem, _$identity);

  /// Serializes this ReceiptFeeItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptFeeItem&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,amount);

@override
String toString() {
  return 'ReceiptFeeItem(name: $name, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $ReceiptFeeItemCopyWith<$Res>  {
  factory $ReceiptFeeItemCopyWith(ReceiptFeeItem value, $Res Function(ReceiptFeeItem) _then) = _$ReceiptFeeItemCopyWithImpl;
@useResult
$Res call({
 String name, double amount
});




}
/// @nodoc
class _$ReceiptFeeItemCopyWithImpl<$Res>
    implements $ReceiptFeeItemCopyWith<$Res> {
  _$ReceiptFeeItemCopyWithImpl(this._self, this._then);

  final ReceiptFeeItem _self;
  final $Res Function(ReceiptFeeItem) _then;

/// Create a copy of ReceiptFeeItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? amount = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiptFeeItem].
extension ReceiptFeeItemPatterns on ReceiptFeeItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiptFeeItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiptFeeItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiptFeeItem value)  $default,){
final _that = this;
switch (_that) {
case _ReceiptFeeItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiptFeeItem value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiptFeeItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiptFeeItem() when $default != null:
return $default(_that.name,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double amount)  $default,) {final _that = this;
switch (_that) {
case _ReceiptFeeItem():
return $default(_that.name,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _ReceiptFeeItem() when $default != null:
return $default(_that.name,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceiptFeeItem implements ReceiptFeeItem {
  const _ReceiptFeeItem({required this.name, required this.amount});
  factory _ReceiptFeeItem.fromJson(Map<String, dynamic> json) => _$ReceiptFeeItemFromJson(json);

@override final  String name;
@override final  double amount;

/// Create a copy of ReceiptFeeItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptFeeItemCopyWith<_ReceiptFeeItem> get copyWith => __$ReceiptFeeItemCopyWithImpl<_ReceiptFeeItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptFeeItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptFeeItem&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,amount);

@override
String toString() {
  return 'ReceiptFeeItem(name: $name, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$ReceiptFeeItemCopyWith<$Res> implements $ReceiptFeeItemCopyWith<$Res> {
  factory _$ReceiptFeeItemCopyWith(_ReceiptFeeItem value, $Res Function(_ReceiptFeeItem) _then) = __$ReceiptFeeItemCopyWithImpl;
@override @useResult
$Res call({
 String name, double amount
});




}
/// @nodoc
class __$ReceiptFeeItemCopyWithImpl<$Res>
    implements _$ReceiptFeeItemCopyWith<$Res> {
  __$ReceiptFeeItemCopyWithImpl(this._self, this._then);

  final _ReceiptFeeItem _self;
  final $Res Function(_ReceiptFeeItem) _then;

/// Create a copy of ReceiptFeeItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? amount = null,}) {
  return _then(_ReceiptFeeItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
