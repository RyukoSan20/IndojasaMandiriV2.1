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

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) {
    return WatchlistItemModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
    };
  }
}
