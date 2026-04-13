import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_service.dart';
import '../../settings/providers/app_lock_provider.dart';

class NativeLockWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  
  const NativeLockWrapper({
    super.key, 
    required this.child,
    required this.navigatorKey,
  });

  @override
  ConsumerState<NativeLockWrapper> createState() => _NativeLockWrapperState();
}

class _NativeLockWrapperState extends ConsumerState<NativeLockWrapper> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isAuthenticating = false;
  bool _isInitialCheckDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final authService = ref.read(authServiceProvider);
      // Don't lock if we are currently performing a manual authentication
      if (authService.isAuthenticating) return;

      final isLockEnabledAsync = ref.read(appLockProvider);
      isLockEnabledAsync.whenData((enabled) {
        if (enabled) {
          setState(() {
            _isLocked = true;
          });
        }
      });
    } else if (state == AppLifecycleState.resumed) {
      _authenticateIfNeeded();
    }
  }

  Future<void> _authenticateIfNeeded() async {
    if (!_isLocked || _isAuthenticating) return;

    final isLockEnabledAsync = ref.read(appLockProvider);
    final isEnabled = isLockEnabledAsync.value ?? false;
    if (!isEnabled) {
      setState(() => _isLocked = false);
      return;
    }

    setState(() {
      _isAuthenticating = true;
    });

    final authService = ref.read(authServiceProvider);
    final success = await authService.authenticate();

    if (success) {
      setState(() {
        _isLocked = false;
        _isAuthenticating = false;
      });
    } else {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We listen to the provider with fireImmediately: true to handle both
    // the initial state (cold start) and subsequent changes (settings toggle).
    ref.listen(appLockProvider, (previous, next) {
      next.whenData((enabled) {
        if (enabled && !_isLocked && !_isAuthenticating) {
          // If enabled but not locked, lock it (covers cold start and turning it ON)
          setState(() {
            _isLocked = true;
          });
          _authenticateIfNeeded();
        } else if (!enabled && _isLocked) {
          // If disabled but locked, unlock it (covers turning it OFF)
          setState(() {
            _isLocked = false;
          });
        }
      });
    });

    // Manual check for initial state on cold start
    if (!_isInitialCheckDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Double check flag inside callback to avoid races
        if (!mounted || _isInitialCheckDone) return;
        
        final state = ref.read(appLockProvider);
        state.whenData((enabled) {
          if (enabled && !_isLocked && !_isAuthenticating) {
            _isInitialCheckDone = true;
            setState(() => _isLocked = true);
            _authenticateIfNeeded();
          } else if (state.hasValue) {
            // Even if not locking, mark check as done once data is loaded
            _isInitialCheckDone = true;
          }
        });
      });
    }

    // We wrap the entire app (the Navigator) in a PopScope to bridge
    // system back-button events. This ensures that sub-screens (pushed pages)
    // are popped normally rather than closing the app immediately.
    return PopScope(
      canPop: !_isLocked && !(widget.navigatorKey.currentState?.canPop() ?? false),
      onPopInvokedWithResult: (didPop, result) {
        // If the system expected a pop but it was blocked (didPop == false),
        // we check if we can manually pop the internal navigator.
        if (!didPop && !_isLocked) {
          final nav = widget.navigatorKey.currentState;
          if (nav != null && nav.canPop()) {
            nav.pop();
          }
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (_isLocked)
            Material(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(
                      Icons.lock_outline_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'SubTrack is Locked',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Authentication required'),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _authenticateIfNeeded,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: const Text('Unlock Now'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
