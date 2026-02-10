import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:investy/config/api_config.dart';
import 'package:investy/datamodel/asset_model.dart';
import 'package:flutter/material.dart';

class CoinGeckoService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  final String? _apiKey = ApiConfig.coinGeckoApiKey;

  // Map common crypto symbols to CoinGecko coin IDs
  static const Map<String, String> _symbolToIdMap = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'SOL': 'solana',
    'ADA': 'cardano',
    'BNB': 'binancecoin',
    'XRP': 'ripple',
    'MATIC': 'matic-network',
    'LINK': 'chainlink',
    'DOT': 'polkadot',
    'AVAX': 'avalanche-2',
    'DOGE': 'dogecoin',
    'SHIB': 'shiba-inu',
    'UNI': 'uniswap',
    'ATOM': 'cosmos',
    'LTC': 'litecoin',
    'BCH': 'bitcoin-cash',
    'XLM': 'stellar',
    'ALGO': 'algorand',
    'VET': 'vechain',
    'FIL': 'filecoin',
    'TRX': 'tron',
    'ETC': 'ethereum-classic',
    'EOS': 'eos',
    'AAVE': 'aave',
    'MKR': 'maker',
    'COMP': 'compound-governance-token',
    'YFI': 'yearn-finance',
    'SNX': 'havven',
    'SUSHI': 'sushi',
  };

  // Get CoinGecko coin ID from symbol
  static String? getCoinId(String symbol) {
    final upperSymbol = symbol.toUpperCase();
    // Extract base symbol from exchange format (e.g., "BINANCE:BTCUSDT" -> "BTC")
    final baseSymbol = upperSymbol.contains(':')
        ? upperSymbol.split(':')[1].replaceAll('USDT', '').replaceAll('USD', '')
        : upperSymbol;
    
    return _symbolToIdMap[baseSymbol];
  }

  // Get multiple crypto assets with prices and 24hr change
  Future<Map<String, AssetModel>> getCryptoAssets(
    List<String> symbols, {
    Map<String, String>? symbolNames,
  }) async {
    try {
      // Convert symbols to CoinGecko IDs
      final coinIds = <String>[];
      final symbolToId = <String, String>{};
      
      for (final symbol in symbols) {
        final coinId = getCoinId(symbol);
        if (coinId != null) {
          coinIds.add(coinId);
          symbolToId[coinId] = symbol;
        }
      }

      if (coinIds.isEmpty) {
        return {};
      }

      // Build URL with API key if available
      final queryParams = <String, String>{
        'ids': coinIds.join(','),
        'vs_currencies': 'usd',
        'include_24hr_change': 'true',
        'include_market_cap': 'false',
        'include_24hr_vol': 'false',
        'include_last_updated_at': 'true',
      };

      if (_apiKey != null && _apiKey.isNotEmpty) {
        queryParams['x_cg_demo_api_key'] = _apiKey;
      }

      final url = Uri.parse('$_baseUrl/simple/price').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        
        final results = <String, AssetModel>{};
        
        for (final entry in jsonData.entries) {
          final coinId = entry.key;
          final data = entry.value as Map<String, dynamic>;
          final symbol = symbolToId[coinId] ?? coinId.toUpperCase();
          
          final price = (data['usd'] as num?)?.toDouble();
          final change24h = (data['usd_24h_change'] as num?)?.toDouble();
          final lastUpdated = data['last_updated_at'] as int?;
          
          // Get coin details for name and logo
          final coinDetails = await _getCoinDetails(coinId);
          
          results[symbol] = AssetModel(
            symbol: symbol,
            name: coinDetails['name'] ?? symbolNames?[symbol] ?? symbol,
            currentPrice: price,
            percentChange: change24h,
            logoUrl: coinDetails['image'] as String?, // Set logo URL from CoinGecko
            lastUpdated: lastUpdated != null
                ? DateTime.fromMillisecondsSinceEpoch(lastUpdated * 1000)
                : DateTime.now(),
            logoColor: _getLogoColorForSymbol(symbol),
          );
        }
        
        return results;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to fetch crypto data: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get coin details (name, logo URL, etc.)
  Future<Map<String, dynamic>> _getCoinDetails(String coinId) async {
    try {
      final queryParams = <String, String>{
        'localization': 'false',
        'tickers': 'false',
        'market_data': 'false',
        'community_data': 'false',
        'developer_data': 'false',
        'sparkline': 'false',
      };

      if (_apiKey != null && _apiKey.isNotEmpty) {
        queryParams['x_cg_demo_api_key'] = _apiKey;
      }

      final url = Uri.parse('$_baseUrl/coins/$coinId').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return {
          'name': jsonData['name'] as String?,
          'symbol': jsonData['symbol'] as String?,
          'image': jsonData['image']?['small'] as String?,
        };
      }
      
      return {};
    } catch (e) {
      // Return empty map if details fetch fails
      return {};
    }
  }

  // Search for cryptocurrencies
  Future<List<AssetModel>> searchCrypto(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final queryParams = <String, String>{
        'query': query,
      };

      if (_apiKey != null && _apiKey.isNotEmpty) {
        queryParams['x_cg_demo_api_key'] = _apiKey;
      }

      final url = Uri.parse('$_baseUrl/search').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final coins = jsonData['coins'] as List<dynamic>? ?? [];
        
        final List<AssetModel> searchResults = [];
        for (final coin in coins) {
          final coinData = coin as Map<String, dynamic>;
          final symbol = (coinData['symbol'] as String? ?? '').toUpperCase();
          final name = coinData['name'] as String? ?? symbol;
          final coinId = coinData['id'] as String? ?? '';
          
          // Fetch coin details for logo URL
          String? logoUrl;
          if (coinId.isNotEmpty) {
            try {
              final details = await _getCoinDetails(coinId);
              logoUrl = details['image'] as String?;
            } catch (e) {
              // Continue without logo if fetch fails
            }
          }
          
          searchResults.add(AssetModel(
            symbol: symbol,
            name: name,
            logoUrl: logoUrl, // Set logo URL from CoinGecko
            logoColor: _getLogoColorForSymbol(symbol),
            // Price and change will be fetched separately if needed
          ));
        }
        return searchResults;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to search crypto: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get logo color for symbol (fallback)
  Color _getLogoColorForSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return const Color(0xFFF7931A);
      case 'ETH':
        return const Color(0xFF627EEA);
      case 'SOL':
        return const Color(0xFF9945FF);
      case 'ADA':
        return const Color(0xFF0033AD);
      case 'BNB':
        return const Color(0xFFF3BA2F);
      case 'XRP':
        return const Color(0xFF23292F);
      case 'MATIC':
        return const Color(0xFF8247E5);
      case 'LINK':
        return const Color(0xFF375BD2);
      default:
        return Colors.grey;
    }
  }
}
