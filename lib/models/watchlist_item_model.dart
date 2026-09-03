class WatchlistItemModel {
  final String id;
  final String symbol;
  final String name;

  WatchlistItemModel({
    required this.id,
    required this.symbol,
    required this.name,
  });

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) {
    return WatchlistItemModel(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
    };
  }
}
