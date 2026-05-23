import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tutorial_provider.dart';
import 'tutorial_bubble.dart';

class TutorialAnchor extends ConsumerStatefulWidget {
  final String tutorialId;
  final String title;
  final String description;
  final ArrowDirection arrowDirection;
  final BubbleAlignment alignment;
  final Widget child;

  const TutorialAnchor({
    super.key,
    required this.tutorialId,
    required this.title,
    required this.description,
    required this.arrowDirection,
    this.alignment = BubbleAlignment.center,
    required this.child,
  });

  @override
  ConsumerState<TutorialAnchor> createState() => _TutorialAnchorState();
}

class _TutorialAnchorState extends ConsumerState<TutorialAnchor> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    // Get the target's RenderBox to find its position and size
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final targetX = position.dx;
    final targetWidth = size.width;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        // Set card width to 280.0px.
        const double bubbleWidth = 280.0;
        // Align card's left edge exactly with the dashboard left margin (20.0px).
        const double cardLeft = 20.0;

        final double horizontalOffset = -targetX + cardLeft;

        // Calculate the arrow pointer horizontal coordinate relative to the card's left edge.
        final double pointerX = (targetX + targetWidth / 2 - cardLeft).clamp(24.0, bubbleWidth - 24.0);

        return CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: widget.arrowDirection == ArrowDirection.up
              ? Alignment.bottomLeft
              : Alignment.topLeft,
          followerAnchor: widget.arrowDirection == ArrowDirection.up
              ? Alignment.topLeft
              : Alignment.bottomLeft,
          offset: Offset(
            horizontalOffset,
            widget.arrowDirection == ArrowDirection.up ? 16.0 : -16.0,
          ),
          // We wrap the follower's child in an Align widget because the root Overlay 
          // passes tight full-screen constraints to its children. Align relaxes these 
          // constraints, allowing our SizedBox inside TutorialBubble to enforce the exact 
          // width of 280.0px.
          child: Align(
            alignment: widget.arrowDirection == ArrowDirection.up
                ? Alignment.topLeft
                : Alignment.bottomLeft,
            child: Material(
              type: MaterialType.transparency,
              child: TutorialBubble(
                title: widget.title,
                description: widget.description,
                arrowDirection: widget.arrowDirection,
                pointerX: pointerX,
                width: bubbleWidth,
                onDismiss: () {
                  ref.read(tutorialProvider.notifier).completeStep(widget.tutorialId);
                },
                onSkipAll: () {
                  ref.read(tutorialProvider.notifier).skipAll();
                },
              ),
            ),
          ),
        );
      },
    );

    // Insert overlay entry into the closest Overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorialState = ref.watch(tutorialProvider).value;
    final isRouteActive = ModalRoute.of(context)?.isCurrent ?? true;
    final isActive = isRouteActive && (tutorialState?.activeStep == widget.tutorialId);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (isActive) {
        // Wait for page transitions to complete to ensure accurate coordinates
        await Future.delayed(const Duration(milliseconds: 1000));
        if (!context.mounted) return;

        // Re-check active state after the delay
        final currentTutorialState = ref.read(tutorialProvider).value;
        final currentRouteActive = ModalRoute.of(context)?.isCurrent ?? true;
        final stillActive = currentRouteActive && (currentTutorialState?.activeStep == widget.tutorialId);

        if (stillActive) {
          _showOverlay();
        }
      } else {
        _hideOverlay();
      }
    });

    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );
  }
}

enum BubbleAlignment { left, right, center }
