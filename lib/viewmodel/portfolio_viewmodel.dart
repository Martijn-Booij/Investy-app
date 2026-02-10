import 'package:flutter/foundation.dart';
import 'package:investy/repository/portfolio_repository.dart';
import 'package:investy/repository/asset_repository.dart';
import 'package:investy/datamodel/portfolio_asset_model.dart';
import 'package:investy/datamodel/portfolio_value_snapshot_model.dart';
import 'package:investy/datamodel/asset_model.dart';

class PortfolioViewModel extends ChangeNotifier {
  final PortfolioRepository _portfolioRepository = PortfolioRepository();
  final AssetRepository _assetRepository = AssetRepository();
  bool _disposed = false;

  // State
  List<PortfolioAsset> _portfolioAssets = [];
  double _totalValue = 0.0;
  double _percentageChange = 0.0;
  List<PortfolioValueSnapshot> _valueHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PortfolioAsset> get portfolioAssets => _portfolioAssets;
  double get totalValue => _totalValue;
  double get percentageChange => _percentageChange;
  List<PortfolioValueSnapshot> get valueHistory => _valueHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get assets by type
  List<PortfolioAsset> getStocks() {
    return _portfolioAssets.where((asset) => asset.assetType == 'stock').toList();
  }

  List<PortfolioAsset> getCrypto() {
    return _portfolioAssets.where((asset) => asset.assetType == 'crypto').toList();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Load portfolio assets from Firestore
  Future<void> loadPortfolio() async {
    try {
      _setLoading(true);
      _clearError();

      _portfolioAssets = await _portfolioRepository.getPortfolioAssets();
      
      if (_disposed) return;

      // Calculate portfolio value
      await _calculatePortfolioValue();
      
      // Load chart data (last 30 days)
      await loadChartData(days: 30);
      
      _setLoading(false);
    } catch (e) {
      if (_disposed) return;
      _setError('Failed to load portfolio: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Calculate total portfolio value from current prices
  Future<void> _calculatePortfolioValue() async {
    if (_portfolioAssets.isEmpty) {
      _totalValue = 0.0;
      _percentageChange = 0.0;
      notifyListeners();
      return;
    }

    try {
      // Group assets by type
      final stockAssets = _portfolioAssets.where((a) => a.assetType == 'stock').toList();
      final cryptoAssets = _portfolioAssets.where((a) => a.assetType == 'crypto').toList();

      // Get current prices for all assets
      final stockSymbols = stockAssets.map((a) => a.symbol).toList();
      final cryptoSymbols = cryptoAssets.map((a) => a.symbol).toList();

      final stockNames = Map.fromEntries(
        stockAssets.map((a) => MapEntry(a.symbol, a.name)),
      );
      final cryptoNames = Map.fromEntries(
        cryptoAssets.map((a) => MapEntry(a.symbol, a.name)),
      );

      // Fetch current prices
      final stockQuotes = stockSymbols.isNotEmpty
          ? await _assetRepository.getAssets(stockSymbols, symbolNames: stockNames, isCrypto: false)
          : <String, AssetModel>{};
      
      final cryptoQuotes = cryptoSymbols.isNotEmpty
          ? await _assetRepository.getCryptoAssets(cryptoSymbols, symbolNames: cryptoNames)
          : <String, AssetModel>{};

      if (_disposed) return;

      // Calculate total value
      double total = 0.0;
      
      for (final asset in stockAssets) {
        final quote = stockQuotes[asset.symbol];
        if (quote?.currentPrice != null) {
          total += quote!.currentPrice! * asset.quantity;
        }
      }

      for (final asset in cryptoAssets) {
        final quote = cryptoQuotes[asset.symbol];
        if (quote?.currentPrice != null) {
          total += quote!.currentPrice! * asset.quantity;
        }
      }

      _totalValue = total;

      // Calculate percentage change from previous snapshot
      final previousSnapshot = await _portfolioRepository.getLatestPortfolioValueSnapshot();
      if (previousSnapshot != null && previousSnapshot.totalValue > 0) {
        _percentageChange = ((_totalValue - previousSnapshot.totalValue) / previousSnapshot.totalValue) * 100;
      } else {
        _percentageChange = 0.0;
      }

      // Save daily snapshot
      await _saveDailySnapshot();

      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _setError('Failed to calculate portfolio value: ${e.toString()}');
    }
  }

  // Save daily snapshot (only if not already saved today)
  Future<void> _saveDailySnapshot() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      
      // Check if snapshot for today exists
      final todaySnapshot = await _portfolioRepository.getLatestPortfolioValueSnapshot();
      
      if (todaySnapshot != null) {
        final snapshotDate = todaySnapshot.timestamp;
        final snapshotDayStart = DateTime(snapshotDate.year, snapshotDate.month, snapshotDate.day);
        
        // If snapshot is from today, update it; otherwise create new one
        if (snapshotDayStart.isAtSameMomentAs(todayStart)) {
          // Update existing snapshot for today
          await _portfolioRepository.savePortfolioValueSnapshot(
            totalValue: _totalValue,
            change: _percentageChange,
          );
        } else {
          // Create new snapshot for today (different day)
          await _portfolioRepository.savePortfolioValueSnapshot(
            totalValue: _totalValue,
            change: _percentageChange,
          );
        }
      } else {
        // No previous snapshot, create first one
        await _portfolioRepository.savePortfolioValueSnapshot(
          totalValue: _totalValue,
          change: 0.0,
        );
      }
    } catch (e) {
      // Don't throw error for snapshot saving, just log it
      debugPrint('Failed to save portfolio snapshot: $e');
    }
  }

  // Add asset to portfolio
  Future<bool> addAsset({
    required String symbol,
    required String name,
    required double quantity,
    required double purchasePrice,
    required String assetType,
    String? logoUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final asset = PortfolioAsset(
        id: '', // Will be set by Firestore
        symbol: symbol,
        name: name,
        quantity: quantity,
        purchasePrice: purchasePrice,
        purchaseDate: DateTime.now(),
        assetType: assetType,
        logoUrl: logoUrl,
      );

      await _portfolioRepository.addPortfolioAsset(asset);
      
      if (_disposed) return false;

      // Reload portfolio and recalculate value
      await loadPortfolio();
      
      _setLoading(false);
      return true;
    } catch (e) {
      if (_disposed) return false;
      _setError('Failed to add asset: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Remove asset from portfolio
  Future<bool> removeAsset(String assetId) async {
    try {
      _setLoading(true);
      _clearError();

      await _portfolioRepository.removePortfolioAsset(assetId);
      
      if (_disposed) return false;

      // Reload portfolio and recalculate value
      await loadPortfolio();
      
      _setLoading(false);
      return true;
    } catch (e) {
      if (_disposed) return false;
      _setError('Failed to remove asset: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Refresh portfolio value (recalculate from current prices)
  Future<void> refreshPortfolioValue() async {
    await _calculatePortfolioValue();
  }

  // Get chart data (value history)
  Future<void> loadChartData({int? days}) async {
    try {
      _setLoading(true);
      _clearError();

      DateTime? startDate;
      if (days != null) {
        startDate = DateTime.now().subtract(Duration(days: days));
      }

      _valueHistory = await _portfolioRepository.getPortfolioValueHistory(
        startDate: startDate,
        limit: days,
      );
      
      if (_disposed) return;
      
      _setLoading(false);
    } catch (e) {
      if (_disposed) return;
      _setError('Failed to load chart data: ${e.toString()}');
      _setLoading(false);
    }
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

  // TEST FUNCTION: Generate sample portfolio value history for the last month
  // This is for testing purposes only
  Future<void> generateTestPortfolioHistory() async {
    try {
      _setLoading(true);
      _clearError();

      final now = DateTime.now();
      final baseValue = _totalValue > 0 ? _totalValue : 100000.0; // Use current value or default to 100k
      
      double previousValue = baseValue * 0.6; // Start value
      
      // Generate snapshots for the last 30 days
      for (int i = 29; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStart = DateTime(date.year, date.month, date.day, 12); // Set to noon for consistency
        
        // Create varying values - start lower and gradually increase with some randomness
        final dayProgress = (29 - i) / 29; // 0 to 1
        final baseProgressValue = baseValue * 0.6 + (baseValue * 0.4 * dayProgress); // Start at 60%, end at 100%
        
        // Add some randomness to make it go up and down (sine wave pattern for smooth variation)
        final sineVariation = (baseValue * 0.1) * (i % 7 - 3.5) / 3.5; // Vary by day of week
        final finalValue = baseProgressValue + sineVariation;
        
        // Calculate change from previous day
        double? change;
        if (i < 29) {
          change = ((finalValue - previousValue) / previousValue) * 100;
        }
        
        // Save snapshot with specific date
        await _portfolioRepository.savePortfolioValueSnapshot(
          totalValue: finalValue,
          change: change,
          specificDate: dateStart,
        );
        
        previousValue = finalValue;
      }
      
      if (_disposed) return;
      
      // Reload chart data
      await loadChartData(days: 30);
      
      _setLoading(false);
    } catch (e) {
      if (_disposed) return;
      _setError('Failed to generate test data: ${e.toString()}');
      _setLoading(false);
    }
  }
}
