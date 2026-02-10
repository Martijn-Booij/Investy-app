import 'package:flutter/material.dart';
import 'package:investy/ui/screens/password_reset_screen.dart';
import 'package:investy/ui/screens/register_screen.dart';
import 'package:investy/widgets/navigation_wrapper.dart';
import 'package:investy/utils/app_colors.dart';
import 'package:investy/viewmodel/auth_viewmodel.dart';
import 'package:investy/widgets/buttons/primary_button.dart';
import 'package:investy/widgets/inputs/app_text_field.dart';

class LoginScreenBody extends StatefulWidget {
  const LoginScreenBody({super.key});

  @override
  State<LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody> {
  final AuthViewModel _authViewModel = AuthViewModel();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Image.asset(
                      'assets/icons/arrow-left.png',
                      width: 24,
                      height: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(
                          width: 240,
                          child: Text(
                            'Login with your account',
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
                const SizedBox(height: 24),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      Transform.translate(
                        offset: const Offset(0, -8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PasswordResetScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot your password?',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Button section
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: ListenableBuilder(
                    listenable: _authViewModel,
                    builder: (context, _) {
                      return Column(
                        children: [
                          if (_authViewModel.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                _authViewModel.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          PrimaryButton(
                            text: 'Login',
                            onPressed: _authViewModel.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final success = await _authViewModel.login(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      );

                                      if (!mounted) return;
                                      
                                      if (success) {
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => const NavigationWrapper(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    }
                                  },
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text.rich(
                          TextSpan(
                            text: 'Do not have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                            children: [
                              TextSpan(
                                text: 'Register now!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

