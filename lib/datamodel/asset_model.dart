import 'package:flutter/material.dart';

class AssetModel {
  final String symbol; 
  final String name; 
  final double? currentPrice;
  final double? previousClose; 
  final double? change;
  final double? percentChange;
  final Color? logoColor;
  final String? logoUrl;
  final DateTime? lastUpdated; 

  AssetModel({
    required this.symbol,
    required this.name,
    this.currentPrice,
    this.previousClose,
    this.change,
    this.percentChange,
    this.logoColor,
    this.logoUrl,
    this.lastUpdated,
  });

  AssetModel copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? previousClose,
    double? change,
    double? percentChange,
    Color? logoColor,
    String? logoUrl,
    DateTime? lastUpdated,
  }) {
    return AssetModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      previousClose: previousClose ?? this.previousClose,
      change: change ?? this.change,
      percentChange: percentChange ?? this.percentChange,
      logoColor: logoColor ?? this.logoColor,
      logoUrl: logoUrl ?? this.logoUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Convert to Map for JSON serialization (for persistent cache)
  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'previousClose': previousClose,
      'change': change,
      'percentChange': percentChange,
      'logoColorValue': logoColor?.value, // Store color as int
      'logoUrl': logoUrl,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Create from Map (for JSON deserialization from persistent cache)
  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      symbol: map['symbol'] as String,
      name: map['name'] as String,
      currentPrice: (map['currentPrice'] as num?)?.toDouble(),
      previousClose: (map['previousClose'] as num?)?.toDouble(),
      change: (map['change'] as num?)?.toDouble(),
      percentChange: (map['percentChange'] as num?)?.toDouble(),
      logoColor: map['logoColorValue'] != null
          ? Color(map['logoColorValue'] as int)
          : null,
      logoUrl: map['logoUrl'] as String?,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : null,
    );
  }
}
