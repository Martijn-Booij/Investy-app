import 'package:flutter/material.dart';
import 'package:investy/utils/app_colors.dart';

class PercentageBadge extends StatelessWidget {
  final double percentage;

  const PercentageBadge({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final String displayText;

    if (percentage > 0) {
      backgroundColor = AppColors.positiveChange;
      displayText = '+${percentage.toStringAsFixed(2)}%';
    } else if (percentage < 0) {
      backgroundColor = AppColors.negativeChange;
      displayText = '${percentage.toStringAsFixed(2)}%';
    } else {
      backgroundColor = AppColors.neutralChange;
      displayText = '0%';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: backgroundColor,
        ),
      ),
    );
  }
}
