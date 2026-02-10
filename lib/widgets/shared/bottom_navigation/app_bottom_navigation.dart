import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:investy/utils/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: _buildSvgIcon('assets/icons/home.svg', isSelected: currentIndex == 0),
            activeIcon: _buildSvgIcon('assets/icons/home.svg', isSelected: true),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildSvgIcon('assets/icons/portfolio.svg', isSelected: currentIndex == 1),
            activeIcon: _buildSvgIcon('assets/icons/portfolio.svg', isSelected: true),
            label: 'Portfolio',
          ),
          // BottomNavigationBarItem(
          //   icon: _buildSvgIcon('assets/icons/news.svg', isSelected: currentIndex == 2),
          //   activeIcon: _buildSvgIcon('assets/icons/news.svg', isSelected: true),
          //   label: 'Explore',
          // ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSvgIcon(String assetPath, {required bool isSelected}) {
    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isSelected ? AppColors.primary : AppColors.textGrey,
        BlendMode.srcIn,
      ),
    );
  }
}
