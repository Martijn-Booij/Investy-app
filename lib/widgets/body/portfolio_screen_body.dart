import 'package:flutter/material.dart';
import 'package:investy/ui/screens/select_asset_screen.dart';
import 'package:investy/widgets/body/select_asset_screen_body.dart'
    show AssetType;
import 'package:investy/widgets/assets/portfolio_value_header.dart';
import 'package:investy/widgets/assets/portfolio_asset_section.dart';
import 'package:investy/viewmodel/portfolio_viewmodel.dart';
import 'package:investy/datamodel/portfolio_asset_model.dart';
import 'package:investy/viewmodel/asset_viewmodel.dart';
import 'package:investy/datamodel/asset_model.dart';
import 'package:investy/utils/format_utils.dart';
import 'package:provider/provider.dart';

class PortfolioScreenBody extends StatefulWidget {
  const PortfolioScreenBody({super.key});

  @override
  State<PortfolioScreenBody> createState() => _PortfolioScreenBodyState();
}

class _PortfolioScreenBodyState extends State<PortfolioScreenBody> {
  final AssetViewModel _assetViewModel = AssetViewModel();
  Map<String, AssetModel> _currentPrices = {}; // Cache of current prices
  Set<String> _deletingAssetIds = {}; // Track assets being deleted

