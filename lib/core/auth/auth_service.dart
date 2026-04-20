import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();
  bool isAuthenticating = false;

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isDeviceSecure() async {
    try {
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      if (availableBiometrics.isNotEmpty) return true;
      
      // If no biometrics, we check if device is supported for other types (PIN/Pattern)
      // but unfortunately local_auth doesn't have a direct "hasPinSet" method.
      // However, if authenticate() throws noCredentialsSet, we know it's not secure.
      // For now, we'll assume that if it's supported, we should try.
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    isAuthenticating = true;
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock SubTrack',
        biometricOnly: false, // Allows PIN/Pattern fallback
        persistAcrossBackgrounding: true,
      );
      return result;
    } on PlatformException catch (e) {
      if (e.code == 'NotEnrolled' || 
          e.code == 'noCredentialsSet' || 
          e.code == 'notEnrolled' || 
          e.code == 'no_credentials') {
        // This is the specific error when no PIN/Pattern/Biometric is set
        throw LocalAuthException(
          code: e.code,
          message: e.message ?? 'No credentials set on device',
        );
      }
      return false;
    } finally {
      isAuthenticating = false;
    }
  }
}

class LocalAuthException implements Exception {
  final String code;
  final String message;

  LocalAuthException({required this.code, required this.message});

  @override
  String toString() => 'LocalAuthException: [$code] $message';
}
