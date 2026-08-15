// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_archive.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BackupArchive {

 DateTime get exportedAt; String get appVersion; List<ReceiptScannerRecord> get receiptRecords; List<ProductLensRecord> get productLensRecords; List<ProductComparisonRecord> get comparisonRecords; List<MenuScannerRecord> get menuRecords;
/// Create a copy of BackupArchive
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupArchiveCopyWith<BackupArchive> get copyWith => _$BackupArchiveCopyWithImpl<BackupArchive>(this as BackupArchive, _$identity);

  /// Serializes this BackupArchive to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupArchive&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&const DeepCollectionEquality().equals(other.receiptRecords, receiptRecords)&&const DeepCollectionEquality().equals(other.productLensRecords, productLensRecords)&&const DeepCollectionEquality().equals(other.comparisonRecords, comparisonRecords)&&const DeepCollectionEquality().equals(other.menuRecords, menuRecords));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exportedAt,appVersion,const DeepCollectionEquality().hash(receiptRecords),const DeepCollectionEquality().hash(productLensRecords),const DeepCollectionEquality().hash(comparisonRecords),const DeepCollectionEquality().hash(menuRecords));

@override
String toString() {
  return 'BackupArchive(exportedAt: $exportedAt, appVersion: $appVersion, receiptRecords: $receiptRecords, productLensRecords: $productLensRecords, comparisonRecords: $comparisonRecords, menuRecords: $menuRecords)';
}


}

/// @nodoc
abstract mixin class $BackupArchiveCopyWith<$Res>  {
  factory $BackupArchiveCopyWith(BackupArchive value, $Res Function(BackupArchive) _then) = _$BackupArchiveCopyWithImpl;
@useResult
$Res call({
 DateTime exportedAt, String appVersion, List<ReceiptScannerRecord> receiptRecords, List<ProductLensRecord> productLensRecords, List<ProductComparisonRecord> comparisonRecords, List<MenuScannerRecord> menuRecords
});




}
/// @nodoc
class _$BackupArchiveCopyWithImpl<$Res>
    implements $BackupArchiveCopyWith<$Res> {
  _$BackupArchiveCopyWithImpl(this._self, this._then);

  final BackupArchive _self;
  final $Res Function(BackupArchive) _then;

/// Create a copy of BackupArchive
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exportedAt = null,Object? appVersion = null,Object? receiptRecords = null,Object? productLensRecords = null,Object? comparisonRecords = null,Object? menuRecords = null,}) {
  return _then(_self.copyWith(
exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,receiptRecords: null == receiptRecords ? _self.receiptRecords : receiptRecords // ignore: cast_nullable_to_non_nullable
as List<ReceiptScannerRecord>,productLensRecords: null == productLensRecords ? _self.productLensRecords : productLensRecords // ignore: cast_nullable_to_non_nullable
as List<ProductLensRecord>,comparisonRecords: null == comparisonRecords ? _self.comparisonRecords : comparisonRecords // ignore: cast_nullable_to_non_nullable
as List<ProductComparisonRecord>,menuRecords: null == menuRecords ? _self.menuRecords : menuRecords // ignore: cast_nullable_to_non_nullable
as List<MenuScannerRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [BackupArchive].
extension BackupArchivePatterns on BackupArchive {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackupArchive value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackupArchive() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackupArchive value)  $default,){
final _that = this;
switch (_that) {
case _BackupArchive():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackupArchive value)?  $default,){
final _that = this;
switch (_that) {
case _BackupArchive() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime exportedAt,  String appVersion,  List<ReceiptScannerRecord> receiptRecords,  List<ProductLensRecord> productLensRecords,  List<ProductComparisonRecord> comparisonRecords,  List<MenuScannerRecord> menuRecords)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackupArchive() when $default != null:
return $default(_that.exportedAt,_that.appVersion,_that.receiptRecords,_that.productLensRecords,_that.comparisonRecords,_that.menuRecords);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime exportedAt,  String appVersion,  List<ReceiptScannerRecord> receiptRecords,  List<ProductLensRecord> productLensRecords,  List<ProductComparisonRecord> comparisonRecords,  List<MenuScannerRecord> menuRecords)  $default,) {final _that = this;
switch (_that) {
case _BackupArchive():
return $default(_that.exportedAt,_that.appVersion,_that.receiptRecords,_that.productLensRecords,_that.comparisonRecords,_that.menuRecords);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime exportedAt,  String appVersion,  List<ReceiptScannerRecord> receiptRecords,  List<ProductLensRecord> productLensRecords,  List<ProductComparisonRecord> comparisonRecords,  List<MenuScannerRecord> menuRecords)?  $default,) {final _that = this;
switch (_that) {
case _BackupArchive() when $default != null:
return $default(_that.exportedAt,_that.appVersion,_that.receiptRecords,_that.productLensRecords,_that.comparisonRecords,_that.menuRecords);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BackupArchive implements BackupArchive {
  const _BackupArchive({required this.exportedAt, required this.appVersion, final  List<ReceiptScannerRecord> receiptRecords = const [], final  List<ProductLensRecord> productLensRecords = const [], final  List<ProductComparisonRecord> comparisonRecords = const [], final  List<MenuScannerRecord> menuRecords = const []}): _receiptRecords = receiptRecords,_productLensRecords = productLensRecords,_comparisonRecords = comparisonRecords,_menuRecords = menuRecords;
  factory _BackupArchive.fromJson(Map<String, dynamic> json) => _$BackupArchiveFromJson(json);

@override final  DateTime exportedAt;
@override final  String appVersion;
 final  List<ReceiptScannerRecord> _receiptRecords;
@override@JsonKey() List<ReceiptScannerRecord> get receiptRecords {
  if (_receiptRecords is EqualUnmodifiableListView) return _receiptRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_receiptRecords);
}

 final  List<ProductLensRecord> _productLensRecords;
@override@JsonKey() List<ProductLensRecord> get productLensRecords {
  if (_productLensRecords is EqualUnmodifiableListView) return _productLensRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_productLensRecords);
}

 final  List<ProductComparisonRecord> _comparisonRecords;
@override@JsonKey() List<ProductComparisonRecord> get comparisonRecords {
  if (_comparisonRecords is EqualUnmodifiableListView) return _comparisonRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comparisonRecords);
}

 final  List<MenuScannerRecord> _menuRecords;
@override@JsonKey() List<MenuScannerRecord> get menuRecords {
  if (_menuRecords is EqualUnmodifiableListView) return _menuRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_menuRecords);
}


