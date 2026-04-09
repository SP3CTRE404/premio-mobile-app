import 'package:flutter/material.dart';

import '../widgets/about_section.dart';
import '../widgets/look_and_feel_section.dart';
import '../widgets/settings_section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          SettingsSectionHeader(title: 'Look and Feel'),
          LookAndFeelSection(),
          SizedBox(height: 12),

          SettingsSectionHeader(title: 'About'),
          AboutSection(),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
