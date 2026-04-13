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

  Future<bool> authenticate() async {
    isAuthenticating = true;
    try {
      final result = await _auth.authenticate(
        localizedReason: ' ',
        biometricOnly: false, // Allows PIN/Pattern fallback
        persistAcrossBackgrounding: true, // Replaces stickyAuth
      );
      return result;
    } on PlatformException {
      return false;
    } finally {
      isAuthenticating = false;
    }
  }
}
