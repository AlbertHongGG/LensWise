import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/receipt_parsing_agent/receipt_parsing_agent.dart';
import 'package:lens_wise/core/storage/i_local_storage_repository.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';

class ReceiptScannerService {
  final ReceiptParsingAgent _agent;
  final ILocalStorageRepository<ReceiptRecord> _repository;
  final LocalMediaService _mediaService;

  ReceiptScannerService(this._agent, this._repository, this._mediaService);

  /// 執行發票解析並自動將成功的結果存入歷史紀錄 (Application Layer Orchestration)
  Future<ReceiptParsingResult> analyzeAndSave(Uint8List imageBytes) async {
    final result = await _agent.execute(imageBytes);

    if (result.status == 'success' && result.data != null) {
      try {
        final imagePath = await _mediaService.saveImage(imageBytes);
        final record = ReceiptRecord.fromAnalysisData(result.data!, imagePath: imagePath);
        await _repository.save(record.id, record);
      } catch (e) {
        print('Error saving receipt to history: $e');
      }
    }

    return result;
  }
}

final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  return ReceiptScannerService(
    ref.watch(receiptParsingAgentProvider),
    ref.watch(receiptRepositoryProvider),
    ref.watch(localMediaServiceProvider),
  );
});
