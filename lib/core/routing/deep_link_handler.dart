import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/household/screens/join_household_screen.dart';

/// Handles deep links while ensuring the app's auth flow completes first.
///
/// Deep links that arrive during splash/loading are cached and consumed
/// only after the user is authenticated and the MainScaffold is mounted.
class DeepLinkHandler extends ConsumerStatefulWidget {
  final Widget child;

  const DeepLinkHandler({super.key, required this.child});

  @override
  ConsumerState<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends ConsumerState<DeepLinkHandler> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  
  /// Cached deep link URI received before auth was ready.
  Uri? _pendingDeepLink;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Check initial link if app was opened from a link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleLink(uri);
    });

    // Handle links incoming while app is in foreground or background
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  void _handleLink(Uri uri) {
    // We handle two formats:
    // 1. https://premio.app/join/CODE
    // 2. premio://join/CODE (for local testing/fallback)
    
    String? inviteCode;
    
    if (uri.scheme == 'premio' && uri.host == 'join') {
      // premio://join/CODE
      inviteCode = uri.path.replaceAll('/', '');
    } else if (uri.path.startsWith('/join')) {
      // https://premio.app/join/CODE
      inviteCode = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    }
    
    if (inviteCode != null && inviteCode.isNotEmpty && inviteCode.length >= 8) {
      debugPrint('Deep Link received: joining household with code $inviteCode');
      
      // Check if auth is ready before navigating
      final authStatus = ref.read(authProvider);
      if (authStatus == AuthStatus.authenticated) {
        _navigateToJoin(inviteCode);
      } else {
        // Cache the link — it will be consumed once auth completes
        _pendingDeepLink = uri;
        debugPrint('Auth not ready yet. Caching deep link for later.');
      }
    }
  }

  void _navigateToJoin(String inviteCode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinHouseholdScreen(initialCode: inviteCode),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth status changes to consume pending deep links
    ref.listen<AuthStatus>(authProvider, (previous, next) {
      if (next == AuthStatus.authenticated && _pendingDeepLink != null) {
        debugPrint('Auth ready — consuming cached deep link.');
        final cachedLink = _pendingDeepLink!;
        _pendingDeepLink = null;
        _handleLink(cachedLink);
      }
    });

    return widget.child;
  }
}
