class SettingsModel {
  final String currency;
  final String theme;
  final bool notificationsEnabled;
  final bool biometricEnabled;

  SettingsModel({
    this.currency = 'IDR',
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      currency: json['currency'] ?? 'IDR',
      theme: json['theme'] ?? 'system',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      biometricEnabled: json['biometricEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'biometricEnabled': biometricEnabled,
    };
  }
}
