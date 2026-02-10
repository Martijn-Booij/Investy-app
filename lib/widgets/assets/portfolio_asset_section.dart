import 'package:flutter/material.dart';
import 'package:investy/utils/app_colors.dart';

class PortfolioAssetSection extends StatelessWidget {
  final String title;
  final List<Widget> assets;
  final VoidCallback? onAdd;

  const PortfolioAssetSection({
    super.key,
    required this.title,
    required this.assets,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Divider(
          color: Colors.grey[300],
          thickness: 1,
        ),
        if (assets.isEmpty)
          _buildEmptyState()
        else
          ...assets,
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: AppColors.textGrey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.add,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    // Determine asset type from title
    final isStocks = title.toLowerCase().contains('stock');
    final assetType = isStocks ? 'stocks' : 'crypto';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              isStocks ? Icons.trending_up : Icons.currency_bitcoin,
              size: 48,
              color: AppColors.textGrey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No $assetType yet',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first $assetType to get started',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
