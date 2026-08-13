import 'package:flutter/material.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';
import 'package:lens_wise/features/history/domain/models/history_tab_config.dart';
import 'package:lens_wise/features/history/domain/controllers/i_history_controller.dart';

class DraggableHistoryCard<T extends IHistoryRecord> extends StatelessWidget {
  final T record;
  final IHistoryController controller;
  final Widget child;

  const DraggableHistoryCard({
    super.key,
    required this.record,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: LongPressDraggable<HistoryDragData<T>>(
        data: HistoryDragData<T>(record: record, controller: controller),
        delay: const Duration(milliseconds: 200),
        feedback: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 32, // Account for padding
            child: Opacity(
              opacity: 0.8,
              child: Transform.scale(
                scale: 1.05,
                child: child,
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.2,
          child: child,
        ),
        child: child,
      ),
    );
  }
}
