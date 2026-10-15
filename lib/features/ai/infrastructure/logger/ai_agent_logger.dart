import 'dart:math' show Random;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/logging/base_file_logger.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';

class AIAgentLogger extends BaseFileLogger<Map<String, dynamic>> {
  final AiAgentType? agentType;

  AIAgentLogger({this.agentType, super.isEnabled}) : super('agent');

  @override
  String getFileName() {
    final parts = getTimestampParts();
    final yyyymmdd = parts['yyyymmdd'];
    final hhmmss = parts['hhmmss'];
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    if (agentType == null) throw Exception('agentType is required for writing logs');
    return '${yyyymmdd}_${hhmmss}_${agentType!.id}_$random.json';
  }

  void logInteraction(dynamic request, dynamic response, int startTime) {
    // 守門檢查：如果關閉記錄，直接返回，避免後續 Map 構建與 log 調用
    if (isEnabled != null && !isEnabled!()) {
      return;
    }

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final durationMs = endTime - startTime;

    final logData = {
      'timestamp': getLocalISOString(DateTime.now()),
      'agentName': agentType?.id ?? 'Unknown',
      'durationMs': durationMs,
      'request': request,
      'response': response,
    };

    log(logData);
  }
}

final aiAgentLoggerProvider = Provider.family<AIAgentLogger, AiAgentType>((ref, type) {
  return AIAgentLogger(
    agentType: type,
    isEnabled: () => ref.read(settingsProvider).enableAiLog,
  );
});
