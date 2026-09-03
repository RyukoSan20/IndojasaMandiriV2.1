import 'package:flutter/foundation.dart';

class FinancialInsight {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  FinancialInsight({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.createdAt,
    this.data,
  });

  factory FinancialInsight.fromJson(Map<String, dynamic> json) {
    return FinancialInsight(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt?.toIso8601String(),
      'data': data,
    };
  }
}

class NetWorthData {
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final DateTime date;

  NetWorthData({
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.date,
  });

  factory NetWorthData.fromJson(Map<String, dynamic> json) {
    return NetWorthData(
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0.0,
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
      totalLiabilities: (json['totalLiabilities'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'netWorth': netWorth,
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'date': date.toIso8601String(),
    };
  }
}
