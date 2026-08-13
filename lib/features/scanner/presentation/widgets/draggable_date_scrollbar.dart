import 'package:flutter/material.dart';
import 'package:lens_wise/features/scanner/domain/models/gallery_asset.dart';

class DraggableDateScrollbar extends StatefulWidget {
  final ScrollController controller;
  final List<String> groupKeys;
  final Map<String, List<GalleryAsset>> groupedAssets;
  final Widget child;

  const DraggableDateScrollbar({
    super.key,
    required this.controller,
    required this.groupKeys,
    required this.groupedAssets,
    required this.child,
  });

  @override
  State<DraggableDateScrollbar> createState() => _DraggableDateScrollbarState();
}

class _DraggableDateScrollbarState extends State<DraggableDateScrollbar> {
  bool _isDragging = false;
  double _dragOffset = 0;
  String _currentLabel = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateLabel);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateLabel);
    super.dispose();
  }

  void _updateLabel() {
    if (!widget.controller.hasClients || widget.groupKeys.isEmpty) return;
    final maxScroll = widget.controller.position.maxScrollExtent;
    final currentScroll = widget.controller.position.pixels;
    if (maxScroll == 0) return;

    final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
    int totalAssets = widget.groupedAssets.values.fold(0, (sum, list) => sum + list.length);
    if (totalAssets == 0) return;

    int targetIndex = (progress * totalAssets).floor();
    int currentSum = 0;
    String newLabel = widget.groupKeys.first;

    for (final key in widget.groupKeys) {
      currentSum += widget.groupedAssets[key]!.length;
      if (targetIndex < currentSum) {
        newLabel = key;
        break;
      }
    }

    if (_currentLabel != newLabel) {
      setState(() {
        _currentLabel = newLabel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Using standard scrollbar for visual thumb, but our custom detector for dragging
        RawScrollbar(
          controller: widget.controller,
          thumbColor: Colors.white.withValues(alpha: 0.5),
          thickness: 4,
          radius: const Radius.circular(10),
          child: widget.child,
        ),
        
        // Fast scroller overlay area
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 30, // Wide enough to catch touches
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: _startDrag,
            onVerticalDragUpdate: _updateDrag,
            onVerticalDragEnd: _endDrag,
            onVerticalDragCancel: _endDragCancel,
            child: const SizedBox.expand(),
          ),
        ),
        
        // The floating badge
        if (_isDragging && _currentLabel.isNotEmpty)
          Positioned(
            right: 48,
            top: _dragOffset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentLabel,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.unfold_more, color: Colors.black, size: 16),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _startDrag(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _updateDragPosition(details.localPosition.dy);
    });
  }

  void _updateDrag(DragUpdateDetails details) {
    _updateDragPosition(details.localPosition.dy);
  }

  void _endDrag(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }
  
  void _endDragCancel() {
    setState(() {
      _isDragging = false;
    });
  }

  void _updateDragPosition(double dy) {
    if (!widget.controller.hasClients) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final height = renderBox.size.height;
    
    final progress = (dy / height).clamp(0.0, 1.0);
    final maxScroll = widget.controller.position.maxScrollExtent;
    
    widget.controller.jumpTo(progress * maxScroll);
    
    setState(() {
      _dragOffset = (dy - 20).clamp(0.0, height - 40);
    });
  }
}
