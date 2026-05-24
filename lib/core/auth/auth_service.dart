import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../secure_storage/secure_storage_service.dart';
import '../../features/auth/screens/pin_entry_screen.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthService(storage);
});

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();
  final SecureStorageService _storage;
  bool isAuthenticating = false;

  AuthService(this._storage);

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
      
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    isAuthenticating = true;
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock Premio',
        biometricOnly: false,
      );
      return result;
    } on PlatformException catch (e) {
      if (e.code == 'NotEnrolled' || 
          e.code == 'noCredentialsSet' || 
          e.code == 'notEnrolled' || 
          e.code == 'no_credentials' ||
          e.code == 'PasscodeNotSet' ||
          e.code == 'passcodeNotSet' ||
          e.code == 'PermanentlyLockedOut' ||
          e.code == 'NotAvailable') {
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

  // --- Smart Verification ---

  /// Performs user verification. 
  /// Uses native authentication if the device is secure.
  /// Falls back to in-app PIN if the device is not secure.
  /// Returns true if successfully authenticated.
  Future<bool> verifyUser(BuildContext context) async {
    final isSecure = await isDeviceSecure();
    
    if (!context.mounted) return false;

    if (isSecure) {
      try {
        return await authenticate();
      } on LocalAuthException {
        // If native auth fails with an enrollment error, fall back to PIN
        return _verifyWithPin(context);
      }
    } else {
      return _verifyWithPin(context);
    }
  }

  Future<bool> _verifyWithPin(BuildContext context) async {
    final hasPin = await hasFallbackPin();
    
    if (!context.mounted) return false;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => PinEntryScreen(
          purpose: hasPin ? PinPurpose.verify : PinPurpose.set,
          onAuthenticated: () => Navigator.of(context).pop(true),
        ),
      ),
    );
    
    return result ?? false;
  }

  // --- Fallback PIN Logic ---

  Future<bool> hasFallbackPin() => _storage.hasFallbackPin();

  Future<void> setFallbackPin(String pin) => _storage.saveFallbackPin(pin);

  Future<bool> verifyFallbackPin(String inputPin) async {
    final savedPin = await _storage.getFallbackPin();
    return savedPin == inputPin;
  }

  Future<void> removeFallbackPin() => _storage.deleteFallbackPin();
}

class LocalAuthException implements Exception {
  final String code;
  final String message;

  LocalAuthException({required this.code, required this.message});

  @override
  String toString() => 'LocalAuthException: [$code] $message';
}
