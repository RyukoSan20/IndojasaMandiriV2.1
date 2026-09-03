class PortfolioHoldingModel {
  final String id;
  final String? userId;
  final String symbol;
  final String name;
  final String companyName;
  final String exchange;
  final int shares;
  final double averagePrice;
  final double currentPrice;
  final String sector;
  final double totalInvested;
  final double? customTotalValue;

  PortfolioHoldingModel({
    required this.id,
    this.userId,
    required this.symbol,
    required this.name,
    String? companyName,
    this.exchange = 'IDX',
    required this.shares,
    required this.averagePrice,
    required this.currentPrice,
    this.sector = 'General',
    double? totalInvested,
    double? totalValue,
  })  : companyName = companyName ?? name,
        totalInvested = totalInvested ?? (shares * averagePrice),
        customTotalValue = totalValue;

  double get totalValue => customTotalValue ?? (shares * currentPrice);
  double get totalCost => totalInvested;
  double get profitLoss => totalValue - totalCost;
  double get profitLossPercent => totalCost > 0 ? (profitLoss / totalCost) * 100 : 0.0;

  factory PortfolioHoldingModel.fromJson(Map<String, dynamic> json) {
    return PortfolioHoldingModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      companyName: json['companyName'] ?? json['name'] ?? '',
      exchange: json['exchange'] ?? 'IDX',
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      sector: json['sector'] ?? 'General',
      totalInvested: (json['totalInvested'] as num?)?.toDouble(),
      totalValue: (json['totalValue'] as num?)?.toDouble(),
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
    };
  }
}
