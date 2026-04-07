import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileAvatarEditor extends StatelessWidget {
  final String initial;
  final Widget? imageWidget;
  final Function(ImageSource) onImageSourceSelected;

  const ProfileAvatarEditor({
    super.key,
    required this.initial,
    required this.onImageSourceSelected,
    this.imageWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 64,
            backgroundColor: AppColors.cobaltBlue.withValues(alpha: 0.1),
            child: imageWidget ?? Text(
              initial.isNotEmpty ? initial[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.cobaltBlue,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cobaltBlue,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 3),
            ),
            child: PopupMenuButton<ImageSource>(
              icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              position: PopupMenuPosition.under,
              offset: const Offset(20, 0), // Adjust to push more to the right
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: onImageSourceSelected,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<ImageSource>>[
                const PopupMenuItem<ImageSource>(
                  value: ImageSource.gallery,
                  child: Row(
                    children: [
                      Icon(Icons.photo_library_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Choose from Gallery'),
                    ],
                  ),
                ),
                const PopupMenuItem<ImageSource>(
                  value: ImageSource.camera,
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Take a Photo'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
