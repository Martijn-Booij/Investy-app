import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:investy/repository/asset_repository.dart';
import 'package:investy/datamodel/asset_model.dart';
import 'package:investy/widgets/body/select_asset_screen_body.dart' show AssetType;

class AssetViewModel extends ChangeNotifier {
  final AssetRepository _assetRepository = AssetRepository();
  bool _disposed = false;
  
  // State
  List<AssetModel> _trendingStocks = [];
  List<AssetModel> _trendingCrypto = [];
  List<AssetModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AssetModel> get trendingStocks => _trendingStocks;
  List<AssetModel> get trendingCrypto => _trendingCrypto;
  List<AssetModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch trending stocks
  Future<void> fetchTrendingStocks() async {
    try {
      if (_trendingStocks.isEmpty) {
        _setLoading(true);
      }
      _clearError();

      // Hardcoded trending stock symbols
      const symbols = ['MSFT', 'TSLA', 'IBM', 'N'];
      const names = {
        'MSFT': 'Microsoft',
        'TSLA': 'Tesla',
        'IBM': 'IBM',
        'N': 'Nvidia',
      };

      final quotes = await _assetRepository.getAssets(symbols, symbolNames: names, isCrypto: false);
      
      if (_disposed) return;
      
      _trendingStocks = symbols.map((symbol) {
        final asset = quotes[symbol];
        if (asset != null) {
          return asset.copyWith(
            name: names[symbol] ?? symbol,
            logoColor: _getLogoColor(symbol),
          );
        }
        // Fallback if fetch failed
        return AssetModel(
          symbol: symbol,
          name: names[symbol] ?? symbol,
          logoColor: _getLogoColor(symbol),
        );
      }).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch trending stocks: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch trending crypto using CoinGecko
  Future<void> fetchTrendingCrypto() async {
    try {
      if (_trendingCrypto.isEmpty) {
        _setLoading(true);
      }
      _clearError();

      // Hardcoded trending crypto symbols (using simple symbols for CoinGecko)
      const symbols = ['BTC', 'ETH', 'SOL', 'ADA'];
      const names = {
        'BTC': 'Bitcoin',
        'ETH': 'Ethereum',
        'SOL': 'Solana',
        'ADA': 'Cardano',
      };

      // Fetch using CoinGecko with longer cache duration for trending assets
      final quotes = await _assetRepository.getCryptoAssets(
        symbols, 
        symbolNames: names,
        useTrendingCache: true, // Use 30-minute cache for trending assets
      );
      
      if (_disposed) return;
      
      _trendingCrypto = symbols.map((symbol) {
        final asset = quotes[symbol];
        if (asset != null) {
          return asset.copyWith(
            logoColor: _getCryptoLogoColor(symbol),
          );
        }
        // Fallback if fetch failed
        return AssetModel(
          symbol: symbol,
          name: names[symbol] ?? symbol,
          logoColor: _getCryptoLogoColor(symbol),
        );
      }).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch trending crypto: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Search assets
  Future<void> searchAssets(String query, AssetType type) async {
    try {
      _setLoading(true);
      _clearError();

      if (query.isEmpty) {
        // Return popular assets for empty query
        if (type == AssetType.stocks) {
          await fetchTrendingStocks();
          if (_disposed) return;
          _searchResults = _trendingStocks;
        } else {
          await fetchTrendingCrypto();
          if (_disposed) return;
          _searchResults = _trendingCrypto;
        }
      } else {
        if (type == AssetType.stocks) {
          _searchResults = await _assetRepository.searchStocks(query);
          if (_disposed) return;
          // Fetch quotes and profiles for search results (includes logos)
          final symbols = _searchResults.map((a) => a.symbol).toList();
          final symbolNames = Map.fromEntries(
            _searchResults.map((a) => MapEntry(a.symbol, a.name)),
          );
          final quotes = await _assetRepository.getAssets(symbols, symbolNames: symbolNames, isCrypto: false);
          if (_disposed) return;
          
          _searchResults = _searchResults.map((asset) {
            final quote = quotes[asset.symbol];
            if (quote != null) {
              return quote.copyWith(
                name: asset.name,
                logoColor: _getLogoColor(asset.symbol),
              );
            }
            return asset.copyWith(logoColor: _getLogoColor(asset.symbol));
          }).toList();
        } else {
          _searchResults = await _assetRepository.searchCrypto(query);
          if (_disposed) return;
          
          // Fetch quotes for search results using CoinGecko
          final symbols = _searchResults.map((a) => a.symbol).toList();
          final symbolNames = Map.fromEntries(
            _searchResults.map((a) => MapEntry(a.symbol, a.name)),
          );
          final quotes = await _assetRepository.getCryptoAssets(symbols, symbolNames: symbolNames);
          if (_disposed) return;
          
          _searchResults = _searchResults.map((asset) {
            final quote = quotes[asset.symbol];
            if (quote != null) {
              return quote.copyWith(
                name: asset.name,
                logoColor: _getCryptoLogoColor(asset.symbol),
              );
            }
            return asset.copyWith(logoColor: _getCryptoLogoColor(asset.symbol));
          }).toList();
        }
      }

      _setLoading(false);
    } catch (e) {
      _setError('Failed to search assets: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Get portfolio assets (handles both stocks and crypto)
  Future<Map<String, AssetModel>> getPortfolioAssets(
    List<String> symbols, {
    Map<String, String>? symbolNames,
    bool isCrypto = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final quotes = isCrypto
          ? await _assetRepository.getCryptoAssets(symbols, symbolNames: symbolNames)
          : await _assetRepository.getAssets(symbols, symbolNames: symbolNames, isCrypto: false);
      
      if (_disposed) return {};
      
      _setLoading(false);
      return quotes;
    } catch (e) {
      _setError('Failed to fetch portfolio assets: ${e.toString()}');
      _setLoading(false);
      return {};
    }
  }

  // Helper: Get logo color for stocks
  Color _getLogoColor(String symbol) {
    // Keep existing logic or use default grey
    return const Color(0xFF9E9E9E); // Grey
  }

  // Helper: Get logo color for crypto
  Color _getCryptoLogoColor(String symbol) {
    // Extract base symbol from exchange format (e.g., "BINANCE:BTCUSDT" -> "BTC")
    String baseSymbol = symbol.toUpperCase();
    if (baseSymbol.contains(':')) {
      final parts = baseSymbol.split(':');
      if (parts.length > 1) {
        baseSymbol = parts[1].replaceAll('USDT', '').replaceAll('USD', '');
      }
    }
    
    // Match base symbol to color
    switch (baseSymbol) {
      case 'BTC':
        return const Color(0xFFF7931A); // Bitcoin orange
      case 'ETH':
        return const Color(0xFF627EEA); // Ethereum blue
      case 'SOL':
        return const Color(0xFF9945FF); // Solana purple
      case 'ADA':
        return const Color(0xFF0033AD); // Cardano blue
      case 'BNB':
        return const Color(0xFFF3BA2F); // Binance yellow
      case 'XRP':
        return const Color(0xFF23292F); // Ripple black
      case 'MATIC':
        return const Color(0xFF8247E5); // Polygon purple
      case 'LINK':
        return const Color(0xFF375BD2); // Chainlink blue
      default:
        return const Color(0xFF9E9E9E); // Default grey
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _setLoading(bool value) {
    if (_disposed) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    if (_disposed) return;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_disposed) return;
    _errorMessage = null;
    notifyListeners();
  }
}
