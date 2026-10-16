import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'package:lens_wise/core/models/target_language.dart';
import 'prompts.dart';

import 'package:lens_wise/features/receipt_scanner/domain/interfaces/i_receipt_scanner_agent.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';

class _ReceiptScannerResponseDto {
  final String status;
  final String? message;
  final _ReceiptScannerDataDto? data;

  _ReceiptScannerResponseDto({required this.status, this.message, this.data});

  factory _ReceiptScannerResponseDto.fromJson(Map<String, dynamic> json) {
    return _ReceiptScannerResponseDto(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] != null ? _ReceiptScannerDataDto.fromJson(json['data']) : null,
    );
  }
}

class _ReceiptScannerDataDto {
  final String? receiptDate;
  final String? storeName;
  final String? currency;
  final double subtotal;
  final List<ReceiptItem> items;
  final List<ReceiptFeeItem> discounts;
  final List<ReceiptFeeItem> taxes;
  final double totalAmount;

  _ReceiptScannerDataDto.fromJson(Map<String, dynamic> json)
      : receiptDate = json['receiptDate'] as String?,
        storeName = json['storeName'] as String?,
        currency = json['currency'] as String?,
        subtotal = _parseDouble(json['subtotal']),
        items = (json['items'] as List<dynamic>?)?.map((e) => ReceiptItem.fromJson(e)).toList() ?? [],
        discounts = (json['discounts'] as List<dynamic>?)?.map((e) => ReceiptFeeItem.fromJson(e)).toList() ?? [],
        taxes = (json['taxes'] as List<dynamic>?)?.map((e) => ReceiptFeeItem.fromJson(e)).toList() ?? [],
        totalAmount = _parseDouble(json['totalAmount']);

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class ReceiptScannerAgent extends BaseAgent<List<Uint8List>, ReceiptScannerRecord> implements IReceiptScannerAgent {
  final TargetLanguage targetLanguage;

  ReceiptScannerAgent(
    super.agentType,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

  ReceiptScannerRecord _mapJsonToRecord(Map<String, dynamic> jsonMap) {
    try {
      final dto = _ReceiptScannerResponseDto.fromJson(jsonMap);
      final data = dto.data;
      if (data == null) {
        return ReceiptScannerRecord.empty();
      }
      return ReceiptScannerRecord(
        id: '',
        timestamp: DateTime.now(),
        receiptDate: data.receiptDate,
        storeName: data.storeName ?? '',
        currency: data.currency,
        subtotal: data.subtotal,
        items: data.items,
        discounts: data.discounts,
        taxes: data.taxes,
        totalAmount: data.totalAmount,
        imagePaths: const [],
      );
    } catch (_) {
      return ReceiptScannerRecord.empty();
    }
  }

  @override
  Stream<StreamingSnapshot<ReceiptScannerRecord>> executeStreamSnapshot(List<Uint8List> input) {
    final request = GenerateRequest(
      systemPrompt: buildReceiptParsingSystemPrompt(targetLanguage),
      prompt: buildReceiptParsingUserPrompt(),
      images: input,
    );

    return executeStreamingPipeline(
      request: request,
      mapper: _mapJsonToRecord,
      initialData: ReceiptScannerRecord.empty(),
    );
  }

  @override
  Future<ReceiptScannerRecord> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildReceiptParsingSystemPrompt(targetLanguage), // Will leave prompts intact
      prompt: buildReceiptParsingUserPrompt(),
      images: input,
    );

    final response = await executePrompt(request);
    final responseText = response.text;

    try {
      final jsonMap = extractJson<Map<String, dynamic>>(responseText);
      final dto = _ReceiptScannerResponseDto.fromJson(jsonMap);

      if (dto.status != 'success' || dto.data == null) {
        throw Exception(dto.message ?? '解析過程發生錯誤');
      }

      final data = dto.data!;
      return ReceiptScannerRecord(
        id: '', // Placeholder, populated by Service
        timestamp: DateTime.now(), // Placeholder, populated by Service
        receiptDate: data.receiptDate,
        storeName: data.storeName ?? '',
        currency: data.currency,
        subtotal: data.subtotal,
        items: data.items,
        discounts: data.discounts,
        taxes: data.taxes,
        totalAmount: data.totalAmount,
        imagePaths: [], // Placeholder, populated by Service
      );
    } catch (e) {
      throw Exception('收據解析失敗，請確保照片清晰且文字未被裁切。');
    }
  }
}

final receiptScannerAgentProvider = Provider.autoDispose<IReceiptScannerAgent>((ref) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return ReceiptScannerAgent(
    AiAgentType.receiptScanner,
    ref.watch(aiProviderFamily(AiAgentType.receiptScanner)),
    ref.watch(aiAgentLoggerProvider(AiAgentType.receiptScanner)),
    targetLanguage: language,
  );
});
