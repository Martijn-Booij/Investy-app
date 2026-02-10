import 'package:flutter/material.dart';
import 'package:investy/widgets/assets/portfolio_value_header.dart';
import 'package:investy/widgets/assets/trending_section_header.dart';
import 'package:investy/widgets/assets/trending_asset_card.dart';
import 'package:investy/viewmodel/asset_viewmodel.dart';
import 'package:investy/utils/format_utils.dart';
import 'package:investy/viewmodel/portfolio_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final AssetViewModel _assetViewModel = AssetViewModel();

  @override
  void initState() {
    super.initState();
    // Listen to ViewModel changes
    _assetViewModel.addListener(_onViewModelChanged);
    _loadData();
    
    // Load portfolio data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final portfolioViewModel = Provider.of<PortfolioViewModel>(context, listen: false);
        portfolioViewModel.loadPortfolio();
      }
    });
  }

  @override
  void dispose() {
    _assetViewModel.removeListener(_onViewModelChanged);
    _assetViewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    // Rebuild widget when ViewModel state changes
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _assetViewModel.fetchTrendingStocks(),
      _assetViewModel.fetchTrendingCrypto(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioViewModel>(
      builder: (context, portfolioViewModel, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PortfolioValueHeader(
                  portfolioValue: FormatUtils.formatCurrency(portfolioViewModel.totalValue),
                  percentageChange: portfolioViewModel.percentageChange,
                  valueHistory: portfolioViewModel.valueHistory,
                ),
            const SizedBox(height: 32),
            // Trending Stocks section
            TrendingSectionHeader(
              title: 'Trending Stocks',
              onSeeAll: () {
              },
            ),
            SizedBox(
              height: 120,
              child: _buildTrendingStocksList(),
            ),
            const SizedBox(height: 32),
            // Trending Crypto section
            TrendingSectionHeader(
              title: 'Trending Crypto',
              onSeeAll: () {
              },
            ),
            SizedBox(
              height: 120,
              child: _buildTrendingCryptoList(),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildTrendingStocksList() {
    if (_assetViewModel.isLoading && _assetViewModel.trendingStocks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assetViewModel.trendingStocks.isEmpty && _assetViewModel.errorMessage != null) {
      return Center(
        child: Text(
          _assetViewModel.errorMessage!,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      children: _assetViewModel.trendingStocks.map((asset) {
        return TrendingAssetCard(
          ticker: asset.symbol,
          price: asset.currentPrice ?? 0.0,
          percentageChange: asset.percentChange ?? 0.0,
          logoColor: asset.logoColor ?? Colors.grey,
          logoUrl: asset.logoUrl,
          isCrypto: false,
        );
      }).toList(),
    );
  }

  Widget _buildTrendingCryptoList() {
    if (_assetViewModel.isLoading && _assetViewModel.trendingCrypto.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assetViewModel.trendingCrypto.isEmpty && _assetViewModel.errorMessage != null) {
      return Center(
        child: Text(
          _assetViewModel.errorMessage!,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      children: _assetViewModel.trendingCrypto.map((asset) {
        final displaySymbol = asset.symbol.contains(':')
            ? asset.symbol.split(':')[1].replaceAll('USDT', '')
            : asset.symbol;
        
        return TrendingAssetCard(
          ticker: displaySymbol,
          price: asset.currentPrice ?? 0.0,
          percentageChange: asset.percentChange ?? 0.0,
          logoColor: asset.logoColor ?? Colors.grey,
          logoUrl: asset.logoUrl,
          isCrypto: true,
        );
      }).toList(),
    );
  }
}

