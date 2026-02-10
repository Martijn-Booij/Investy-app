import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> checkBiometricSupport() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Get a user-friendly name for the biometric type
  String getBiometricTypeName(List<BiometricType> availableBiometrics) {
    if (availableBiometrics.isEmpty) {
      return 'Biometric';
    }

    // Check for Face ID (iOS) or Face (Android)
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    }

    // Check for Touch ID (iOS) or Fingerprint (Android)
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    }

    // Check for other types
    if (availableBiometrics.contains(BiometricType.strong)) {
      return 'Biometric';
    }

    if (availableBiometrics.contains(BiometricType.weak)) {
      return 'Biometric';
    }

    return 'Biometric';
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({String? reason}) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true, // Only use biometrics, not device PIN/password
          stickyAuth: true, // Keep authentication dialog open if user switches apps
        ),
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric authentication is enabled in app settings
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_biometricEnabledKey, true);
    } catch (e) {
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_biometricEnabledKey, false);
    } catch (e) {
      return false;
    }
  }

  /// Check if biometrics are available and enrolled on device
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await checkBiometricSupport();
      if (!canCheck) return false;

      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
