import 'package:flutter/material.dart';
import 'package:investy/utils/app_colors.dart';
import 'package:investy/viewmodel/user_viewmodel.dart';
import 'package:investy/viewmodel/portfolio_viewmodel.dart';
import 'package:investy/viewmodel/auth_viewmodel.dart';
import 'package:investy/datamodel/user_model.dart';
import 'package:investy/ui/screens/edit_profile_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreenBody extends StatefulWidget {
  const ProfileScreenBody({super.key});

  @override
  State<ProfileScreenBody> createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody> {
  final UserViewModel _userViewModel = UserViewModel();
  final AuthViewModel _authViewModel = AuthViewModel();
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _userViewModel.dispose();
    _authViewModel.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await _userViewModel.getCurrentUserData();
    if (mounted) {
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    }
  }

  String _getDisplayName() {
    if (_userData == null) return 'Not set';
    return _userData!.fullName ?? _userData!.username;
  }

  String _getValue(String? value) {
    return value ?? 'Not set';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_userData == null) {
      return const Center(
        child: Text('Failed to load user data'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture and name section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile picture
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/profile.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getDisplayName(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '@${_userData!.username}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // User information section
                    _buildInfoRow('Email', _userData!.email, Icons.email),
                    const SizedBox(height: 16),
                    _buildInfoRow('Phone', _getValue(_userData!.phoneNumber), Icons.phone),
                    const SizedBox(height: 16),
                    _buildInfoRow('Country', _getValue(_userData!.country), Icons.location_on),
                    const SizedBox(height: 32),
                    // Test data generation button
                    _buildTestDataButton(),
                    const SizedBox(height: 16),
                    // Logout button
                    _buildLogoutButton(),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 80),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  // Refresh data if profile was updated
                  if (result == true) {
                    _loadUserData();
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestDataButton() {
    return Consumer<PortfolioViewModel>(
      builder: (context, portfolioViewModel, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: portfolioViewModel.isLoading
                ? null
                : () async {
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Generate Test Data'),
                        content: const Text(
                          'This will generate portfolio value history for the last 30 days. This is for testing purposes only.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                            child: const Text('Generate'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      await portfolioViewModel.generateTestPortfolioHistory();
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              portfolioViewModel.errorMessage ??
                                  'Test data generated successfully!',
                            ),
                            backgroundColor: portfolioViewModel.errorMessage != null
                                ? Colors.red
                                : Colors.green,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: AppColors.textGrey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: portfolioViewModel.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.data_object, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Generate Test Portfolio Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Log Out'),
              content: const Text(
                'Are you sure you want to log out?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Log Out'),
                ),
              ],
            ),
          );

          if (confirmed == true && mounted) {
            try {
              await _authViewModel.logout();
              
              if (mounted) {
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Navigation will be handled automatically by AuthWrapper
                // when it detects the auth state change
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error logging out: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.red[300]!, width: 1),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
