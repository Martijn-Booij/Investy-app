import 'package:flutter/material.dart';
import 'package:investy/widgets/shared/topbar/app_topbar.dart';
import 'package:investy/widgets/shared/bottom_navigation/app_bottom_navigation.dart';

class AppScreen extends StatelessWidget {
  final String screenName;
  final Widget body;
  final bool showTopbar;
  final bool showBottomNavigation;
  final int? bottomNavigationIndex;
  final Function(int)? onBottomNavigationTap;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;

  const AppScreen({
    super.key,
    required this.screenName,
    required this.body,
    this.showTopbar = true,
    this.showBottomNavigation = true,
    this.bottomNavigationIndex,
    this.onBottomNavigationTap,
    this.backgroundColor,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar ?? (showTopbar ? _buildTopbarAppBar() : null),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar ?? 
          (showBottomNavigation && bottomNavigationIndex != null && onBottomNavigationTap != null
              ? AppBottomNavigation(
                  currentIndex: bottomNavigationIndex!,
                  onTap: onBottomNavigationTap!,
                )
              : null),
    );
  }

  PreferredSizeWidget _buildTopbarAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: AppTopbar(screenName: screenName),
    );
  }
}
