import 'dart:convert';
import 'package:investy/services/coingecko_service.dart';
import 'package:investy/config/api_config.dart';
import 'package:investy/datamodel/asset_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedAsset {
  final AssetModel asset;
  final DateTime cachedAt;

  CachedAsset({
    required this.asset,
    required this.cachedAt,
  });

  bool get isExpired =>
      DateTime.now().difference(cachedAt) > ApiConfig.cacheDuration;
  
  bool isExpiredWithDuration(Duration duration) =>
      DateTime.now().difference(cachedAt) > duration;

  // Convert to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'asset': asset.toMap(),
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  // Create from Map
  factory CachedAsset.fromMap(Map<String, dynamic> map) {
    return CachedAsset(
      asset: AssetModel.fromMap(map['asset'] as Map<String, dynamic>),
      cachedAt: DateTime.parse(map['cachedAt'] as String),
    );
  }
}

class AssetRepository {
  final CoinGeckoService _coinGeckoService = CoinGeckoService();
  final Map<String, CachedAsset> _assetCache = {};
  final Map<String, CachedAsset> _searchCache = {};
  SharedPreferences? _prefs;
  bool _initialized = false;
  
  // Initialize persistent cache
  Future<void> _initializeCache() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadPersistentCache();
      _initialized = true;
    } catch (e) {
      // If SharedPreferences fails, continue without persistent cache
      print('Warning: Could not initialize persistent cache: $e');
    }
  }
  
  // Load cache from SharedPreferences
  Future<void> _loadPersistentCache() async {
    if (_prefs == null) return;
    
    try {
      final cacheJson = _prefs?.getString('asset_cache');
      if (cacheJson != null) {
        final cacheMap = json.decode(cacheJson) as Map<String, dynamic>;
        for (final entry in cacheMap.entries) {
          try {
            final cached = CachedAsset.fromMap(entry.value as Map<String, dynamic>);
            // Only load if not expired (use trending cache duration for all)
            if (!cached.isExpiredWithDuration(ApiConfig.trendingCacheDuration)) {
              _assetCache[entry.key] = cached;
            }
          } catch (e) {
            // Skip invalid cache entries
            continue;
          }
        }
      }
    } catch (e) {
      // If loading fails, continue with empty cache
      print('Warning: Could not load persistent cache: $e');
    }
  }
  
  // Save cache to SharedPreferences
  Future<void> _savePersistentCache() async {
    if (_prefs == null) return;
    
    try {
      final cacheMap = <String, dynamic>{};
      for (final entry in _assetCache.entries) {
        cacheMap[entry.key] = entry.value.toMap();
      }
      await _prefs?.setString('asset_cache', json.encode(cacheMap));
    } catch (e) {
      // If saving fails, continue without persistent cache
      print('Warning: Could not save persistent cache: $e');
    }
  }
  
  // Hardcoded stock data 
  static final Map<String, AssetModel> _hardcodedStocks = {
    'MSFT': AssetModel(
      symbol: 'MSFT',
      name: 'Microsoft',
      currentPrice: 420.50,
      previousClose: 415.20,
      change: 5.30,
      percentChange: 1.28,
      logoColor: Colors.grey,
      logoUrl: 'assets/icons/stocks/msft.png',
      lastUpdated: DateTime.now(),
    ),
    'TSLA': AssetModel(
      symbol: 'TSLA',
      name: 'Tesla',
      currentPrice: 245.80,
      previousClose: 250.10,
      change: -4.30,
      percentChange: -1.72,
      logoColor: Colors.grey,
      logoUrl: 'assets/icons/stocks/tesla.png',
      lastUpdated: DateTime.now(),
    ),
    'IBM': AssetModel(
      symbol: 'IBM',
      name: 'IBM',
      currentPrice: 185.30,
      previousClose: 183.90,
      change: 1.40,
      percentChange: 0.76,
      logoColor: Colors.grey,
      logoUrl: 'assets/icons/stocks/ibm.png',
      lastUpdated: DateTime.now(),
    ),
    'N': AssetModel(
      symbol: 'N',
      name: 'Nvidia',
      currentPrice: 95.20,
      previousClose: 94.50,
      change: 0.70,
      percentChange: 0.74,
      logoColor: Colors.grey,
      logoUrl: 'assets/icons/stocks/nvidia.png',
      lastUpdated: DateTime.now(),
    ),
    'AAPL': AssetModel(
      symbol: 'AAPL',
      name: 'Apple',
      currentPrice: 178.90,
      previousClose: 177.20,
      change: 1.70,
      percentChange: 0.96,
      logoColor: Colors.grey,
      lastUpdated: DateTime.now(),
    ),
  };

  // Get cached asset if available and not expired (checks both in-memory and persistent)
  Future<AssetModel?> _getCachedAsset(String symbol, {bool useTrendingCache = false}) async {
    await _initializeCache();
    
    final cached = _assetCache[symbol];
    if (cached != null) {
      // Use longer cache duration for trending assets
      final cacheDuration = useTrendingCache 
          ? ApiConfig.trendingCacheDuration 
          : ApiConfig.cacheDuration;
      
      if (!cached.isExpiredWithDuration(cacheDuration)) {
        return cached.asset;
      }
    }
    return null;
  }

  // Cache an asset (both in-memory and persistent)
  Future<void> _cacheAsset(String symbol, AssetModel asset) async {
    await _initializeCache();
    
    _assetCache[symbol] = CachedAsset(
      asset: asset,
      cachedAt: DateTime.now(),
    );
    
    // Save to persistent cache
    await _savePersistentCache();
  }

  // Get assets (quotes) for multiple symbols - uses hardcoded data for stocks
  Future<Map<String, AssetModel>> getAssets(
    List<String> symbols, {
    Map<String, String>? symbolNames,
    required bool isCrypto,
  }) async {
    if (isCrypto) {
      // Use crypto service
      return await getCryptoAssets(symbols, symbolNames: symbolNames);
    }
    
    // For stocks, return hardcoded data (no need to cache since it's hardcoded)
    final Map<String, AssetModel> results = {};
    
    for (final symbol in symbols) {
      // Use hardcoded data or create fallback
      if (_hardcodedStocks.containsKey(symbol)) {
        // Always use fresh hardcoded data to ensure logoUrl is included
        final asset = _hardcodedStocks[symbol]!.copyWith(
          name: symbolNames?[symbol] ?? _hardcodedStocks[symbol]!.name,
        );
        results[symbol] = asset;
      } else {
        // Fallback for unknown stocks
        final asset = AssetModel(
          symbol: symbol,
          name: symbolNames?[symbol] ?? symbol,
          currentPrice: 0.0,
          logoColor: Colors.grey,
          lastUpdated: DateTime.now(),
        );
        results[symbol] = asset;
      }
    }
    
    return results;
  }

  // Search for stocks - returns hardcoded stocks that match query
  Future<List<AssetModel>> searchStocks(String query) async {
    if (query.isEmpty) {
      return _hardcodedStocks.values.toList();
    }

    final queryLower = query.toLowerCase();
    return _hardcodedStocks.values
        .where((stock) =>
            stock.symbol.toLowerCase().contains(queryLower) ||
            stock.name.toLowerCase().contains(queryLower))
        .toList();
  }

  // Search for crypto using CoinGecko
  Future<List<AssetModel>> searchCrypto(String query) async {
    if (query.isEmpty) {
      return [];
    }

    // Check search cache
    final cacheKey = 'crypto_$query';
    final cached = _searchCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      // For now, just fetch again
    }

    try {
      final results = await _coinGeckoService.searchCrypto(query);
      
      // Cache search results
      if (results.isNotEmpty) {
        _searchCache[cacheKey] = CachedAsset(
          asset: results.first,
          cachedAt: DateTime.now(),
        );
      }

      return results;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, AssetModel>> getCryptoAssets(
    List<String> symbols, {
    Map<String, String>? symbolNames,
    bool useTrendingCache = false, // Use longer cache for trending assets
  }) async {
    await _initializeCache();
    
    final Map<String, AssetModel> results = {};
    final List<String> symbolsToFetch = [];

    // Check cache for each symbol
    for (final symbol in symbols) {
      final cached = await _getCachedAsset(symbol, useTrendingCache: useTrendingCache);
      if (cached != null) {
        results[symbol] = cached;
      } else {
        symbolsToFetch.add(symbol);
      }
    }

    // Only fetch symbols that aren't cached or are expired
    if (symbolsToFetch.isNotEmpty) {
      try {
        final coinGeckoResults = await _coinGeckoService.getCryptoAssets(
          symbolsToFetch,
          symbolNames: symbolNames,
        );
        
        // Cache all fetched results
        for (final entry in coinGeckoResults.entries) {
          await _cacheAsset(entry.key, entry.value);
          results[entry.key] = entry.value;
        }
      } catch (e) {
        // If fetch fails, use expired cache if available
        for (final symbol in symbolsToFetch) {
          final expiredCached = _assetCache[symbol];
          if (expiredCached != null) {
            results[symbol] = expiredCached.asset;
          }
        }
      }
    }

    return results;
  }
}
