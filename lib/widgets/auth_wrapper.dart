import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investy/ui/screens/authentication_screen.dart';
import 'package:investy/widgets/navigation_wrapper.dart';
import 'package:investy/services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticated = false;
  bool _isCheckingBiometric = false;
  DateTime? _lastBackgroundTime;
  static const String _lastBackgroundTimeKey = 'last_background_time';
  static const int _backgroundTimeoutSeconds = 5; // Consider app closed if backgrounded for more than 5 seconds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastBackgroundTime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App went to background
      _saveLastBackgroundTime();
    } else if (state == AppLifecycleState.resumed) {
      // App came to foreground
      _checkIfAppWasReopened();
    }
  }

  Future<void> _loadLastBackgroundTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastBackgroundTimeKey);
      if (timestamp != null) {
        _lastBackgroundTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _saveLastBackgroundTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastBackgroundTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<bool> _wasAppClosed() async {
    if (_lastBackgroundTime == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(_lastBackgroundTime!);
    
    // Consider app closed if it was in background for more than the timeout
    return difference.inSeconds > _backgroundTimeoutSeconds;
  }

  Future<void> _checkIfAppWasReopened() async {
    if (!mounted) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in, mark as authenticated (no biometric needed)
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
        });
      }
      return;
    }
    
    final wasClosed = await _wasAppClosed();
    // On first app start, if there's a stored background time, consider it as reopened
    // Otherwise, if app was just resumed (not closed), skip biometric
    if (!wasClosed && _lastBackgroundTime != null) {
      // App was just resumed, not reopened - allow access
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
        });
      }
      return;
    }
    
    final biometricEnabled = await _biometricService.isBiometricEnabled();
    if (!biometricEnabled) {
      // Biometric not enabled - allow access
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
        });
      }
      return;
    }
    
    // Check if biometric is available
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!isAvailable) {
      // Biometric not available - allow access (fallback)
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
        });
      }
      return;
    }
    
    // Show biometric prompt
    if (mounted && !_isAuthenticated && !_isCheckingBiometric) {
      await _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (!mounted) return;
    
    setState(() {
      _isCheckingBiometric = true;
    });

    try {
      final availableBiometrics = await _biometricService.getAvailableBiometrics();
      final biometricName = _biometricService.getBiometricTypeName(availableBiometrics);
      
      final authenticated = await _biometricService.authenticate(
        reason: 'Please use $biometricName to access your account',
      );

      if (mounted) {
        setState(() {
          _isCheckingBiometric = false;
          if (authenticated) {
            _isAuthenticated = true;
          } else {
            // Biometric failed or cancelled - sign out and show login
            FirebaseAuth.instance.signOut();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingBiometric = false;
        });
        // On error, sign out and show login
        FirebaseAuth.instance.signOut();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state or biometric
        if (snapshot.connectionState == ConnectionState.waiting || _isCheckingBiometric) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (_isCheckingBiometric) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Please authenticate',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // If user is logged in, check if we need biometric authentication
        if (snapshot.hasData && snapshot.data != null) {
          // Check biometric on first load if app was closed
          if (!_isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (mounted) {
                await _checkIfAppWasReopened();
                // If still not authenticated after check, it means biometric is not needed
                // or was cancelled - allow access (biometric is optional security layer)
                if (mounted && !_isCheckingBiometric) {
                  setState(() {
                    _isAuthenticated = true;
                  });
                }
              }
            });
            // Show loading while checking
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // User is authenticated (either no biometric needed or biometric passed)
          return const NavigationWrapper();
        }

        // If user is not logged in, show authentication screen
        // Reset authentication state
        if (_isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isAuthenticated = false;
              });
            }
          });
        }
        
        return const AuthenticationScreen();
      },
    );
  }
}
