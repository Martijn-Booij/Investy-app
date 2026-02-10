import 'package:flutter/material.dart';
import 'package:investy/ui/screens/login_screen.dart';
import 'package:investy/ui/screens/register_screen.dart';
import 'package:investy/utils/app_colors.dart';
import 'package:investy/widgets/buttons/primary_button.dart';

class AuthenticationScreenBody extends StatelessWidget {
  const AuthenticationScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Logo section - centered
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 35),
                      const SizedBox(
                        width: 240,
                        child: Text(
                          'Track your investments, simple and secure.',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.textGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Buttons section - at the bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  children: [
                    PrimaryButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      text: 'Register',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

