import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/widgets/auth_background.dart';
import '../providers/account_provider.dart';
import '../widgets/edit_profile_screen/edit_profile_form.dart';
import '../widgets/edit_profile_screen/profile_avatar_editor.dart';
import '../widgets/edit_profile_screen/save_button.dart';
import '../../../core/widgets/custom_toast.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;
    
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) CustomToast.show(context: context, message: 'Error picking image: $e', isError: true);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      String? base64Image;
      
      // Encode picked image to base64 if a new one was selected
      if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
      }

      await ref.read(userProvider.notifier).updateProfile(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profilePicture: base64Image, // Will be null if no new image picked, leaving backend unchanged
      );

      if (mounted) {
        Navigator.pop(context);
        CustomToast.show(context: context, message: 'Profile updated successfully', isError: false);
      }
    } catch (e) {
      if (mounted) CustomToast.show(context: context, message: 'Failed to update profile: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to figure out what image to show in the editor circle
  Widget? _getDisplayImage() {
    final user = ref.read(userProvider).value;
    
    if (_pickedImage != null) {
      return ClipOval(child: Image.file(_pickedImage!, fit: BoxFit.cover, width: 128, height: 128));
    } else if (user?.profilePicture != null && user!.profilePicture!.isNotEmpty) {
      try {
        final b64 = user.profilePicture!.split(',').last;
        return ClipOval(child: Image.memory(base64Decode(b64), fit: BoxFit.cover, width: 128, height: 128));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileAvatarEditor(
                    initial: _nameController.text,
                    imageWidget: _getDisplayImage(), // Dynamically injected
                    onImageSourceSelected: _pickImage,
                  ),
                  const SizedBox(height: 40),

                  EditProfileForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                  ),
                  const SizedBox(height: 48),

                  SaveButton(
                    isLoading: _isLoading,
                    onPressed: _saveProfile,
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