import 'package:flutter/material.dart';

abstract interface class IHistoryRecord {
  String get id;
  String get displayTitle;
  String get displaySubtitle;
  DateTime get timestamp;
  
  IconData get displayIcon;

  String? get deletionImagePath;
  List<String>? get deletionImagePaths;
}
