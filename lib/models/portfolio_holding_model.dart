class PortfolioHoldingModel {
  final String id;
  final String? userId;
  final String symbol;
  final String name;
  final int shares;
  final double averagePrice;
  final double currentPrice;
  final String sector;

  PortfolioHoldingModel({
    required this.id,
    this.userId,
    required this.symbol,
    required this.name,
    required this.shares,
    required this.averagePrice,
    required this.currentPrice,
    this.sector = 'General',
  });

  double get totalValue => shares * currentPrice;
  double get totalCost => shares * averagePrice;
  double get totalInvested => totalCost;
  double get profitLoss => totalValue - totalCost;

  factory PortfolioHoldingModel.fromJson(Map<String, dynamic> json) {
    return PortfolioHoldingModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
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
      'shares': shares,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'sector': sector,
    };
  }
}
