import 'package:flutter/material.dart';
import 'package:investy/ui/screens/home_screen.dart';
import 'package:investy/ui/screens/portfolio_screen.dart';
// import 'package:investy/ui/screens/explore_screen.dart';
import 'package:investy/ui/screens/profile_screen.dart';
import 'package:investy/widgets/shared/bottom_navigation/app_bottom_navigation.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> _getScreens() {
    return [
      const HomeScreen(),
      const PortfolioScreen(),
      // const ExploreScreen(), // Commented out - not developed yet
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _getScreens(),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavigationTap,
      ),
    );
  }
}
