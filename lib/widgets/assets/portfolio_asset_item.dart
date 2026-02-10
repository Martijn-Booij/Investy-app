import 'package:flutter/material.dart';
import 'package:investy/utils/app_colors.dart';
import 'package:investy/widgets/assets/percentage_badge.dart';

class PortfolioAssetItem extends StatelessWidget {
  final String name;
  final String ticker;
  final double value;
  final double percentageChange;
  final String? quantity;
  final Color logoColor;
  final String? logoUrl;
  final bool isCrypto;

  const PortfolioAssetItem({
    super.key,
    required this.name,
    required this.ticker,
    required this.value,
    required this.percentageChange,
    this.quantity,
    this.logoColor = Colors.grey,
    this.logoUrl,
    this.isCrypto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo - try to load from URL, fallback to colored circle
          _buildLogo(),
          const SizedBox(width: 12),
          // Name and ticker - fixed width to align badges
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  ticker,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Percentage badge - fixed position
          PercentageBadge(percentage: percentageChange),
          const Spacer(),
          // Value and quantity
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${value.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (quantity != null) ...[
                const SizedBox(height: 2),
                Text(
                  quantity!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    // Use provided logoUrl or fallback to colored circle
    final url = logoUrl;

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
          : null, // Just show colored circle if no URL
    );
  }
}
