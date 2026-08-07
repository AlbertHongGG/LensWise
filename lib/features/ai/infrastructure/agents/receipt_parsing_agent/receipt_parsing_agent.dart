import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/console_ai_logger.dart';
import 'prompts.dart';

class ReceiptParsingResult {
  final String status;
  final String? message;
  final Map<String, dynamic>? data;

  ReceiptParsingResult({required this.status, this.message, this.data});

  factory ReceiptParsingResult.fromJson(Map<String, dynamic> json) {
    return ReceiptParsingResult(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class ReceiptParsingAgent extends BaseAgent<List<Uint8List>, ReceiptParsingResult> {
  ReceiptParsingAgent(super.agentName, super.provider, super.logger);

  @override
  Future<ReceiptParsingResult> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildReceiptParsingSystemPrompt(),
      prompt: buildReceiptParsingUserPrompt(),
      images: input,
    );

    final responseText = await executePrompt(request);
    
    try {
      final jsonMap = extractJson<Map<String, dynamic>>(responseText);
      return ReceiptParsingResult.fromJson(jsonMap);
    } catch (e) {
      return ReceiptParsingResult(
        status: 'needs_more_info', 
        message: '收據解析失敗，請確保照片清晰且文字未被裁切。'
      );
    }
  }
}

final receiptParsingAgentProvider = Provider.autoDispose<ReceiptParsingAgent>((ref) {
  return ReceiptParsingAgent(
    'ReceiptParsing',
    ref.watch(aiProviderProvider),
    ref.watch(aiLoggerProvider),
  );
});
