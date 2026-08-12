import 'dart:io';

class AiLogModel {
  final FileSystemEntity file;
  final String title;
  final String agentName;
  final DateTime dateTime;

  AiLogModel({
    required this.file,
    required this.title,
    required this.agentName,
    required this.dateTime,
  });

  factory AiLogModel.fromFile(FileSystemEntity file) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final parts = fileName.split('_');
    
    String title = fileName;
    String agentName = 'Unknown';
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(0);
    
    if (parts.length >= 2) {
      try {
        final dateStr = parts[0];
        final timeStr = parts[1];
        
        if (dateStr.length == 8 && timeStr.length >= 6) {
          final year = int.parse(dateStr.substring(0, 4));
          final month = int.parse(dateStr.substring(4, 6));
          final day = int.parse(dateStr.substring(6, 8));
          final hour = int.parse(timeStr.substring(0, 2));
          final min = int.parse(timeStr.substring(2, 4));
          final sec = int.parse(timeStr.substring(4, 6));
          
          dt = DateTime(year, month, day, hour, min, sec);
        }
        
        if (parts.length >= 4) {
          title = parts[2];
          agentName = parts[2];
        }
      } catch (_) {
        dt = file.statSync().modified;
      }
    } else {
      dt = file.statSync().modified;
    }
    
    return AiLogModel(
      file: file,
      title: title,
      agentName: agentName,
      dateTime: dt,
    );
  }
}
