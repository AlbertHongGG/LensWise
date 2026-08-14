import 'dart:math';
import 'package:lens_wise/features/ai/infrastructure/logger/base_file_logger.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';

class AIAgentLogger extends BaseFileLogger<Map<String, dynamic>> {
  final AiAgentType? agentType;

  AIAgentLogger([this.agentType]) : super('agent');

  @override
  String getFileName() {
    final parts = getTimestampParts();
    final yyyymmdd = parts['yyyymmdd'];
    final hhmmss = parts['hhmmss'];
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    final typeId = agentType?.id ?? 'SystemViewer';
    return '${yyyymmdd}_${hhmmss}_${typeId}_$random.json';
  }

  void logInteraction(dynamic request, dynamic response, int startTime) {
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final durationMs = endTime - startTime;

    final logData = {
      'timestamp': getLocalISOString(DateTime.now()),
      'agentName': agentType?.id ?? 'SystemViewer',
      'durationMs': durationMs,
      'request': request,
      'response': response,
    };

    this.log(logData);
  }
}
