import 'package:flutter/material.dart';

class OnboardingTourDialog extends StatefulWidget {
  final Function(String name, String currency, double income, bool hasIncome, bool useFormula) onComplete;

  const OnboardingTourDialog({super.key, required this.onComplete});

  @override
  State<OnboardingTourDialog> createState() => _OnboardingTourDialogState();
}

class _OnboardingTourDialogState extends State<OnboardingTourDialog> {
  int _step = 0;
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();
  String _selectedCurrency = 'IDR';
  bool _hasIncome = true;
  bool _useFormula = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_step == 0) ...[
              const Text('Selamat Datang di FinTrack', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Mari atur preferensi dan profil keuangan awal Anda secara bersih.'),
              const SizedBox(height: 15),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedCurrency,
                items: const [
                  DropdownMenuItem(value: 'IDR', child: Text('IDR - Rupiah')),
                  DropdownMenuItem(value: 'USD', child: Text('USD - Dollar')),
                  DropdownMenuItem(value: 'JPY', child: Text('JPY - Yen')),
                ],
                onChanged: (val) => setState(() => _selectedCurrency = val!),
                decoration: const InputDecoration(labelText: 'Mata Uang Utama', border: OutlineInputBorder()),
              ),
            ] else if (_step == 1) ...[
              const Text('Status Penghasilan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              SwitchListTile(
                title: const Text('Sudah Memiliki Penghasilan Bulanan?'),
                value: _hasIncome,
                onChanged: (val) => setState(() => _hasIncome = val),
              ),
              if (_hasIncome)
                TextField(
                  controller: _incomeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nominal Penghasilan Bulanan', border: OutlineInputBorder()),
                ),
            ] else ...[
              const Text('Alokasi Otomatis (Smart Hack)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Bagi penghasilan otomatis ke rumus 50/5/30/15 (Kebutuhan, Konsumtif, Investasi, Dana Darurat)?'),
                value: _useFormula,
                onChanged: (val) => setState(() => _useFormula = val),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_step > 0)
                  TextButton(onPressed: () => setState(() => _step--), child: const Text('Kembali')),
                ElevatedButton(
                  onPressed: () {
                    if (_step < 2) {
                      setState(() => _step++);
                    } else {
                      final inc = double.tryParse(_incomeController.text) ?? 0.0;
                      widget.onComplete(_nameController.text, _selectedCurrency, inc, _hasIncome, _useFormula);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(_step == 2 ? 'Selesai' : 'Lanjut'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
