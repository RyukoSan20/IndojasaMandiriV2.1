class SettingsModel {
  final String currency;
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final bool biometricEnabled;

  SettingsModel({
    this.currency = 'IDR',
    this.language = 'id',
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      currency: json['currency'] ?? 'IDR',
      language: json['language'] ?? 'id',
      theme: json['theme'] ?? 'system',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      biometricEnabled: json['biometricEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'language': language,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'biometricEnabled': biometricEnabled,
    };
  }
}
