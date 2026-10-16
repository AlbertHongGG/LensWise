import 'package:flutter/material.dart';

class StreamingSection extends StatelessWidget {
  final bool isLoaded;
  final Widget skeleton;
  final Widget child;
  final Duration duration;

  const StreamingSection({
    super.key,
    required this.isLoaded,
    required this.skeleton,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (widget, animation) {
        return FadeTransition(
          opacity: animation,
          child: widget,
        );
      },
      child: isLoaded
          ? KeyedSubtree(key: const ValueKey('loaded_content'), child: child)
          : KeyedSubtree(key: const ValueKey('skeleton_placeholder'), child: skeleton),
    );
  }
}
