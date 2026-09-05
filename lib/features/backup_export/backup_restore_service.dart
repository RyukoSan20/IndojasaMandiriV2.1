import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../../data/local/database_helper.dart';

class BackupRestoreService {
  static const String _backupFolder = '/storage/emulated/0/FinTrack/backup';

  static Future<Directory> _getBackupDirectory() async {
    final dir = Directory(_backupFolder);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // Ekspor Database SQLite ke File JSON
  static Future<String?> exportBackup() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) return null;
    }

    final db = await DatabaseHelper.instance.database;
    final user = await db.query('user_profile');
    final accounts = await db.query('accounts');
    final transactions = await db.query('transactions');
    final goals = await db.query('savings_goals');

    final Map<String, dynamic> snapshot = {
      'app': 'FinTrack',
      'version': '2.1',
      'exported_at': DateTime.now().toIso8601String(),
      'user_profile': user,
      'accounts': accounts,
      'transactions': transactions,
      'savings_goals': goals,
    };

    final dir = await _getBackupDirectory();
    final fileName = 'fintrack_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(jsonEncode(snapshot));
    return file.path;
  }

  // Pulihkan Data dari File JSON Snapshot
  static Future<bool> restoreBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      final db = await DatabaseHelper.instance.database;

      await db.transaction((txn) async {
        await txn.delete('user_profile');
        await txn.delete('accounts');
        await txn.delete('transactions');
        await txn.delete('savings_goals');

        for (var row in (data['user_profile'] as List? ?? [])) {
          await txn.insert('user_profile', Map<String, dynamic>.from(row));
        }
        for (var row in (data['accounts'] as List? ?? [])) {
          await txn.insert('accounts', Map<String, dynamic>.from(row));
        }
        for (var row in (data['transactions'] as List? ?? [])) {
          await txn.insert('transactions', Map<String, dynamic>.from(row));
        }
        for (var row in (data['savings_goals'] as List? ?? [])) {
          await txn.insert('savings_goals', Map<String, dynamic>.from(row));
        }
      });

      return true;
    } catch (_) {
      return false;
    }
  }
}