/// Create a copy of BackupArchive
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackupArchiveCopyWith<_BackupArchive> get copyWith => __$BackupArchiveCopyWithImpl<_BackupArchive>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BackupArchiveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackupArchive&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&const DeepCollectionEquality().equals(other._receiptRecords, _receiptRecords)&&const DeepCollectionEquality().equals(other._productLensRecords, _productLensRecords)&&const DeepCollectionEquality().equals(other._comparisonRecords, _comparisonRecords)&&const DeepCollectionEquality().equals(other._menuRecords, _menuRecords));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exportedAt,appVersion,const DeepCollectionEquality().hash(_receiptRecords),const DeepCollectionEquality().hash(_productLensRecords),const DeepCollectionEquality().hash(_comparisonRecords),const DeepCollectionEquality().hash(_menuRecords));

@override
String toString() {
  return 'BackupArchive(exportedAt: $exportedAt, appVersion: $appVersion, receiptRecords: $receiptRecords, productLensRecords: $productLensRecords, comparisonRecords: $comparisonRecords, menuRecords: $menuRecords)';
}


}

/// @nodoc
abstract mixin class _$BackupArchiveCopyWith<$Res> implements $BackupArchiveCopyWith<$Res> {
  factory _$BackupArchiveCopyWith(_BackupArchive value, $Res Function(_BackupArchive) _then) = __$BackupArchiveCopyWithImpl;
@override @useResult
$Res call({
 DateTime exportedAt, String appVersion, List<ReceiptScannerRecord> receiptRecords, List<ProductLensRecord> productLensRecords, List<ProductComparisonRecord> comparisonRecords, List<MenuScannerRecord> menuRecords
});




}
/// @nodoc
class __$BackupArchiveCopyWithImpl<$Res>
    implements _$BackupArchiveCopyWith<$Res> {
  __$BackupArchiveCopyWithImpl(this._self, this._then);

  final _BackupArchive _self;
  final $Res Function(_BackupArchive) _then;

/// Create a copy of BackupArchive
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exportedAt = null,Object? appVersion = null,Object? receiptRecords = null,Object? productLensRecords = null,Object? comparisonRecords = null,Object? menuRecords = null,}) {
  return _then(_BackupArchive(
exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,receiptRecords: null == receiptRecords ? _self._receiptRecords : receiptRecords // ignore: cast_nullable_to_non_nullable
as List<ReceiptScannerRecord>,productLensRecords: null == productLensRecords ? _self._productLensRecords : productLensRecords // ignore: cast_nullable_to_non_nullable
as List<ProductLensRecord>,comparisonRecords: null == comparisonRecords ? _self._comparisonRecords : comparisonRecords // ignore: cast_nullable_to_non_nullable
as List<ProductComparisonRecord>,menuRecords: null == menuRecords ? _self._menuRecords : menuRecords // ignore: cast_nullable_to_non_nullable
as List<MenuScannerRecord>,
  ));
}


}

// dart format on
