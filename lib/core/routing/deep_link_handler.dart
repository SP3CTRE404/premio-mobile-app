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
    // We handle two formats:
    // 1. https://subtrack.app/join/CODE
    // 2. subtrack://join/CODE (for local testing/fallback)
    
    String? inviteCode;
    
    if (uri.scheme == 'subtrack' && uri.host == 'join') {
      // subtrack://join/CODE
      inviteCode = uri.path.replaceAll('/', '');
    } else if (uri.path.startsWith('/join')) {
      // https://subtrack.app/join/CODE
      inviteCode = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    }
    
    if (inviteCode != null && inviteCode.isNotEmpty && inviteCode.length >= 8) {
      debugPrint('Deep Link received: joining household with code $inviteCode');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JoinHouseholdScreen(initialCode: inviteCode!),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
