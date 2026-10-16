import 'package:flutter/material.dart';

class StreamingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool isStreaming;
  final int? maxLines;
  final TextOverflow? overflow;

  const StreamingText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.isStreaming = false,
    this.maxLines,
    this.overflow,
  });

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: widget.isStreaming
          ? AnimatedBuilder(
              animation: _cursorController,
              builder: (context, child) {
                final showCursor = _cursorController.value > 0.4;
                return Text(
                  '${widget.text}${showCursor ? ' ▌' : ''}',
                  style: widget.style,
                  textAlign: widget.textAlign,
                  maxLines: widget.maxLines,
                  overflow: widget.overflow,
                );
              },
            )
          : Text(
              widget.text,
              style: widget.style,
              textAlign: widget.textAlign,
              maxLines: widget.maxLines,
              overflow: widget.overflow,
            ),
    );
  }
}
