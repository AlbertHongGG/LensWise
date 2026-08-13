import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_chat_controller.dart';
import 'package:lens_wise/features/ai/domain/models/chat_message.dart';
import 'package:lens_wise/features/ai/presentation/widgets/thinking_orb.dart';
import 'package:lens_wise/core/voice/presentation/controllers/voice_controller.dart';
import 'package:lens_wise/core/voice/domain/models/voice_state.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_config_controller.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void showAiChatBottomSheet(
  BuildContext context, {
  required String contextId,
  required String systemContextPrompt,
  required String initialMessage,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AiChatBottomSheet(
      contextId: contextId,
      systemContextPrompt: systemContextPrompt,
      initialMessage: initialMessage,
    ),
  );
}

class AiChatBottomSheet extends ConsumerStatefulWidget {
  final String contextId;
  final String systemContextPrompt;
  final String initialMessage;

  const AiChatBottomSheet({
    super.key,
    required this.contextId,
    required this.systemContextPrompt,
    required this.initialMessage,
  });

  @override
  ConsumerState<AiChatBottomSheet> createState() => _AiChatBottomSheetState();
}

class _AiChatBottomSheetState extends ConsumerState<AiChatBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _textFieldScrollController = ScrollController();
  String _baseTypedText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceControllerProvider.notifier).initialize();
      ref.read(aiChatControllerProvider.notifier).initialize(
            contextId: widget.contextId,
            systemContextPrompt: widget.systemContextPrompt,
            initialMessage: widget.initialMessage,
          );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }
  void _scrollTextFieldToRight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_textFieldScrollController.hasClients) {
        _textFieldScrollController.animateTo(
          _textFieldScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(aiChatControllerProvider.notifier).sendMessage(text);
    
    // Stop listening to prevent late voice results from overwriting the cleared input
    ref.read(voiceControllerProvider.notifier).stopListening();
    
    _controller.clear();
    _baseTypedText = '';
    ref.read(voiceControllerProvider.notifier).clearText();
  }

  void _handleMicToggle(bool isCurrentlyListening) {
    if (!isCurrentlyListening) {
      _baseTypedText = _controller.text.trim();
    }
    ref.read(voiceControllerProvider.notifier).toggleListening();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(aiChatControllerProvider);
    final aiConfig = ref.watch(aiConfigControllerProvider);
    final voiceState = ref.watch(voiceControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.listen<AiChatSessionState>(aiChatControllerProvider, (_, __) => _scrollToBottom());
    
    ref.listen<VoiceState>(voiceControllerProvider, (previous, next) {
      if (next.recognizedText != previous?.recognizedText) {
        final newText = _baseTypedText.isEmpty 
            ? next.recognizedText 
            : (_baseTypedText + (next.recognizedText.isNotEmpty ? ' ${next.recognizedText}' : ''));
            
        if (_controller.text != newText) {
          _controller.text = newText;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length)
          );
          _scrollTextFieldToRight();
        }
      }
      if (next.hasError && !(previous?.hasError ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('無法啟用語音辨識，請確認麥克風權限與系統是否支援。')),
        );
      }
    });

    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: math.max(0.0, (MediaQuery.sizeOf(context).height * 0.85) - keyboardHeight),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(isDark),
            if (!aiConfig.isAIAgentEnabled)
              Expanded(child: _buildDisabledState(context, isDark))
            else ...[
              Expanded(
                child: Container(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: sessionState.messages.length + (sessionState.isProcessing ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < sessionState.messages.length) {
                        return _buildChatBubble(sessionState.messages[index], isDark);
                      }
                      return _buildThinkingBubble(sessionState, isDark);
                    },
                  ),
                ),
              ),
              _buildInputArea(sessionState, voiceState, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.power_off_rounded,
                size: 64,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AI 聆聽中...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '請至設定開啟 AI 輔助功能以使用智能對話。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'AI 深度探討',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _buildPremiumMarkdownStyleSheet(BuildContext context, bool isDark, bool isError) {
    final textColor = isError ? Colors.red : (isDark ? Colors.white : Colors.black87);
    final primaryColor = Theme.of(context).primaryColor;
    
    return MarkdownStyleSheet(
      p: TextStyle(fontSize: 15, color: textColor, height: 1.6),
      h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor, height: 1.4),
      h2: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor, height: 1.4),
      h3: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor, height: 1.4),
      h4: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor, height: 1.4),
      h5: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor, height: 1.4),
      h6: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor, height: 1.4),
      em: TextStyle(fontStyle: FontStyle.italic, color: textColor),
      strong: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      del: TextStyle(decoration: TextDecoration.lineThrough, color: isDark ? Colors.white54 : Colors.black54),
      a: TextStyle(color: primaryColor, decoration: TextDecoration.underline, decorationColor: primaryColor.withValues(alpha: 0.5)),
      
      // Quotes (Fix for thick blue panel issue)
      blockquote: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : Colors.black87, fontStyle: FontStyle.normal, height: 1.6),
      blockquoteDecoration: BoxDecoration(
        color: isDark ? primaryColor.withValues(alpha: 0.1) : primaryColor.withValues(alpha: 0.05),
        border: Border(left: BorderSide(color: primaryColor, width: 4)),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      
      // Code
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: isDark ? const Color(0xFFE5C07B) : const Color(0xFFC678DD),
        backgroundColor: Colors.transparent,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      
      // Lists
      listBullet: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
      listIndent: 24,
      
      // Horizontal Rule (Fix for super thick black line issue)
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1.0, // Fixed 1px thin line
          ),
        ),
      ),
      
      // Tables
      tableBorder: TableBorder.all(color: isDark ? Colors.white24 : Colors.black26, width: 1),
      tableCellsPadding: const EdgeInsets.all(8),
      
      blockSpacing: 16, // Space between paragraphs
    );
  }

  Widget _buildChatBubble(ChatMessage message, bool isDark) {
    final isUser = message.type == ChatMessageType.user;
    final isError = message.type == ChatMessageType.error;
    final isSystem = message.type == ChatMessageType.system;

    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isError ? Colors.red.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(
                isError ? Icons.error_outline : Icons.smart_toy_rounded, 
                size: 16, 
                color: isError ? Colors.red : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                    ? Theme.of(context).primaryColor 
                    : (isError 
                        ? Colors.red.withValues(alpha: 0.1) 
                        : (isDark ? const Color(0xFF2A2A2A) : Colors.white)), // Slightly tweaked AI bubble color for elegance
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 24),
                ),
                boxShadow: isUser || isError ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06), // Smoother shadow
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isUser 
                ? Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  )
                : MarkdownBody(
                    data: message.text,
                    selectable: true, // Allow user to copy AI text!
                    styleSheet: _buildPremiumMarkdownStyleSheet(context, isDark, isError),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('欲開啟外部連結：$href'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble(AiChatSessionState sessionState, bool isDark) {
    if (!sessionState.isProcessing) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Icon(Icons.smart_toy_outlined, size: 16, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThinkingOrb(isDark: isDark, size: 24.0),
                  const SizedBox(width: 12),
                  Text(
                    'AI 思考中...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(AiChatSessionState sessionState, VoiceState voiceState, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        scrollController: _textFieldScrollController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: voiceState.isListening 
                              ? '聆聽中...' 
                              : '輸入想進一步探討的問題...',
                          hintStyle: TextStyle(
                            color: voiceState.isListening ? Theme.of(context).primaryColor : (isDark ? Colors.white30 : Colors.black38),
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _handleSubmit(),
                      ),
                    ),
                    if (voiceState.isListening)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ThinkingOrb(isDark: isDark, size: 24),
                      ),
                    GestureDetector(
                      onLongPress: () {
                        if (!voiceState.isListening) {
                          _handleMicToggle(voiceState.isListening);
                        }
                      },
                      onLongPressUp: () {
                        ref.read(voiceControllerProvider.notifier).stopListening();
                      },
                      onTap: () {
                        _handleMicToggle(voiceState.isListening);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: voiceState.isListening ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          voiceState.isListening ? Icons.mic : Icons.mic_none,
                          color: voiceState.isListening ? Theme.of(context).primaryColor : (isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send_rounded, color: Theme.of(context).primaryColor),
                      onPressed: _handleSubmit,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
