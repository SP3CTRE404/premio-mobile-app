import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MemberListItem extends StatefulWidget {
  final String name;
  final String role;
  final bool isYou;
  final bool showArrow;
  final String? profilePicture;
  final VoidCallback? onTap;

  const MemberListItem({
    super.key,
    required this.name,
    required this.role,
    required this.isYou,
    this.showArrow = true,
    this.profilePicture,
    this.onTap,
  });

  @override
  State<MemberListItem> createState() => _MemberListItemState();
}

class _MemberListItemState extends State<MemberListItem> {
  Uint8List? _decodedImage;

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  @override
  void didUpdateWidget(MemberListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profilePicture != oldWidget.profilePicture) {
      _decodeImage();
    }
  }

  void _decodeImage() {
    if (widget.profilePicture != null && widget.profilePicture!.isNotEmpty) {
      try {
        final base64String = widget.profilePicture!.contains(',')
            ? widget.profilePicture!.split(',').last
            : widget.profilePicture!;
        setState(() {
          _decodedImage = base64Decode(base64String);
        });
      } catch (e) {
        _decodedImage = null;
      }
    } else {
      setState(() {
        _decodedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Create consistent avatars
    final avatarColors = [
      Colors.purpleAccent,
      Colors.deepOrangeAccent,
      Colors.tealAccent.shade400,
      AppColors.cobaltBlue,
    ];
    final colorHash = widget.name.hashCode.abs() % avatarColors.length;
    final avatarColor = widget.isYou ? AppColors.cobaltBlue : avatarColors[colorHash];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          avatarColor.withValues(alpha: 0.8),
                          avatarColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: avatarColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _decodedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.memory(
                              _decodedImage!,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                          )
                        : Center(
                            child: Text(
                              widget.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.isYou) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.cobaltBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'You',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.cobaltBlue,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              widget.role == 'Admin' ? Icons.shield_rounded : Icons.person_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.role,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.showArrow)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
