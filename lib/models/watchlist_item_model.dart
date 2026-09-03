class WatchlistItemModel {
  final String id;
  final String? userId;
  final String symbol;
  final String name;
  final double currentPrice;

  WatchlistItemModel({
    required this.id,
    this.userId,
    required this.symbol,
    required this.name,
    required this.currentPrice,
  });
}
