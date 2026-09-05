import '../local/database_helper.dart';

class TransactionRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 20}) async {
    final db = await dbHelper.database;
    return await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  Future<void> insertTransaction(Map<String, dynamic> txData) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('transactions', txData);
      
      // Update saldo akun terkait secara otomatis
      final isIncome = txData['type'] == 'income';
      final amount = (txData['amount'] as num).toDouble();
      final accountId = txData['account_id'] as String;

      final accResult = await txn.query('accounts', where: 'id = ?', whereArgs: [accountId]);
      if (accResult.isNotEmpty) {
        double currentBalance = (accResult.first['balance'] as num).toDouble();
        double updatedBalance = isIncome ? currentBalance + amount : currentBalance - amount;
        await txn.update(
          'accounts',
          {'balance': updatedBalance},
          where: 'id = ?',
          whereArgs: [accountId],
        );
      }
    });
  }
}
