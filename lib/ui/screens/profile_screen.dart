import 'package:flutter/material.dart';
import 'package:investy/widgets/app_screen.dart';
import 'package:investy/widgets/body/profile_screen_body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScreen(
      screenName: 'Profile',
      body: ProfileScreenBody(),
      showBottomNavigation: false,
    );
  }
}
