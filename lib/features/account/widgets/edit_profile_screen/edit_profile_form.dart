import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toast.dart';

class EditProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const EditProfileForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel('Full Name', theme),
          TextFormField(
            controller: nameController,
            style: theme.textTheme.bodyLarge,
            decoration: _glassDecoration(theme, 'Enter your name', Icons.person_outline),
            validator: (val) => val == null || val.trim().isEmpty ? 'Name cannot be empty' : null,
          ),
          const SizedBox(height: 24),

          _buildLabel('Email', theme),
          TextFormField(
            controller: emailController,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            enabled: false, // Read-only
            decoration: _glassDecoration(theme, 'Your email', Icons.email_outlined),
          ),
          const SizedBox(height: 24),

          _buildLabel('Phone Number', theme),
          TextFormField(
            controller: phoneController,
            style: theme.textTheme.bodyLarge,
            keyboardType: TextInputType.phone,
            decoration: _glassDecoration(theme, 'Enter phone number', Icons.phone_outlined),
          ),
          const SizedBox(height: 24),

          _buildLabel('Password', theme),
          GestureDetector(
            onTap: () {
              CustomToast.show(context: context, message: 'Change Password screen coming soon!', isError: false);
            },
            child: AbsorbPointer(
              child: TextFormField(
                initialValue: '********',
                readOnly: true,
                decoration: _glassDecoration(
                  theme, 
                  'Change Password', 
                  Icons.lock_outline,
                ).copyWith(
                  suffixIcon: const Icon(Icons.chevron_right, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  InputDecoration _glassDecoration(ThemeData theme, String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      filled: true,
      fillColor: theme.colorScheme.surface.withValues(alpha: 0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      prefixIcon: icon != null 
          ? Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)) 
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.cobaltBlue,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
          width: 1,
        ),
      ),
    );
  }
}
