import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/core/models/target_language.dart';
import 'prompts.dart';

abstract class IMenuScannerAgent {
  Future<MenuScannerRecord> execute(List<Uint8List> input);
  Stream<StreamingSnapshot<MenuScannerRecord>> executeStreamSnapshot(List<Uint8List> input);
}

class _MenuResponseDto {
  final String status;
  final String? message;
  final Map<String, dynamic>? data;

  _MenuResponseDto({required this.status, this.message, this.data});

  factory _MenuResponseDto.fromJson(Map<String, dynamic> json) {
    return _MenuResponseDto(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class MenuScannerAgent extends BaseAgent<List<Uint8List>, MenuScannerRecord> implements IMenuScannerAgent {
  final TargetLanguage targetLanguage;

  MenuScannerAgent(
    super.agentType,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

  MenuScannerRecord _mapJsonToRecord(Map<String, dynamic> jsonMap) {
    try {
      final dto = _MenuResponseDto.fromJson(jsonMap);
      final data = dto.data;
      if (data == null) {
        return MenuScannerRecord.empty();
      }
      final itemsList = (data['items'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => MenuScannerItem(
                    originalName: e['originalName'] as String? ?? '',
                    translatedName: e['translatedName'] as String? ?? '',
                    description: e['description'] as String?,
                    price: (e['price'] is num) ? (e['price'] as num).toDouble() : 0.0,
                  ))
              .toList() ??
          const [];

      return MenuScannerRecord(
        id: '',
        timestamp: DateTime.now(),
        imagePaths: const [],
        storeName: data['storeName'] as String? ?? '',
        items: itemsList,
        translatedImagePaths: const {},
      );
    } catch (_) {
      return MenuScannerRecord.empty();
    }
  }

  @override
  Stream<StreamingSnapshot<MenuScannerRecord>> executeStreamSnapshot(List<Uint8List> input) {
    final request = GenerateRequest(
      systemPrompt: buildMenuScannerSystemPrompt(targetLanguage),
      prompt: buildMenuScannerUserPrompt(),
      images: input,
    );

    return executeStreamingPipeline(
      request: request,
      mapper: _mapJsonToRecord,
      initialData: MenuScannerRecord.empty(),
    );
  }

  @override
  Future<MenuScannerRecord> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildMenuScannerSystemPrompt(targetLanguage),
      prompt: buildMenuScannerUserPrompt(),
      images: input,
    );

    final response = await executePrompt(request);
    final responseText = response.text;

    try {
      final jsonMap = extractJson<Map<String, dynamic>>(responseText);
      final dto = _MenuResponseDto.fromJson(jsonMap);

      if (dto.status != 'success' || dto.data == null) {
        throw Exception(dto.message ?? '解析過程發生錯誤');
      }

      return MenuScannerRecord(
        id: '', // Will be assigned by service
        timestamp: DateTime.now(),
        imagePaths: const [], // Will be assigned by service
        storeName: dto.data!['storeName'] as String? ?? '未知餐廳菜單',
        items: (dto.data!['items'] as List<dynamic>?)
                ?.map((e) => MenuScannerItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e, stack) {
      print('Failed to parse AI response: $e\n$stack');
      throw Exception('解析或比對過程發生錯誤: $e\n請確認照片是否清晰且包含菜單。');
    }
  }
}

final menuScannerAgentProvider = Provider.autoDispose<IMenuScannerAgent>((ref) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return MenuScannerAgent(
    AiAgentType.menuScanner,
    ref.watch(aiProviderFamily(AiAgentType.menuScanner)),
    ref.watch(aiAgentLoggerProvider(AiAgentType.menuScanner)),
    targetLanguage: language,
  );
});
