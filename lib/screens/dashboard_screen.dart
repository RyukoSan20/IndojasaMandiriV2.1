import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../features/onboarding/onboarding_tour_dialog.dart';
import '../features/backup_export/backup_restore_service.dart';
import '../services/calendar_sync_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.loadInitialData();
      if (!provider.isOnboarded) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => OnboardingTourDialog(
            onComplete: ({required name, required currency, required income, required hasIncome, required useFormula, required goalType}) async {
              await provider.completeOnboarding(
                name: name,
                currency: currency,
                income: income,
                hasIncome: hasIncome,
                useFormula: useFormula,
                goalType: goalType,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inisialisasi FinTrack & Alokasi 50/5/30/15 Berhasil!'), backgroundColor: Colors.green),
              );
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selamat Pagi', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(provider.userName.isEmpty ? 'Pengguna Baru' : provider.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () async {
              await CalendarSyncService.syncBudgetPlanToCalendar(
                title: 'Review FinTrack Goals',
                targetDate: DateTime.now().add(const Duration(days: 7)),
                targetAmount: provider.totalBalance,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal tersinkronisasi dengan Google Calendar')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white),
            onPressed: () async {
              final path = await BackupRestoreService.exportBackup();
              if (!mounted) return;
              if (path != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup tersimpan di: $path')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal backup. Periksa izin penyimpanan.')));
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(provider),
            const SizedBox(height: 20),
            _buildActionButtons(context, provider),
            const SizedBox(height: 24),
            const Text('Arus Kas & Mutasi Relasional', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTransactionList(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saldo Bersih', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('${provider.currency} ${provider.totalBalance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubBalance('Tunai & Bank', provider.cashAndBankBalance, provider.currency),
              _buildSubBalance('Portofolio Investasi', provider.totalPortfolioValue, provider.currency),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSubBalance(String label, double amount, String currency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 2),
          Text('$currency ${amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(context, Icons.add, 'Pemasukan', const Color(0xFF10B981), () => _showTransactionDialog(context, provider, true)),
        _buildActionButton(context, Icons.remove, 'Pengeluaran', const Color(0xFFEF4444), () => _showTransactionDialog(context, provider, false)),
        _buildActionButton(context, Icons.swap_horiz, 'Transfer', const Color(0xFFF59E0B), () => _showTransferDialog(context, provider)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.29,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, AppProvider provider, bool isIncome) {
    if (provider.accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun belum tersedia. Selesaikan onboarding.')));
      return;
    }
    String selectedAccount = provider.accounts.first.id;
    final amountController = TextEditingController();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(isIncome ? 'Tambah Pemasukan' : 'Catat Pengeluaran', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedAccount,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              items: provider.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currency})'))).toList(),
              onChanged: (val) {
                if (val != null) selectedAccount = val;
              },
              decoration: const InputDecoration(labelText: 'Akun Sumber', labelStyle: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 12),
            TextField(controller: titleController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Deskripsi', labelStyle: TextStyle(color: Colors.grey))),
            const SizedBox(height: 12),
            TextField(controller: amountController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nominal', labelStyle: TextStyle(color: Colors.grey))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text) ?? 0.0;
              if (amt > 0) {
                provider.addTransaction(
                  accountId: selectedAccount,
                  title: titleController.text.isEmpty ? (isIncome ? 'Pemasukan' : 'Pengeluaran') : titleController.text,
                  amount: amt,
                  isIncome: isIncome,
                  category: isIncome ? 'Gaji' : 'Kebutuhan',
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context, AppProvider provider) {
    if (provider.accounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dibutuhkan minimal 2 akun untuk transfer.')));
      return;
    }
    String fromAccount = provider.accounts[0].id;
    String toAccount = provider.accounts[1].id;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Transfer Antar Akun', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: fromAccount,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: provider.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.balance.toStringAsFixed(0)})'))).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => fromAccount = val);
                },
                decoration: const InputDecoration(labelText: 'Dari Akun', labelStyle: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: toAccount,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: provider.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.balance.toStringAsFixed(0)})'))).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => toAccount = val);
                },
                decoration: const InputDecoration(labelText: 'Ke Akun', labelStyle: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 12),
              TextField(controller: amountController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Jumlah', labelStyle: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text) ** 0.0; // Fixed fallback or parse
              final parsedAmt = double.tryParse(amountController.text) ?? 0.0;
              if (parsedAmt > 0) {
                provider.transferFunds(fromAccountId: fromAccount, toAccountId: toAccount, amount: parsedAmt);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(AppProvider provider) {
    if (provider.transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text('Belum ada transaksi terekam.\nSeluruh data murni dari input Anda.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.transactions.length,
      itemBuilder: (context, index) {
        final tx = provider.transactions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: tx.isIncome ? Colors.teal : Colors.redAccent),
            title: Text(tx.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            subtitle: Text(tx.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Text(
              '${tx.isIncome ? '+' : '-'}${provider.currency} ${tx.amount.toStringAsFixed(0)}',
              style: TextStyle(color: tx.isIncome ? Colors.teal : Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
