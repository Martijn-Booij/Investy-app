import 'package:flutter/material.dart';
import 'package:investy/utils/app_colors.dart';

class TrendingSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const TrendingSectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 8,
                    height: 8,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        AppColors.textGrey,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/icons/chevron-right.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(
          color: Colors.grey[300],
          thickness: 1,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
