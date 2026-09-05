import '../local/database_helper.dart';
import '../../models/account_model.dart';

class AccountRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Account>> getAllAccounts() async {
    final db = await dbHelper.database;
    final result = await db.query('accounts');
    return result.map((json) => Account(
      id: json['id'] as String,
      name: json['name'] as String,
      category: AccountCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AccountCategory.bank,
      ),
      balance: (json['balance'] as num).toDouble(),
      currencyCode: json['currency_code'] as String? ?? 'IDR',
      bankName: json['bank_name'] as String?,
    )).toList();
  }

  Future<void> insertAccount(Account account) async {
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
