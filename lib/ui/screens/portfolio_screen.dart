import 'package:flutter/material.dart';
import 'package:investy/widgets/app_screen.dart';
import 'package:investy/widgets/body/portfolio_screen_body.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScreen(
      screenName: 'Portfolio',
      body: PortfolioScreenBody(),
      showBottomNavigation: false,
    );
  }
}
