

abstract class IBackupService {
  /// 匯出全系統歷史紀錄，回傳備份檔案的絕對路徑，若取消或失敗回傳 null
  Future<String?> exportBackup();

  /// 匯入備份檔案，回傳是否成功
  Future<bool> importBackup();
}
