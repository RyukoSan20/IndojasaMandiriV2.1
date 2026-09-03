class PortfolioHoldingModel {
  final String id;
  final String? userId;
  final String symbol;
  final String name;
  final String companyName;
  final int shares;
  final double averagePrice;
  final double currentPrice;
  final String sector;

  PortfolioHoldingModel({
    required this.id,
    this.userId,
    required this.symbol,
    required this.name,
    String? companyName,
    required this.shares,
    required this.averagePrice,
    required this.currentPrice,
    this.sector = 'General',
  }) : companyName = companyName ?? name;

  double get totalValue => shares * currentPrice;
  double get totalCost => shares * averagePrice;
  double get totalInvested => totalCost;
  double get profitLoss => totalValue - totalCost;
  double get profitLossPercent => totalCost > 0 ? (profitLoss / totalCost) * 100 : 0.0;

  factory PortfolioHoldingModel.fromJson(Map<String, dynamic> json) {
    return PortfolioHoldingModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      companyName: json['companyName'] ?? json['name'] ?? '',
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      sector: json['sector'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'symbol': symbol,
      'name': name,
      'companyName': companyName,
      'shares': shares,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'sector': sector,
    };
  }
}
