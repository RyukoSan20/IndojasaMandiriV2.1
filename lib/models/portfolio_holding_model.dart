// ignore_for_file: unnecessary_cast
class PortfolioHoldingModel {
  final String id;
  final String? userId;
  final String symbol;
  final String name;
  final String companyName;
  final String exchange;
  final double shares;
  final double averagePrice;
  final double currentPrice;
  final String sector;
  final double totalInvested;
  final double? customTotalValue;
  final double? customProfitLoss;
  final double? customProfitLossPercent;
  final DateTime? lastUpdated;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PortfolioHoldingModel({
    required this.id,
    this.userId,
    required this.symbol,
    String? name,
    String? companyName,
    this.exchange = 'IDX',
    required dynamic shares,
    required this.averagePrice,
    required this.currentPrice,
    this.sector = 'General',
    double? totalInvested,
    double? totalValue,
    double? profitLoss,
    double? profitLossPercent,
    this.lastUpdated,
    this.createdAt,
    this.updatedAt,
  })  : shares = (shares as num).toDouble(),
        name = name ?? companyName ?? symbol,
        companyName = companyName ?? name ?? symbol,
        totalInvested = totalInvested ?? ((shares).toDouble() * averagePrice),
        customTotalValue = totalValue,
        customProfitLoss = profitLoss,
        customProfitLossPercent = profitLossPercent;

  double get totalValue => customTotalValue ?? (shares * currentPrice);
  double get totalCost => totalInvested;
  double get profitLoss => customProfitLoss ?? (totalValue - totalCost);
  double get profitLossPercent =>
      customProfitLossPercent ?? (totalCost > 0 ? (profitLoss / totalCost) * 100 : 0.0);

  factory PortfolioHoldingModel.fromJson(Map<String, dynamic> json) {
    return PortfolioHoldingModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      companyName: json['companyName'] ?? json['name'] ?? '',
      exchange: json['exchange'] ?? 'IDX',
      shares: (json['shares'] as num?)?.toDouble() ?? 0.0,
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      sector: json['sector'] ?? 'General',
      totalInvested: (json['totalInvested'] as num?)?.toDouble(),
      totalValue: (json['totalValue'] as num?)?.toDouble(),
      profitLoss: (json['profitLoss'] as num?)?.toDouble(),
      profitLossPercent: (json['profitLossPercent'] as num?)?.toDouble(),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
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
      'exchange': exchange,
      'shares': shares,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'sector': sector,
      'totalInvested': totalInvested,
      'totalValue': totalValue,
      'profitLoss': profitLoss,
      'profitLossPercent': profitLossPercent,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
