import '../local/database_helper.dart';
import '../../models/account_model.dart';

class AccountRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<AccountModel>> getAllAccounts() async {
    final db = await dbHelper.database;
    final res = await db.query('accounts', where: 'is_active = 1');
    return res.map((e) => AccountModel.fromJson(e)).toList();
  }

  Future<void> saveAccount(AccountModel account) async {
    final db = await dbHelper.database;
    await db.insert('accounts', account.toMap());
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    final db = await dbHelper.database;
    await db.update(
      'accounts',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }
}
