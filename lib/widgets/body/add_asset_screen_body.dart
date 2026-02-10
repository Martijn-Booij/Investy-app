import 'package:flutter/material.dart';
import 'package:investy/datamodel/asset_model.dart';
import 'package:investy/utils/app_colors.dart';
import 'package:investy/viewmodel/portfolio_viewmodel.dart';
import 'package:investy/widgets/body/select_asset_screen_body.dart'
    show AssetType;
import 'package:provider/provider.dart';

class AddAssetScreenBody extends StatefulWidget {
  final AssetModel asset;
  final AssetType assetType;

  const AddAssetScreenBody({
    super.key,
    required this.asset,
    required this.assetType,
  });

  @override
  State<AddAssetScreenBody> createState() => _AddAssetScreenBodyState();
}

class _AddAssetScreenBodyState extends State<AddAssetScreenBody> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _insertCurrentPrice() {
    setState(() {
      _priceController.text = (widget.asset.currentPrice ?? 0.0).toStringAsFixed(2);
    });
  }

  Future<void> _handleAdd() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(_priceController.text);
    final amount = double.tryParse(_amountController.text);

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final portfolioViewModel = Provider.of<PortfolioViewModel>(context, listen: false);
      
      final success = await portfolioViewModel.addAsset(
        symbol: widget.asset.symbol,
        name: widget.asset.name,
        quantity: amount,
        purchasePrice: price,
        assetType: widget.assetType == AssetType.stocks ? 'stock' : 'crypto',
        logoUrl: widget.asset.logoUrl,
      );

      if (!mounted) return;

      if (success) {
        // Pop both Add Asset Screen and Select Asset Screen to return to Portfolio
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(portfolioViewModel.errorMessage ?? 'Failed to add asset'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Asset info - icon, name, ticker
                  Row(
                    children: [
                      // Logo
                      _buildLogo(),
                      const SizedBox(width: 16),
                      // Name and ticker
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.asset.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.asset.symbol,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Price per asset input
                  Text(
                    'Price per asset',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter price per asset',
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
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: TextButton(
                        onPressed: _insertCurrentPrice,
                        child: Text(
                          'Current',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Amount of assets input
                  Text(
                    'Amount of asset',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
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
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Add button at bottom
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    // Use logoUrl from asset or fallback to colored circle
    final url = widget.asset.logoUrl;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: widget.asset.logoColor ?? Colors.grey,
        shape: BoxShape.circle,
      ),
      child: url != null && url.isNotEmpty
          ? ClipOval(
              child: url.startsWith('assets/')
                  ? Image.asset(
                      url,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: widget.asset.logoColor ?? Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    )
                  : Image.network(
                      url,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: widget.asset.logoColor ?? Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: widget.asset.logoColor ?? Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
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
          : null, // Just show colored circle if no URL
    );
  }
}