  @override
  void initState() {
    super.initState();
    // Load portfolio after first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final portfolioViewModel = Provider.of<PortfolioViewModel>(context, listen: false);
        portfolioViewModel.loadPortfolio().then((_) {
          if (mounted) {
            _loadCurrentPrices();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _assetViewModel.dispose();
    super.dispose();
  }

  // Load current prices for all portfolio assets
  Future<void> _loadCurrentPrices() async {
    if (!mounted) return;
    
    final portfolioViewModel = Provider.of<PortfolioViewModel>(context, listen: false);
    final assets = portfolioViewModel.portfolioAssets;
    
    if (assets.isEmpty) return;

    try {
      // Separate stocks and crypto
      final stockAssets = assets.where((a) => a.assetType == 'stock').toList();
      final cryptoAssets = assets.where((a) => a.assetType == 'crypto').toList();

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
          ? await _assetViewModel.getPortfolioAssets(stockSymbols, symbolNames: stockNames, isCrypto: false)
          : <String, AssetModel>{};
      
      final cryptoQuotes = cryptoSymbols.isNotEmpty
          ? await _assetViewModel.getPortfolioAssets(cryptoSymbols, symbolNames: cryptoNames, isCrypto: true)
          : <String, AssetModel>{};

      if (mounted) {
        setState(() {
          _currentPrices = {...stockQuotes, ...cryptoQuotes};
        });
      }
    } catch (e) {
      // Error loading prices - continue with existing prices
      debugPrint('Error loading current prices: $e');
    }
  }

  // Refresh prices when portfolio changes
  void _refreshPrices() {
    if (mounted) {
      _loadCurrentPrices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioViewModel>(
      builder: (context, portfolioViewModel, child) {
        // Refresh prices when portfolio assets change
        if (portfolioViewModel.portfolioAssets.length != _currentPrices.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refreshPrices();
          });
        }

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
                // Your stocks section
                PortfolioAssetSection(
                  title: 'Your stocks',
                  assets: _buildPortfolioItems(
                    portfolioViewModel.getStocks(),
                    portfolioViewModel,
                  ),
                  onAdd: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectAssetScreen(
                          assetType: AssetType.stocks,
                        ),
                      ),
                    ).then((_) {
                      // Refresh portfolio after returning from add asset screen
                      portfolioViewModel.loadPortfolio();
                    });
                  },
                ),
                const SizedBox(height: 32),
                // Your crypto section
                PortfolioAssetSection(
                  title: 'Your crypto',
                  assets: _buildPortfolioItems(
                    portfolioViewModel.getCrypto(),
                    portfolioViewModel,
                  ),
                  onAdd: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectAssetScreen(
                          assetType: AssetType.crypto,
                        ),
                      ),
                    ).then((_) {
                      // Refresh portfolio after returning from add asset screen
                      portfolioViewModel.loadPortfolio();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPortfolioItems(
    List<PortfolioAsset> assets,
    PortfolioViewModel portfolioViewModel,
  ) {
    if (assets.isEmpty) {
      return [];
    }

    // Filter out assets that are being deleted
    final visibleAssets = assets.where((asset) => !_deletingAssetIds.contains(asset.id)).toList();

    return visibleAssets.map((portfolioAsset) {
      final currentPrice = _currentPrices[portfolioAsset.symbol];
      final currentValue = (currentPrice?.currentPrice ?? 0.0) * portfolioAsset.quantity;
      final percentageChange = currentPrice?.percentChange ?? 0.0;

      // Format quantity string
      final quantityString = portfolioAsset.assetType == 'stock'
          ? '${portfolioAsset.quantity.toStringAsFixed(0)} shares'
          : '${portfolioAsset.quantity.toStringAsFixed(4)} ${portfolioAsset.symbol}';

      return Dismissible(
        key: Key(portfolioAsset.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 28,
          ),
        ),
        confirmDismiss: (direction) async {
          // Show confirmation dialog
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Remove Asset'),
              content: Text('Are you sure you want to remove ${portfolioAsset.name} from your portfolio?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) {
          // Immediately mark as deleting to remove from UI
          setState(() {
            _deletingAssetIds.add(portfolioAsset.id);
          });

          // Perform async deletion
          portfolioViewModel.removeAsset(portfolioAsset.id).then((success) {
            if (mounted) {
              setState(() {
                _deletingAssetIds.remove(portfolioAsset.id);
              });

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${portfolioAsset.name} removed from portfolio'),
                    backgroundColor: Colors.green,
                  ),
                );
                _refreshPrices();
              } else {
                // Reload portfolio to restore the item if deletion failed
                portfolioViewModel.loadPortfolio();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(portfolioViewModel.errorMessage ?? 'Failed to remove asset'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          });
        },
        child: _PortfolioAssetItemWidget(
          portfolioAsset: portfolioAsset,
          currentValue: currentValue,
          percentageChange: percentageChange,
          quantityString: quantityString,
          logoUrl: currentPrice?.logoUrl ?? portfolioAsset.logoUrl,
          isCrypto: portfolioAsset.assetType == 'crypto',
        ),
      );
    }).toList();
  }
}

// Widget to display portfolio asset item
class _PortfolioAssetItemWidget extends StatelessWidget {
  final PortfolioAsset portfolioAsset;
  final double currentValue;
  final double percentageChange;
  final String quantityString;
  final String? logoUrl;
  final bool isCrypto;

  const _PortfolioAssetItemWidget({
    required this.portfolioAsset,
    required this.currentValue,
    required this.percentageChange,
    required this.quantityString,
    this.logoUrl,
    required this.isCrypto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLogo(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portfolioAsset.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  portfolioAsset.symbol,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Percentage badge
          _buildPercentageBadge(),
          const SizedBox(width: 16),
          // Value and quantity
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${currentValue.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                quantityString,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final url = logoUrl;
    final logoColor = _getLogoColor();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: logoColor,
        shape: BoxShape.circle,
      ),
      child: url != null && url.isNotEmpty
          ? ClipOval(
              child: url.startsWith('assets/')
                  ? Image.asset(
                      url,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: logoColor,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    )
                  : Image.network(
                      url,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: logoColor,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: logoColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            )
          : null,
    );
  }

  Widget _buildPercentageBadge() {
    Color backgroundColor;
    if (percentageChange > 0) {
      backgroundColor = Colors.green;
    } else if (percentageChange < 0) {
      backgroundColor = Colors.red;
    } else {
      backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(2)}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: backgroundColor,
        ),
      ),
    );
  }

  Color _getLogoColor() {
    if (isCrypto) {
      switch (portfolioAsset.symbol.toUpperCase()) {
        case 'BTC':
          return const Color(0xFFF7931A);
        case 'ETH':
          return const Color(0xFF627EEA);
        case 'SOL':
          return const Color(0xFF9945FF);
        case 'ADA':
          return const Color(0xFF0033AD);
        default:
          return Colors.grey;
      }
    }
    return Colors.grey;
  }
}
