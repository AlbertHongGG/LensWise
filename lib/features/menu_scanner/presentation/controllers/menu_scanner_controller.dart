import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/menu_scanner_agent/menu_scanner_agent.dart';
import 'package:lens_wise/features/menu_scanner/application/menu_scanner_service.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_config_controller.dart';

enum MenuScannerStatus {
  idle,
  connecting, // 等待首個 Token (TTFT)
  streaming,  // 首個 Token 抵達，進入 ResultPage 漸進展開品項
  success,    // 串流結束且儲存完畢
  error,      // 錯誤
}

class MenuScannerState {
  final List<AppImageEntity> capturedImages;
  final MenuScannerStatus status;
  final String? errorMessage;
  final MenuScannerRecord? parsingResult;
  final bool isStreamingComplete;

  MenuScannerState({
    this.capturedImages = const [],
    this.status = MenuScannerStatus.idle,
    this.errorMessage,
    this.parsingResult,
    this.isStreamingComplete = false,
  });

  bool get isAnalyzing => status == MenuScannerStatus.connecting || status == MenuScannerStatus.streaming;

  MenuScannerState copyWith({
    List<AppImageEntity>? capturedImages,
    MenuScannerStatus? status,
    String? errorMessage,
    MenuScannerRecord? parsingResult,
    bool? isStreamingComplete,
  }) {
    return MenuScannerState(
      capturedImages: capturedImages ?? this.capturedImages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      parsingResult: parsingResult ?? this.parsingResult,
      isStreamingComplete: isStreamingComplete ?? this.isStreamingComplete,
    );
  }
}

class MenuScannerController extends Notifier<MenuScannerState> {
  StreamSubscription<StreamingSnapshot<MenuScannerRecord>>? _streamSub;

  @override
  MenuScannerState build() {
    ref.onDispose(() {
      _streamSub?.cancel();
    });
    return MenuScannerState();
  }

  void reset() {
    _streamSub?.cancel();
    _streamSub = null;
    if (ref.mounted) {
      state = MenuScannerState();
    }
  }

  Future<void> analyzeMenu(List<AppImageEntity> images) async {
    if (images.isEmpty) return;

    final aiState = ref.read(aiConfigControllerProvider);
    if (!aiState.isAIAgentEnabled) {
      state = state.copyWith(
        status: MenuScannerStatus.error,
        errorMessage: 'AI 輔助未啟用，請至設定開啟。',
      );
      ref.read(notificationProvider.notifier).showError('AI 輔助未啟用，請至設定開啟。');
      return;
    }

    await _streamSub?.cancel();

    state = state.copyWith(
      capturedImages: images,
      status: MenuScannerStatus.connecting,
      errorMessage: null,
      parsingResult: MenuScannerRecord.empty(),
      isStreamingComplete: false,
    );

    try {
      final agent = ref.read(menuScannerAgentProvider);
      final service = ref.read(menuScannerServiceProvider);
      final bytesList = images.map((e) => e.bytes).toList();

      final stream = agent.executeStreamSnapshot(bytesList);

      _streamSub = stream.listen(
        (snapshot) async {
          final isDone = snapshot.isComplete;

          state = state.copyWith(
            status: isDone ? MenuScannerStatus.success : MenuScannerStatus.streaming,
            parsingResult: snapshot.data,
            isStreamingComplete: isDone,
          );

          if (isDone) {
            try {
              final saved = await service.saveCompletedRecord(snapshot.data, bytesList);
              ref.invalidate(menuHistoryProvider);
              state = state.copyWith(parsingResult: saved);
            } catch (_) {}
          }
        },
        onError: (e) {
          state = state.copyWith(
            status: MenuScannerStatus.error,
            errorMessage: e.toString(),
          );
          ref.read(notificationProvider.notifier).showError('菜單分析失敗：$e');
        },
        onDone: () {},
      );
    } catch (e) {
      state = state.copyWith(
        status: MenuScannerStatus.error,
        errorMessage: e.toString(),
      );
      ref.read(notificationProvider.notifier).showError('菜單分析失敗：$e');
    }
  }
}

final menuScannerControllerProvider = NotifierProvider<MenuScannerController, MenuScannerState>(() {
  return MenuScannerController();
});
