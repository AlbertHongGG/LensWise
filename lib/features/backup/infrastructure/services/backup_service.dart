import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import 'package:lens_wise/features/backup/domain/services/i_backup_service.dart';
import 'package:lens_wise/features/backup/domain/models/backup_archive.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';

class BackupService implements IBackupService {
  final Ref ref;

  BackupService(this.ref);

  Future<Directory> _getMediaDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${directory.path}/lens_wise_media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir;
  }

  void _collectImages(List<IHistoryRecord> records, Set<String> imageFilesToCopy) {
    for (final r in records) {
      if (r.deletionImagePath != null && r.deletionImagePath!.isNotEmpty) {
        final paths = r.deletionImagePath!.split(',');
        for (final p in paths) {
          if (p.trim().isNotEmpty) {
            imageFilesToCopy.add(p.contains(RegExp(r'[/\\]')) ? p.split(RegExp(r'[/\\]')).last : p.trim());
          }
        }
      }
      if (r.deletionImagePaths != null) {
        for (final p in r.deletionImagePaths!) {
          if (p.trim().isNotEmpty) {
            imageFilesToCopy.add(p.contains(RegExp(r'[/\\]')) ? p.split(RegExp(r'[/\\]')).last : p.trim());
          }
        }
      }
    }
  }

  @override
  Future<String?> exportBackup() async {
    try {
      final receiptRepo = ref.read(receiptScannerRepositoryProvider);
      final productRepo = ref.read(productLensRepositoryProvider);
      final comparisonRepo = ref.read(productComparisonRepositoryProvider);
      final menuRepo = ref.read(menuScannerRepositoryProvider);

      final receipts = await receiptRepo.getAll();
      final products = await productRepo.getAll();
      final comparisons = await comparisonRepo.getAll();
      final menus = await menuRepo.getAll();

      final archive = BackupArchive(
        exportedAt: DateTime.now(),
        appVersion: '1.0.0', // You can dynamically get this via package_info_plus if needed
        receiptRecords: receipts,
        productLensRecords: products,
        comparisonRecords: comparisons,
        menuRecords: menus,
      );

      final tempDir = await getTemporaryDirectory();
      final backupDir = Directory('${tempDir.path}/lenswise_backup_temp');
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
      await backupDir.create();

      // 1. Write JSON data
      final jsonFile = File('${backupDir.path}/backup_data.json');
      await jsonFile.writeAsString(jsonEncode(archive.toJson()));

      // 2. Collect & Copy Images
      final Set<String> imagesToCopy = {};
      _collectImages(receipts, imagesToCopy);
      _collectImages(products, imagesToCopy);
      _collectImages(comparisons, imagesToCopy);
      _collectImages(menus, imagesToCopy);

      final imagesDir = Directory('${backupDir.path}/images');
      await imagesDir.create();
      final mediaDir = await _getMediaDir();

      for (final imgName in imagesToCopy) {
        final sourceFile = File('${mediaDir.path}/$imgName');
        if (await sourceFile.exists()) {
          await sourceFile.copy('${imagesDir.path}/$imgName');
        }
      }

      // 3. Zip the directory
      final encoder = ZipFileEncoder();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final zipPath = '${tempDir.path}/LensWise_Backup_$dateStr.zip';
      
      encoder.create(zipPath);
      encoder.addDirectory(backupDir);
      encoder.close();

      // Clean up temp backup dir
      await backupDir.delete(recursive: true);

      // 4. Save file via FilePicker
      final bytes = await File(zipPath).readAsBytes();
      final Uri? outputFileUri = await FilePicker.saveFile(
        dialogTitle: '儲存備份檔案',
        fileName: 'LensWise_Backup_$dateStr.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
        bytes: bytes,
      );

      // Clean up temp zip
      await File(zipPath).delete();

      if (outputFileUri == null) {
        // User canceled
        throw Exception('User canceled');
      }
      
      return outputFileUri.toString();
    } catch (e) {
      print('Backup export failed: $e');
      return null;
    }
  }

  @override
  Future<bool> importBackup() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null) {
      throw Exception('User canceled');
    }
      
    final zipPath = result.path;
    if (zipPath == null) {
      throw Exception('無法獲取選擇的檔案路徑');
    }

      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory('${tempDir.path}/lenswise_extract_temp');
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create();

      // 1. Unzip
      final bytes = File(zipPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File('${extractDir.path}/$filename');
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(data);
        } else {
          await Directory('${extractDir.path}/$filename').create(recursive: true);
        }
      }

      // Find the JSON file (it might be inside a subfolder if zipped differently)
      File? jsonFile;
      await for (final entity in extractDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('backup_data.json')) {
          jsonFile = entity;
          break;
        }
      }

      if (jsonFile == null) {
        throw Exception('Invalid backup format: backup_data.json not found');
      }

      // 2. Parse JSON
      final jsonString = await jsonFile.readAsString();
      final backupData = BackupArchive.fromJson(jsonDecode(jsonString));

      // 3. Copy Images
      final mediaDir = await _getMediaDir();
      final jsonDir = jsonFile.parent;
      final imagesDir = Directory('${jsonDir.path}/images');
      
      if (await imagesDir.exists()) {
        await for (final entity in imagesDir.list()) {
          if (entity is File) {
            final filename = entity.uri.pathSegments.last;
            await entity.copy('${mediaDir.path}/$filename');
          }
        }
      }

      // 4. Save to Repositories
      final receiptRepo = ref.read(receiptScannerRepositoryProvider);
      for (final r in backupData.receiptRecords) {
        await receiptRepo.save(r.id, r);
      }

      final productRepo = ref.read(productLensRepositoryProvider);
      for (final r in backupData.productLensRecords) {
        await productRepo.save(r.id, r);
      }

      final comparisonRepo = ref.read(productComparisonRepositoryProvider);
      for (final r in backupData.comparisonRecords) {
        await comparisonRepo.save(r.id, r);
      }

      final menuRepo = ref.read(menuScannerRepositoryProvider);
      for (final r in backupData.menuRecords) {
        await menuRepo.save(r.id, r);
      }

    // Clean up extract dir
    await extractDir.delete(recursive: true);

    return true;
  }
}

final backupServiceProvider = Provider<IBackupService>((ref) {
  return BackupService(ref);
});
