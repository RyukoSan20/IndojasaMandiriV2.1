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
}
