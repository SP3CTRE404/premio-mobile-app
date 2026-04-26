import 'package:flutter/material.dart';
import '../../../auth/widgets/auth_background.dart';
import '../../../auth/widgets/auth_header.dart';

class HouseholdFormLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const HouseholdFormLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  AuthHeader(
                    title: title,
                    subtitle: subtitle,
                  ),
                  const SizedBox(height: 32),
                  child,
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
