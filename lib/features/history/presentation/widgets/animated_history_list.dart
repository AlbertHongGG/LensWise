import 'package:flutter/material.dart';

class AnimatedHistoryList<T> extends StatefulWidget {
  final List<T> records;
  final Widget Function(BuildContext context, T record) itemBuilder;
  final bool Function(T a, T b) areItemsTheSame;

  const AnimatedHistoryList({
    super.key,
    required this.records,
    required this.itemBuilder,
    required this.areItemsTheSame,
  });

  @override
  State<AnimatedHistoryList<T>> createState() => _AnimatedHistoryListState<T>();
}

class _AnimatedHistoryListState<T> extends State<AnimatedHistoryList<T>> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.records);
  }

  @override
  void didUpdateWidget(AnimatedHistoryList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final newList = widget.records;
    
    // Find removed items (iterate backwards to avoid index shifting issues)
    for (int i = _items.length - 1; i >= 0; i--) {
      final oldItem = _items[i];
      if (!newList.any((newItem) => widget.areItemsTheSame(oldItem, newItem))) {
        final removedItem = _items.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildAnimatedItem(context, removedItem, animation),
          duration: const Duration(milliseconds: 500),
        );
      }
    }
    
    // Find added items
    for (int i = 0; i < newList.length; i++) {
      final newItem = newList[i];
      if (!_items.any((existingItem) => widget.areItemsTheSame(existingItem, newItem))) {
        final insertIndex = i > _items.length ? _items.length : i;
        _items.insert(insertIndex, newItem);
        _listKey.currentState?.insertItem(
          insertIndex, 
          duration: const Duration(milliseconds: 500)
        );
      }
    }
  }

  Widget _buildAnimatedItem(BuildContext context, T item, Animation<double> animation) {
    return SizeTransition(
      axisAlignment: -1.0,
      sizeFactor: CurvedAnimation(
        parent: animation,
        // When inserting (0->1): size expands first (0.0 to 0.6)
        // When removing (1->0): size collapses last (0.6 to 0.0)
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          // When inserting (0->1): fades in last (0.4 to 1.0)
          // When removing (1->0): fades out first (1.0 to 0.4)
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
        ),
        child: widget.itemBuilder(context, item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).copyWith(bottom: 100),
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        return _buildAnimatedItem(context, _items[index], animation);
      },
    );
  }
}
