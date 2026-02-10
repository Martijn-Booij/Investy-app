import 'package:flutter/material.dart';
import 'package:investy/widgets/app_screen.dart';
import 'package:investy/widgets/body/explore_screen_body.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScreen(
      screenName: 'Explore',
      body: ExploreScreenBody(),
      showBottomNavigation: false,
    );
  }
}
