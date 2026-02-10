import 'package:flutter/material.dart';
import 'package:investy/widgets/app_screen.dart';
import 'package:investy/widgets/body/edit_profile_screen_body.dart';
import 'package:investy/widgets/shared/topbar/app_tobar_with_back.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      screenName: 'Edit profile',
      showTopbar: false,
      showBottomNavigation: false,
      appBar: const AppBackTopbar(title: 'Edit profile'),
      body: const EditProfileScreenBody(),
    );
  }
}
