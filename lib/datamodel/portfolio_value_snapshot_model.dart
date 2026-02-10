class PortfolioValueSnapshot {
  final String id; 
  final DateTime timestamp;
  final double totalValue;
  final double? change; 

  PortfolioValueSnapshot({
    required this.id,
    required this.timestamp,
    required this.totalValue,
    this.change,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'totalValue': totalValue,
      'change': change,
    };
  }

  // Create from Firestore document
  factory PortfolioValueSnapshot.fromFirestore(String id, Map<String, dynamic> data) {
    return PortfolioValueSnapshot(
      id: id,
      timestamp: DateTime.parse(data['timestamp'] as String),
      totalValue: (data['totalValue'] as num).toDouble(),
      change: (data['change'] as num?)?.toDouble(),
    );
  }
}
