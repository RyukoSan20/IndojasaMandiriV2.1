import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class BackupRestoreService {
  static Future<String> get _backupDirectoryPath async {
    final directory = Directory('/storage/emulated/0/FinTrack/backup');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  static Future<File?> exportBackup(Map<String, dynamic> dbData) async {
    if (!await requestStoragePermission()) return null;
    final path = await _backupDirectoryPath;
    final fileName = 'fintrack_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('$path/$fileName');
    return await file.writeAsString(jsonEncode(dbData));
  }

  static Future<Map<String, dynamic>?> importBackup(File backupFile) async {
    try {
      final jsonString = await backupFile.readAsString();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
