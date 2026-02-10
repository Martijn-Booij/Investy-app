class PortfolioAsset {
  final String id;
  final String symbol;
  final String name;
  final double quantity;
  final double purchasePrice;
  final DateTime purchaseDate;
  final String assetType;
  final String? logoUrl;

  PortfolioAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.assetType,
    this.logoUrl,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate.toIso8601String(),
      'assetType': assetType,
      'logoUrl': logoUrl,
    };
  }

  // Create from Firestore document
  factory PortfolioAsset.fromFirestore(String id, Map<String, dynamic> data) {
    return PortfolioAsset(
      id: id,
      symbol: data['symbol'] as String,
      name: data['name'] as String,
      quantity: (data['quantity'] as num).toDouble(),
      purchasePrice: (data['purchasePrice'] as num).toDouble(),
      purchaseDate: DateTime.parse(data['purchaseDate'] as String),
      assetType: data['assetType'] as String,
      logoUrl: data['logoUrl'] as String?,
    );
  }

  PortfolioAsset copyWith({
    String? id,
    String? symbol,
    String? name,
    double? quantity,
    double? purchasePrice,
    DateTime? purchaseDate,
    String? assetType,
    String? logoUrl,
  }) {
    return PortfolioAsset(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      assetType: assetType ?? this.assetType,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
