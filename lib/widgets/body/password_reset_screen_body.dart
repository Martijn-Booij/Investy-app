import 'package:flutter/material.dart';
import 'package:investy/utils/app_colors.dart';
import 'package:investy/viewmodel/auth_viewmodel.dart';
import 'package:investy/widgets/buttons/primary_button.dart';
import 'package:investy/widgets/inputs/app_text_field.dart';

class PasswordResetScreenBody extends StatefulWidget {
  const PasswordResetScreenBody({super.key});

  @override
  State<PasswordResetScreenBody> createState() => _PasswordResetScreenBodyState();
}

class _PasswordResetScreenBodyState extends State<PasswordResetScreenBody> {
  final AuthViewModel _authViewModel = AuthViewModel();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
                // Logo section - centered vertically
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
                        const SizedBox(height: 10),
                        const SizedBox(
                          width: 240,
                          child: Text(
                            'Reset your password',
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
                // Input field and button section - scrollable
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
                      const SizedBox(height: 24),
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
                                  text: 'Send reset link',
                                  onPressed: _authViewModel.isLoading
                                      ? null
                                      : () async {
                                          if (!_formKey.currentState!.validate()) return;
                                          
                                          final success = await _authViewModel.sendPasswordResetEmail(
                                            _emailController.text.trim(),
                                          );

                                          if (!mounted) return;
                                          
                                          if (success) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'If an account exists with this email, a password reset link has been sent.',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
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

