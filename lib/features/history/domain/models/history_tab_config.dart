import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';
import 'package:lens_wise/features/history/domain/controllers/i_history_controller.dart';

class HistoryTabConfig<T extends IHistoryRecord> {
  final String tabName;
  final IconData tabIcon;
  final String emptyStateTitle;
  final String emptyStateDescription;
  final IconData emptyStateIcon;
  final AsyncValue<List<T>> Function(WidgetRef ref) watchHistory;
  final IHistoryController Function(WidgetRef ref) readController;
  final Widget Function(BuildContext context, WidgetRef ref, IHistoryRecord record, bool isDark) cardBuilder;

  const HistoryTabConfig({
    required this.tabName,
    required this.tabIcon,
    required this.emptyStateTitle,
    required this.emptyStateDescription,
    required this.emptyStateIcon,
    required this.watchHistory,
    required this.readController,
    required this.cardBuilder,
  });
}

class HistoryDragData<T extends IHistoryRecord> {
  final T record;
  final IHistoryController controller;
  
  const HistoryDragData({
    required this.record,
    required this.controller,
  });
}
