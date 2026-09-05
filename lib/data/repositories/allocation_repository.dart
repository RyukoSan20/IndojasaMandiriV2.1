import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';

class AllocationRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<void> saveAllocationRule({
    required double needsRatio,
    required double wantsRatio,
    required double investRatio,
    required double emergencyRatio,
  }) async {
    final db = await dbHelper.database;
    await db.insert(
      'allocation_rules',
      {
        'id': 'default_rule',
        'needs_ratio': needsRatio,
        'wants_ratio': wantsRatio,
        'invest_ratio': investRatio,
        'emergency_ratio': emergencyRatio,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, double>> getAllocationRule() async {
    final db = await dbHelper.database;
    final result = await db.query('allocation_rules', where: 'id = ?', whereArgs: ['default_rule']);
    if (result.isNotEmpty) {
      final row = result.first;
      return {
        'needs': (row['needs_ratio'] as num).toDouble(),
        'wants': (row['wants_ratio'] as num).toDouble(),
        'invest': (row['invest_ratio'] as num).toDouble(),
        'emergency': (row['emergency_ratio'] as num).toDouble(),
      };
    }
    return {'needs': 0.50, 'wants': 0.05, 'invest': 0.30, 'emergency': 0.15};
  }
}
