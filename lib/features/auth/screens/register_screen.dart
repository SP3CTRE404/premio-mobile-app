import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/screens/main_scaffold.dart';
import '../models/auth_request.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_redirect.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';
import '../../../core/widgets/custom_toast.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _householdNameController = TextEditingController();
  bool _createHousehold = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _householdNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_createHousehold && _householdNameController.text.trim().isEmpty) {
        CustomToast.show(context: context, message: 'Please enter a household name', isError: false);
        return;
      }

      final request = RegisterRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        createHousehold: _createHousehold,
        householdName:
            _createHousehold ? _householdNameController.text.trim() : '',
      );
      ref.read(authProvider.notifier).register(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthStatus>(authProvider, (previous, next) {
      if (next == AuthStatus.authenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
          (Route<dynamic> route) => false,
        );
      } else if (next == AuthStatus.error) {
        CustomToast.show(context: context, message: 'Registration failed. Please try again.', isError: false);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        title: 'Create Account',
                        subtitle: 'Start managing your subscriptions today.',
                      ),
                      const SizedBox(height: 32),
                      AuthTextField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _fullNameController,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Password',
                        hint: 'Create a password',
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Create New Household',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Switch(
                              value: _createHousehold,
                              onChanged: (value) {
                                setState(() {
                                  _createHousehold = value;
                                });
                              },
                              activeThumbColor: AppColors.cobaltBlue,
                            ),
                          ],
                        ),
                      ),
                      if (_createHousehold) ...[
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: 'Household Name',
                          hint: 'Enter household name',
                          controller: _householdNameController,
                        ),
                      ],
                      const SizedBox(height: 32),
                      AuthButton(
                        onPressed: _submit,
                        label: 'Sign Up',
                        isLoading: authState == AuthStatus.loading,
                      ),
                      const SizedBox(height: 32),
                      const AuthDivider(),
                      const SizedBox(height: 32),
                      GoogleSignInButton(
                        onPressed: () {
                          CustomToast.show(context: context, message: 'Google Sign-In coming soon!', isError: false);
                        },
                      ),
                      const SizedBox(height: 32),
                      AuthRedirect(
                        text: 'Already have an account?',
                        buttonText: 'Sign In',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
