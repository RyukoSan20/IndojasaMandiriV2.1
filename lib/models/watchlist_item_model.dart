class WatchlistItemModel {
  final String id;
  final String? userId;
  final String symbol;
  final String name;
  final String companyName;
  final double currentPrice;
  final double? lastPrice;
  final double? targetPrice;
  final double? priceChange;
  final double? priceChangePercent;
  final String? notes;
  final bool alertEnabled;
  final DateTime? addedAt;
  final DateTime? updatedAt;

  WatchlistItemModel({
    required this.id,
    this.userId,
    required this.symbol,
    String? name,
    String? companyName,
    double? currentPrice,
    this.lastPrice,
    this.targetPrice,
    this.priceChange,
    this.priceChangePercent,
    this.notes,
    this.alertEnabled = false,
    this.addedAt,
    this.updatedAt,
  })  : name = name ?? companyName ?? symbol,
        companyName = companyName ?? name ?? symbol,
        currentPrice = currentPrice ?? lastPrice ?? 0.0;

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) {
    return WatchlistItemModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      companyName: json['companyName'] ?? json['name'] ?? '',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      lastPrice: (json['lastPrice'] as num?)?.toDouble(),
      targetPrice: (json['targetPrice'] as num?)?.toDouble(),
      priceChange: (json['priceChange'] as num?)?.toDouble(),
      priceChangePercent: (json['priceChangePercent'] as num?)?.toDouble(),
      notes: json['notes'],
      alertEnabled: json['alertEnabled'] ?? false,
      addedAt: json['addedAt'] != null ? DateTime.parse(json['addedAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'symbol': symbol,
      'name': name,
      'companyName': companyName,
      'currentPrice': currentPrice,
      'lastPrice': lastPrice,
      'targetPrice': targetPrice,
      'priceChange': priceChange,
      'priceChangePercent': priceChangePercent,
      'notes': notes,
      'alertEnabled': alertEnabled,
      'addedAt': addedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
