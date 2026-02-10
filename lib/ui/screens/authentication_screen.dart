import 'package:flutter/material.dart';
import 'package:investy/widgets/body/authentication_screen_body.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AuthenticationScreenBody(),
    );
  }
}

