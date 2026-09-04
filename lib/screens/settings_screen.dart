// ignore_for_file: unused_field, prefer_const_declarations, prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Pengaturan FinTrack')),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: Text('Mode Gelap (Dark Mode)'),
                subtitle: Text('Ubah tampilan aplikasi ke tema gelap secara global'),
                value: settings.isDarkMode,
                onChanged: (val) => settings.toggleDarkMode(val),
              ),
              Divider(),
              ListTile(
                title: Text('Mata Uang Utama'),
                subtitle: Text('Aktif saat ini: ${settings.currency}'),
                trailing: DropdownButton<String>(
                  value: settings.currency,
                  items: [
                    DropdownMenuItem(value: 'IDR', child: Text('IDR (Rp - Rupiah)')),
                    DropdownMenuItem(value: 'USD', child: Text('USD (USD - Dollar)')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR (€ - Euro)')),
                    DropdownMenuItem(value: 'JPY', child: Text('JPY (¥ - Yen)')),
                    DropdownMenuItem(value: 'KRW', child: Text('KRW (₩ - Won)')),
                    DropdownMenuItem(value: 'SAR', child: Text('SAR (SR - Riyal)')),
                    DropdownMenuItem(value: 'MYR', child: Text('MYR (RM - Ringgit)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      settings.setCurrency(val);
                    }
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text('Bahasa Aplikasi'),
                subtitle: Text(settings.languageCode == 'id' ? 'Bahasa Indonesia' : 'English'),
                trailing: DropdownButton<String>(
                  value: settings.languageCode,
                  items: [
                    DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      settings.setLanguage(val);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
