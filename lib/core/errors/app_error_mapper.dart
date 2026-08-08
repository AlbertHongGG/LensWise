import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AppErrorMapper {
  static String map(dynamic error) {
    if (error == null) return '發生未知錯誤';
    
    final errorStr = error.toString();
    
    if (errorStr.contains('SocketException') || errorStr.contains('Connection refused')) {
      return '網路連線失敗，請檢查網路狀態。';
    }
    
    if (errorStr.contains('TimeoutException')) {
      return '系統回應逾時，請稍後重試。';
    }

    if (errorStr.contains('FormatException') || errorStr.contains('Exception: 解析 JSON 失敗')) {
      return '資料解析異常，請重新拍攝。';
    }

    if (errorStr.contains('AIConnectionError')) {
      return 'AI 服務連線失敗。';
    }

    // Custom validation errors
    if (errorStr.contains('AI 代理已停用')) {
      return errorStr;
    }

    if (kDebugMode) {
      return errorStr;
    }
    
    return '發生未知的系統錯誤，請稍後再試。';
  }
}
