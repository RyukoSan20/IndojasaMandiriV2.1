class PortfolioHoldingModel {
  final String id;
  final String symbol;
  final String name;
  final double shares;
  final double averagePrice;

  PortfolioHoldingModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.shares,
    required this.averagePrice,
  });

  factory PortfolioHoldingModel.fromJson(Map<String, dynamic> json) {
    return PortfolioHoldingModel(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      shares: (json['shares'] ?? 0).toDouble(),
      averagePrice: (json['averagePrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'shares': shares,
      'averagePrice': averagePrice,
    };
  }
}
