import 'package:flutter/material.dart';

/// Direct text display for streaming content with zero animation jitter.
/// Uses [RepaintBoundary] to isolate text repainting from parent widgets.
class StreamingText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isStreaming;

  const StreamingText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
