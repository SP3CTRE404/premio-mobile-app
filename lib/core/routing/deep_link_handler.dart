import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../../features/household/screens/join_household_screen.dart';

class DeepLinkHandler extends StatefulWidget {
  final Widget child;

  const DeepLinkHandler({super.key, required this.child});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

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
    // Expected: https://subtrack.app/join/CODE
    if (uri.path.startsWith('/join')) {
      final code = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
      
      if (code != null && code.isNotEmpty) {
        // Navigate to JoinHouseholdScreen
        // Note: Using findAncestorStateOfType or similar might be complex here.
        // A simple way is to use a context-based navigation if ready, 
        // but since this is usually wrapping the MaterialApp, we might need a GlobalKey.
        
        // For simplicity, we'll use a post-frame callback to ensure context is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JoinHouseholdScreen(initialCode: code),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
