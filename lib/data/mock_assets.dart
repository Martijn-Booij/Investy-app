import 'package:flutter/material.dart';

class AssetData {
  final String name;
  final String ticker;
  final double value;
  final double percentageChange;
  final Color logoColor;

  const AssetData({
    required this.name,
    required this.ticker,
    required this.value,
    required this.percentageChange,
    required this.logoColor,
  });
}

class MockAssets {
  static const List<AssetData> popularStocks = [
    AssetData(
      name: 'Microsoft',
      ticker: 'MSFT',
      value: 415.50,
      percentageChange: 32,
      logoColor: Colors.grey,
    ),
    AssetData(
      name: 'Apple',
      ticker: 'AAPL',
      value: 185.25,
      percentageChange: 12,
      logoColor: Colors.grey,
    ),
    AssetData(
      name: 'Tesla',
      ticker: 'TSLA',
      value: 245.80,
      percentageChange: -5,
      logoColor: Colors.grey,
    ),
    AssetData(
      name: 'Google',
      ticker: 'GOOGL',
      value: 142.50,
      percentageChange: 18,
      logoColor: Colors.grey,
    ),
    AssetData(
      name: 'Amazon',
      ticker: 'AMZN',
      value: 152.30,
      percentageChange: 8,
      logoColor: Colors.grey,
    ),
    AssetData(
      name: 'Meta',
      ticker: 'META',
      value: 485.75,
      percentageChange: 25,
      logoColor: Colors.grey,
    ),
    AssetData(
      name: 'Nvidia',
      ticker: 'NVDA',
      value: 875.20,
      percentageChange: 45,
      logoColor: Colors.grey,
    ),
    AssetData(
      name: 'Netflix',
      ticker: 'NFLX',
      value: 485.40,
      percentageChange: -2,
      logoColor: Colors.grey,
    ),
  ];

  static const List<AssetData> popularCrypto = [
    AssetData(
      name: 'Bitcoin',
      ticker: 'BTC',
      value: 45230.50,
      percentageChange: 32,
      logoColor: Color(0xFFF7931A),
    ),
    AssetData(
      name: 'Ethereum',
      ticker: 'ETH',
      value: 2850.75,
      percentageChange: 18,
      logoColor: Color(0xFF627EEA),
    ),
    AssetData(
      name: 'Solana',
      ticker: 'SOL',
      value: 98.25,
      percentageChange: -8,
      logoColor: Color(0xFF9945FF),
    ),
    AssetData(
      name: 'Cardano',
      ticker: 'ADA',
      value: 0.52,
      percentageChange: 5,
      logoColor: Color(0xFF0033AD),
    ),
    AssetData(
      name: 'Binance Coin',
      ticker: 'BNB',
      value: 315.80,
      percentageChange: 12,
      logoColor: Color(0xFFF3BA2F),
    ),
    AssetData(
      name: 'Ripple',
      ticker: 'XRP',
      value: 0.62,
      percentageChange: -3,
      logoColor: Color(0xFF23292F),
    ),
    AssetData(
      name: 'Polygon',
      ticker: 'MATIC',
      value: 0.85,
      percentageChange: 15,
      logoColor: Color(0xFF8247E5),
    ),
    AssetData(
      name: 'Chainlink',
      ticker: 'LINK',
      value: 14.25,
      percentageChange: 22,
      logoColor: Color(0xFF375BD2),
    ),
  ];
}
