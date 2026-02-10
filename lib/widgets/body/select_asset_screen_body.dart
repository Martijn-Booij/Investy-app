import 'dart:async';
import 'package:flutter/material.dart';
import 'package:investy/widgets/assets/portfolio_asset_item.dart';
import 'package:investy/ui/screens/add_asset_screen.dart';
import 'package:investy/viewmodel/asset_viewmodel.dart';
import 'package:investy/datamodel/asset_model.dart';

enum AssetType { stocks, crypto }

class SelectAssetScreenBody extends StatefulWidget {
  final AssetType assetType;

  const SelectAssetScreenBody({
    super.key,
    required this.assetType,
  });

  @override
  State<SelectAssetScreenBody> createState() => _SelectAssetScreenBodyState();
}

class _SelectAssetScreenBodyState extends State<SelectAssetScreenBody> {
  final TextEditingController _searchController = TextEditingController();
  final AssetViewModel _assetViewModel = AssetViewModel();
  List<AssetModel> _filteredAssets = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _assetViewModel.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    // Load popular assets (empty query shows popular)
    await _assetViewModel.searchAssets('', widget.assetType);
    if (mounted) {
      setState(() {
        _filteredAssets = _assetViewModel.searchResults;
      });
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _filterAssets();
    });
  }

  Future<void> _filterAssets() async {
    final query = _searchController.text;
    await _assetViewModel.searchAssets(query, widget.assetType);
    if (mounted) {
      setState(() {
        _filteredAssets = _assetViewModel.searchResults;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search....',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[400]!,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: Icon(
                Icons.search,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
        // Asset list
        Expanded(
          child: _assetViewModel.isLoading && _filteredAssets.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _filteredAssets.isEmpty
                  ? Center(
                      child: Text(
                        _assetViewModel.errorMessage ?? 'No assets found',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredAssets.length,
                      itemBuilder: (context, index) {
                        final asset = _filteredAssets[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddAssetScreen(
                                  asset: asset,
                                  assetType: widget.assetType,
                                ),
                              ),
                            );
                          },
                          child: PortfolioAssetItem(
                            name: asset.name,
                            ticker: asset.symbol,
                            value: asset.currentPrice ?? 0.0,
                            percentageChange: asset.percentChange ?? 0.0,
                            logoColor: asset.logoColor ?? Colors.grey,
                            logoUrl: asset.logoUrl,
                            isCrypto: widget.assetType == AssetType.crypto,
                            // No quantity for available assets
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
