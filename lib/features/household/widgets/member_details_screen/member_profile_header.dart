import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/household_provider.dart';

class MemberProfileHeader extends ConsumerStatefulWidget {
  final int memberId;
  final String memberName;
  final String role;

  const MemberProfileHeader({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.role,
  });

  @override
  ConsumerState<MemberProfileHeader> createState() => _MemberProfileHeaderState();
}

class _MemberProfileHeaderState extends ConsumerState<MemberProfileHeader> {
  Uint8List? _decodedImage;
  String? _lastPfp;

  void _updateImage(String? pfp) {
    if (pfp == null || pfp.isEmpty) {
      if (_decodedImage != null) {
        setState(() {
          _decodedImage = null;
          _lastPfp = null;
        });
      }
      return;
    }

    if (pfp != _lastPfp) {
      try {
        final base64String = pfp.contains(',') ? pfp.split(',').last : pfp;
        setState(() {
          _decodedImage = base64Decode(base64String);
          _lastPfp = pfp;
        });
      } catch (_) {
        setState(() {
          _decodedImage = null;
          _lastPfp = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Watch household to get current pfp string
    final members = ref.watch(householdProvider).value?['members'] as List<dynamic>?;
    final member = members?.firstWhere((m) => m['id'] == widget.memberId, orElse: () => null);
    final pfp = member?['profilePicture']?.toString();

    _updateImage(pfp);

    // Create consistent avatar based on name hash
    final avatarColors = [
      Colors.purpleAccent,
      Colors.deepOrangeAccent,
      Colors.tealAccent.shade400,
      AppColors.cobaltBlue,
    ];
    final colorHash = widget.memberName.hashCode.abs() % avatarColors.length;
    final avatarColor = avatarColors[colorHash];

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [avatarColor.withValues(alpha: 0.8), avatarColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: avatarColor.withValues(alpha: 0.3), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              ),
            ],
          ),
          child: _decodedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.memory(
                    _decodedImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                )
              : Center(
                  child: Text(
                    widget.memberName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 32, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.memberName,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.role == 'Admin' 
                ? AppColors.cobaltBlue.withValues(alpha: 0.1) 
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.role,
            style: theme.textTheme.labelMedium?.copyWith(
              color: widget.role == 'Admin' 
                  ? AppColors.cobaltBlue 
                  : colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
