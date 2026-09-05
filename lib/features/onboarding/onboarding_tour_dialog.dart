import 'package:flutter/material.dart';

class OnboardingTourDialog extends StatefulWidget {
  final Function({
    required String name,
    required String currency,
    required double income,
    required bool hasIncome,
    required bool useFormula,
    required String goalType,
  }) onComplete;

  const OnboardingTourDialog({super.key, required onComplete}) : onComplete = onComplete;

  @override
  State<OnboardingTourDialog> createState() => _OnboardingTourDialogState();
}

class _OnboardingTourDialogState extends State<OnboardingTourDialog> {
  int _step = 0;
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();
  String _selectedCurrency = 'IDR';
  String _selectedGoal = 'Monthly';
  bool _hasIncome = true;
  bool _useFormula = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selamat Datang di FinTrack! (Langkah ${_step + 1}/3)'),
      content: SingleChildScrollView(
        child: _buildStepContent(),
      ),
      actions: [
        if (_step > 0)
          TextButton(
            onPressed: () => setState(() => _step--),
            child: const Text('Kembali'),
          ),
        ElevatedButton(
          onPressed: () {
            if (_step < 2) {
              setState(() => _step++);
            } else {
              final income = double.tryParse(_incomeController.text) ?? 0.0;
              widget.onComplete(
                name: _nameController.text.isEmpty ? 'Pengguna Baru' : _nameController.text,
                currency: _selectedCurrency,
                income: income,
                hasIncome: _hasIncome,
                useFormula: _useFormula,
                goalType: _selectedGoal,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(_step == 2 ? 'Mulai FinTrack' : 'Lanjut'),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    if (_step == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Mari atur profil keuangan dasar Anda.'),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama Lengkap'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCurrency,
            items: ['IDR', 'USD', 'EUR', 'SAR', 'JPY', 'MYR']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => setState(() => _selectedCurrency = val ?? 'IDR'),
            decoration: const InputDecoration(labelText: 'Mata Utama'),
          ),
        ],
      );
    } else if (_step == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Pilih Target Planning Keuangan Anda:'),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Weekly', label: Text('Mingguan')),
              ButtonSegment(value: 'Monthly', label: Text('Bulanan')),
              ButtonSegment(value: 'Yearly', label: Text('Tahunan')),
            ],
            selected: {_selectedGoal},
            onSelectionChanged: (val) => setState(() => _selectedGoal = val.first),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Sudah Memiliki Penghasilan Bulanan?'),
            value: _hasIncome,
            onChanged: (val) => setState(() => _hasIncome = val),
          ),
          if (_hasIncome) ...[
            TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Penghasilan Bulanan',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Gunakan Hack Alokasi 50/5/30/15?'),
              subtitle: const Text('50% Kebutuhan, 5% Konsumtif, 30% Investasi, 15% Darurat'),
              value: _useFormula,
              onChanged: (val) => setState(() => _useFormula = val),
            ),
          ],
        ],
      );
    }
  }
}
