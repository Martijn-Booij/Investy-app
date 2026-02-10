import 'package:flutter/material.dart';
import 'package:investy/widgets/assets/percentage_badge.dart';

class TrendingAssetCard extends StatelessWidget {
  final String ticker;
  final double price;
  final double percentageChange;
  final Color logoColor;
  final String? logoUrl;
  final bool isCrypto;

  const TrendingAssetCard({
    super.key,
    required this.ticker,
    required this.price,
    required this.percentageChange,
    this.logoColor = Colors.grey,
    this.logoUrl,
    this.isCrypto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo - try to load from URL, fallback to colored circle
              _buildLogo(),
              PercentageBadge(percentage: percentageChange),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticker,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '€${price.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    // Use provided logoUrl or fallback to colored circle
    final url = logoUrl;

    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        return ClipOval(
          child: Image.asset(
            url,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to colored circle if asset fails to load
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: logoColor,
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        );
      } else {
        return ClipOval(
          child: Image.network(
            url,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to colored circle if network image fails to load
              return Container(
                width: 40,
                height: 40,
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
              // Show colored circle with loading indicator while loading
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: logoColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
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
        );
      }
    }

    // Just show colored circle if no URL
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: logoColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
